#!/bin/bash

show_help(){
    echo "Usage:"
    echo "	bakkesmod-tool [OPTION?]"
    echo "Start BakkesMod."
    echo ""
    echo "With no OPTION, starts BakkesMod application"
    echo ""
    echo "  -p, --plugin-install LINK       Installs a plugin with a link in the format bakkesmod://install/"
    echo "  -i, --inject                    Injects Rocket League with BakkesMod"
    echo "  -h, --help                      Shows this help message"
    echo "  -s, --start                     Starts BakkesMod application, note that the Rocket League will not start if BakkesMod is already open"
}

# This function is stolen from https://reddit.com/r/bakkesmod/comments/w9e7ur/running_bakkesmod_on_linux_with_steam_proton/ihz37h3/?context=3
inject(){
    # Wait until Rocket League is running
    echo "Waiting for Rocket League to start"
    while ! killall -0 RocketLeague.ex 2> /dev/null; do
        sleep 1
    done
    echo "Rocket League has started, now starting BakkesMod"
    # Start BakkesMod
    WINEFSYNC=1 protontricks -c "wine 'c:/Program Files/BakkesMod/BakkesMod.exe'" 252950 &
    
    echo "Waiting for bakkesmod to close"
    # Wait until user updates and closes BakkesMod
    while killall -0 BakkesMod.ex 2> /dev/null; do
        sleep 1
    done
    echo "Injecting"
    # Use custom injector to inject instead
    WINEFSYNC=1 protontricks -c "wine 'c:/Program Files/BakkesMod/Inject.exe'" 252950
}

echo "Unofficial BakkesMod Tool"

if [ ${#} -lt 1 ];
then
    WINEFSYNC=1 protontricks -c "wine 'c:/Program Files/BakkesMod/BakkesMod.exe'" 252950
else
    opt=${1}
    case ${opt} in
        -p | --plugin-install)
            shift
            protontricks -c "wine 'c:/users/steamuser/AppData/Roaming/bakkesmod/bakkesmod/plugininstaller.exe' $1" 252950
            ;;
        -i | --inject)
            inject
            ;;
        -h | --help)
            show_help
            ;;
        -s | --start)
            WINEFSYNC=1 protontricks -c "wine 'c:/Program Files/BakkesMod/BakkesMod.exe'" 252950
            ;;
        *)
            echo "Invalid parameter, see valid parameters in bakkesmod-tool --help"
            ;;
    esac
fi
