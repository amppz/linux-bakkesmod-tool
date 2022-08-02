# linux-bakkesmod-tool
Some scripts put together to make installing and using bakkesmod easier for Linux users

## Prerequisites
- **Rocket League** for Steam must be installed
- **[Protontricks](https://github.com/Matoking/protontricks)** must be installed 
- (Optional) x86_64-w64-mingw32-g++ 
- (Optional) mingw64-winpthreads-static

The two optional prerequisites are only optional if you want to use the precompiled Inject.exe (use `--dont-compile-injector` on the installer), it's probably a better idea to compile Inject.cpp yourself
# Installing
Simply run install-bakkesmod-steam.sh to install. 
#### Installation Options
```
  --bin-path EXE_DIR                  Installs bakkesmod-tool to EXE_DIR, defaults to ~/.local/bin/ 
  --de-path DESKTOP_ENTRY_DIR         Installs desktop entries to DESKTOP_ENTRY_DIR, defaults to ~/.local/share/applications/
  --icon-path ICON_DIR                Installs icons for desktop entries to ICON_DIR, defaults to ~/.local/share/icons/ by default
  --dont-compile-injector             Prevents the installer from compiling Inject.exe. For those who would like to use an Inject.exe already in their folder.
  --dont-install-desktop-files        Prevents desktop files from being installed
```
After installation, make sure to set your Steam launch options to `bakkesmod-tool --inject & %command%` to inject bakkesmod into the game
# Running
Run bakkesmod-tool to start the normal BakkesMod application - you will likely get errors if you use this to inject the game - use the injector with 
#### Running Options
```
  -p, --plugin-install LINK       Installs a plugin with a link in the format bakkesmod://
  -i, --inject                    Injects Rocket League with BakkesMod. 
  -h, --help                      Shows this help 
  -s, --start                     Starts BakkesMod application, note that the game will not start if BakkesMod is already open
```
# Troubleshooting
### Rocket League doesn't open
Close the BakkesMod application, and if this doesn't work run `protontricks -c 'wineserver -k' 252950` which kills all wine processes in the Rocket League wineprefix.

# Credits

[Allavaz](https://gist.github.com/allavaz) for instructions on how to install BakkesMod https://allavaz.github.io/2022/07/26/bakkesmod-on-linux.html

[blastrock](https://gist.github.com/blastrock) for the custom injector https://gist.github.com/blastrock/6958033f03a0bdffa52c6dfa2ce0e60a

Claritux for the bakkesmod launch script https://www.reddit.com/r/bakkesmod/comments/w9e7ur/comment/ihz37h3/?utm_source=reddit&utm_medium=web2x&context=3

[BakkesMod](https://github.com/bakkesmodorg) for obvious reasons
