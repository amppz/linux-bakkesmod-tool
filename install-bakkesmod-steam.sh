#!/bin/bash

# Where bakkesmod.sh will be moved
BIN_PATH=~/.local/bin/

# Location of the desktop file
DE_PATH=~/.local/share/applications/

ICON_PATH=~/.local/share/icons/

COMPILE=1

INSTALL_DESKTOP=1


install(){
    # Download bakkesmod
    wget https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/latest/download/BakkesModSetup.zip -O ./BakkesModSetup.zip && unzip -q ./BakkesModSetup.zip -O 
    # Set prefix to windows 10
    protontricks 252950 win10
    # Run setup
    protontricks -c "wine '$PWD/BakkesModSetup.exe'" 252950

    local proton_prefix
    proton_prefix=$(protontricks -c "printenv WINEPREFIX" 252950)
    
    # Add injector to the wineprefix
    cp ./Inject.exe "$proton_prefix/drive_c/Program Files/BakkesMod/Inject.exe"

    # bakkesmod-tool installation
    chmod +x ./bakkesmod-tool-steam.sh
    cp ./bakkesmod-tool-steam.sh $BIN_PATH/bakkesmod-tool
    
    echo "Remember to set your steam launch arguments to:"
    echo "bakkesmod-tool --inject & %command%"
    read -r
}

# So that bakkesmod:// links work and so that bakkesmod can be opened from menu
desktop_install(){
    desktop-file-edit ./bakkesmod.desktop --set-key=Exec --set-value="$BIN_PATH/bakkesmod-tool"
    desktop-file-edit ./bakkesmod-plugin.desktop --set-key=Exec --set-value="$BIN_PATH/bakkesmod-tool -p %u"

    # Bakkesmod icon
    curl https://bp-prod.nyc3.digitaloceanspaces.com/site-assets/static/bm-transparent.png -o $ICON_PATH/hicolor/512x512/bakkesmod.png --create-dirs
    
    desktop-file-install ./bakkesmod-plugin.desktop --dir=$DE_PATH
    desktop-file-install ./bakkesmod.desktop --dir=$DE_PATH

    xdg-mime default bakkesmod-plugin.desktop x-scheme-handler/bakkesmod
    update-desktop-database $DE_PATH
}

cleanup(){
    rm BakkesModSetup.zip BakkesModSetup.exe
}

show_help(){
    echo "Usage:"
    echo "	install-bakkesmod-steam [OPTION...]"
    echo "Install BakkesMod for Steam."
    echo ""
    echo "With no OPTION, compiles BakkesMod Injector and installs bakkesmod-tool to default paths"
    echo ""
    echo "  --bin-path EXE_DIR                  Installs bakkesmod-tool to EXE_DIR, ~/.local/bin/ "
    echo "  --de-path DESKTOP_ENTRY_DIR         Installs desktop entries to DESKTOP_ENTRY_DIR, ~/.local/share/applications/"
    echo "  --icon-path ICON_DIR                Installs icons for desktop entries to ICON_DIR, ~/.local/share/icons/ by default"           
    echo "  --dont-compile-injector             Prevents the installer from compiling Inject.exe. For those who already have Inject.exe in their folder"
    echo "  --dont-install-desktop-files        Prevents desktop files from being installed"
}

check_requirements(){
    CAN_INSTALL=0

    # Check rocket league and protontricks exist
    foundRocketLeague=$(protontricks -l | grep 252950)
    if [[ -n $foundRocketLeague ]]; then
        ((CAN_INSTALL++))
    else 
        echo "Error: Protontricks is missing or cannot find Rocket League" > "$(tty)"
    fi

    # Check that compiler exists
    if [[ COMPILE -eq 0 ]] || command -v x86_64-w64-mingw32-g++ &> /dev/null; then
        ((CAN_INSTALL++))
    else
        echo "Error: x86_64-w64-mingw32-g++ is missing, injector cannot be compiled" > "$(tty)"
    fi
    echo "$CAN_INSTALL"
}


while [[ -n $1 ]]; 
do
    opt=${1}
    shift
    case ${opt} in
        --bin-path)
            BIN_PATH="$1"
            shift
            ;;
        --de-path)
            DE_PATH="$1"
            shift
            ;;
        --dont-compile-injector)
            COMPILE=0
            ;;
        --dont-install-desktop-files)
            INSTALL_DESKTOP=0
            ;;
        --help)
            show_help
            exit 0
            ;;
        --icon-path)
            ICON_PATH="$1"
            shift
            ;;
        *)
            echo "Error: Invalid parameter"
            exit 1
            ;;
    esac
done

if [[ $(check_requirements) -ne 2 ]]; then
    echo "Failed to install due to missing requirements"
    exit 1
fi

[[ COMPILE -eq 1 ]] && echo "Compiling BakkesMod injector" && x86_64-w64-mingw32-g++ Inject.cpp -municode -mconsole -lpsapi -std=c++17 -o Inject.exe -static -w && echo "Finished compilation"

# Verify injector exists
if [[ $(ls Inject.exe) = Inject.exe ]]; then
    echo "Installing"
    echo "$BIN_PATH"
    echo "$DE_PATH"
    echo "$ICON_PATH"

    install
    [[ INSTALL_DESKTOP = 1 ]] && desktop_install
    cleanup
else
    echo "Error: Inject.exe not found"
    [[ COMPILE -eq 1 ]] && echo "If compilation failed try installing $(tput bold)x86_64-w64-mingw32-g++ $(tput sgr0)or $(tput bold)mingw64-winpthreads-static"
    exit 1
fi
