#include <windows.h>

#include <tlhelp32.h>

#include <iostream>
#include <string>

#define LOG_LINE(x, msg) std::cout << msg << std::endl;

DWORD GetProcessID64(std::wstring processName)
{
  PROCESSENTRY32 processInfo;
  processInfo.dwSize = sizeof(processInfo);

  HANDLE processesSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, NULL);
  if (processesSnapshot == INVALID_HANDLE_VALUE)
    return 0;

  Process32First(processesSnapshot, &processInfo);
  if (_wcsicmp(processName.c_str(), processInfo.szExeFile) == 0)
  {

    BOOL iswow64 = FALSE;
    // https://stackoverflow.com/questions/14184137/how-can-i-determine-whether-a-process-is-32-or-64-bit
    // If IsWow64Process() reports true, the process is 32-bit running on a
    // 64-bit OS So we want it to return false (32 bit on 32 bit os, or 64 bit on
    // 64 bit OS, since we build x64 the first condition will never satisfy since
    // they can't run this exe)

    auto hProcess =
        OpenProcess(PROCESS_ALL_ACCESS, FALSE, processInfo.th32ProcessID);
    if (hProcess == NULL)
    {
      LOG_LINE(INFO, "Error on OpenProcess to check bitness");
    }
    else
    {

      if (IsWow64Process(hProcess, &iswow64))
      {
        // LOG_LINE(INFO, "Rocket league process ID is " <<
        // processInfo.th32ProcessID << " | " << " has the WOW factor: " <<
        // iswow64);
        if (!iswow64)
        {
          CloseHandle(processesSnapshot);
          return processInfo.th32ProcessID;
        }
      }
      else
      {
        LOG_LINE(INFO, "IsWow64Process failed bruv " << GetLastError());
      }
      CloseHandle(hProcess);
    }
  }

  while (Process32Next(processesSnapshot, &processInfo))
  {
    if (_wcsicmp(processName.c_str(), processInfo.szExeFile) == 0)
    {
      BOOL iswow64 = FALSE;
      auto hProcess =
          OpenProcess(PROCESS_ALL_ACCESS, FALSE, processInfo.th32ProcessID);
      if (hProcess == NULL)
      {
        LOG_LINE(INFO, "Error on OpenProcess to check bitness");
      }
      else
      {

        if (IsWow64Process(hProcess, &iswow64))
        {
          // LOG_LINE(INFO, "Rocket league process ID is " <<
          // processInfo.th32ProcessID << " | " << " has the WOW factor: " <<
          // iswow64);
          if (!iswow64)
          {
            CloseHandle(processesSnapshot);
            return processInfo.th32ProcessID;
          }
        }
        else
        {
          LOG_LINE(INFO, "IsWow64Process failed bruv " << GetLastError());
        }
        CloseHandle(hProcess);
      }
    }
    // CloseHandle(processesSnapshot);
  }

  CloseHandle(processesSnapshot);
  return 0;
}

int wmain(int argc, wchar_t* argv[])
{
  DWORD processID;
  while (true)
  {
    processID = GetProcessID64(L"RocketLeague.exe");
    if (processID != 0)
      break;
    Sleep(100);
  }

  HANDLE h = OpenProcess(PROCESS_ALL_ACCESS, false, processID);
  if (h)
  {
    LPVOID LoadLibAddr = (LPVOID)GetProcAddress(
        GetModuleHandleW(L"kernel32.dll"), "LoadLibraryW");
    auto ws = L"C:\\users\\steamuser\\Application Data\\bakkesmod\\bakkesmod/dll\\bakkesmod.dll";
    auto wslen = (std::wcslen(ws) + 1) * sizeof(WCHAR);
    LPVOID dereercomp = VirtualAllocEx(
        h, NULL, wslen, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    WriteProcessMemory(h, dereercomp, ws, wslen, NULL);
    HANDLE asdc = CreateRemoteThread(
        h,
        NULL,
        NULL,
        (LPTHREAD_START_ROUTINE)LoadLibAddr,
        dereercomp,
        0,
        NULL);
    WaitForSingleObject(asdc, INFINITE);
    DWORD res = 0;
    GetExitCodeThread(asdc, &res);
    LOG_LINE(INFO, "GetExitCodeThread(): " << (int)res);
    LOG_LINE(INFO, "Last error: " << GetLastError());
    VirtualFreeEx(h, dereercomp, wslen, MEM_RELEASE);
    CloseHandle(asdc);
    CloseHandle(h);
    return res == 0;
  }
  return 1;
}
