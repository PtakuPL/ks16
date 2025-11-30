#!/bin/bash

# =============================================================================
# Counter-Strike 1.6 Server Installer
# Installs: ReHLDS, AMX Mod X, Metamod-r, ReGameDLL_CS
# Usage: ./install.sh [install_dir]
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default installation directory
INSTALL_DIR="${1:-$HOME/cs16_server}"

# Version URLs (latest releases)
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
REHLDS_URL="https://github.com/dreamstalker/rehlds/releases/latest/download/rehlds-bin-3.13.0.788-linux.zip"
AMXMODX_URL="https://www.amxmodx.org/amxxdrop/1.10/amxmodx-1.10.0-git5467-base-linux.tar.gz"
AMXMODX_CSTRIKE_URL="https://www.amxmodx.org/amxxdrop/1.10/amxmodx-1.10.0-git5467-cstrike-linux.tar.gz"
METAMOD_URL="https://github.com/theAsmodai/metamod-r/releases/latest/download/metamod-r-1.3.0.149-linux.tar.gz"
REGAMEDLL_URL="https://github.com/s1lentq/ReGameDLL_CS/releases/latest/download/regamedll-bin-5.26.0.668-linux.zip"

# Print colored message
print_msg() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${NC}"
}

print_header() {
    echo ""
    print_msg "$BLUE" "=============================================="
    print_msg "$BLUE" "$1"
    print_msg "$BLUE" "=============================================="
    echo ""
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_msg "$YELLOW" "Warning: Running as root is not recommended."
        print_msg "$YELLOW" "Consider running as a regular user."
    fi
}

# Detect OS and install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        print_msg "$GREEN" "Detected Debian/Ubuntu system"
        sudo dpkg --add-architecture i386
        sudo apt-get update
        sudo apt-get install -y lib32gcc-s1 lib32stdc++6 curl wget unzip tar screen
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL/Fedora
        print_msg "$GREEN" "Detected RHEL-based system"
        sudo yum install -y glibc.i686 libstdc++.i686 curl wget unzip tar screen
    elif [ -f /etc/arch-release ]; then
        # Arch Linux
        print_msg "$GREEN" "Detected Arch Linux system"
        sudo pacman -Sy --noconfirm lib32-gcc-libs lib32-glibc curl wget unzip tar screen
    else
        print_msg "$YELLOW" "Unknown distribution. Please install 32-bit libraries manually."
    fi
    
    print_msg "$GREEN" "Dependencies installed successfully!"
}

# Create installation directory
create_directories() {
    print_header "Creating Directories"
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/steamcmd"
    mkdir -p "$INSTALL_DIR/temp"
    
    print_msg "$GREEN" "Directories created at: $INSTALL_DIR"
}

# Download and install SteamCMD
install_steamcmd() {
    print_header "Installing SteamCMD"
    
    cd "$INSTALL_DIR/steamcmd"
    
    if [ ! -f "steamcmd.sh" ]; then
        print_msg "$YELLOW" "Downloading SteamCMD..."
        curl -sqL "$STEAMCMD_URL" | tar zxvf -
    else
        print_msg "$GREEN" "SteamCMD already installed"
    fi
    
    print_msg "$GREEN" "SteamCMD installed successfully!"
}

# Download CS 1.6 dedicated server via SteamCMD
install_cs16_base() {
    print_header "Installing Counter-Strike 1.6 Base Server"
    
    cd "$INSTALL_DIR/steamcmd"
    
    print_msg "$YELLOW" "Downloading CS 1.6 server files (this may take a while)..."
    
    ./steamcmd.sh +force_install_dir "$INSTALL_DIR/server" \
        +login anonymous \
        +app_update 90 validate \
        +quit
    
    print_msg "$GREEN" "CS 1.6 base server installed successfully!"
}

# Download and install ReHLDS
install_rehlds() {
    print_header "Installing ReHLDS"
    
    cd "$INSTALL_DIR/temp"
    
    print_msg "$YELLOW" "Downloading ReHLDS..."
    
    # Try to get latest release from GitHub API
    REHLDS_LATEST=$(curl -s https://api.github.com/repos/dreamstalker/rehlds/releases/latest | grep "browser_download_url.*linux" | cut -d '"' -f 4 | head -n1)
    
    if [ -n "$REHLDS_LATEST" ]; then
        wget -q "$REHLDS_LATEST" -O rehlds.zip || wget -q "$REHLDS_URL" -O rehlds.zip
    else
        wget -q "$REHLDS_URL" -O rehlds.zip
    fi
    
    unzip -o rehlds.zip -d rehlds_temp
    
    # Copy ReHLDS files
    cp -rf rehlds_temp/bin/linux32/* "$INSTALL_DIR/server/"
    
    rm -rf rehlds_temp rehlds.zip
    
    print_msg "$GREEN" "ReHLDS installed successfully!"
}

# Download and install Metamod-r
install_metamod() {
    print_header "Installing Metamod-r"
    
    cd "$INSTALL_DIR/temp"
    
    print_msg "$YELLOW" "Downloading Metamod-r..."
    
    # Try to get latest release from GitHub API
    METAMOD_LATEST=$(curl -s https://api.github.com/repos/theAsmodai/metamod-r/releases/latest | grep "browser_download_url.*linux.*tar.gz" | cut -d '"' -f 4 | head -n1)
    
    if [ -n "$METAMOD_LATEST" ]; then
        wget -q "$METAMOD_LATEST" -O metamod.tar.gz || wget -q "$METAMOD_URL" -O metamod.tar.gz
    else
        wget -q "$METAMOD_URL" -O metamod.tar.gz
    fi
    
    tar -xzf metamod.tar.gz
    
    # Copy Metamod files
    cp -rf addons "$INSTALL_DIR/server/cstrike/"
    
    # Create liblist.gam for metamod
    cat > "$INSTALL_DIR/server/cstrike/liblist.gam" << 'EOF'
game "Counter-Strike"
url_info "www.counter-strike.net"
url_dl ""
version "1.6"
size "184000000"
svonly "1"
secure "1"
type "multiplayer_only"
gamedll "addons/metamod/dlls/metamod.so"
gamedll_linux "addons/metamod/dlls/metamod.so"
gamedll_osx "dlls/cs.dylib"
cldll "1"
hlversion "1132"
mpentity "info_player_start"
EOF
    
    rm -rf addons metamod.tar.gz
    
    print_msg "$GREEN" "Metamod-r installed successfully!"
}

# Download and install ReGameDLL_CS
install_regamedll() {
    print_header "Installing ReGameDLL_CS"
    
    cd "$INSTALL_DIR/temp"
    
    print_msg "$YELLOW" "Downloading ReGameDLL_CS..."
    
    # Try to get latest release from GitHub API
    REGAMEDLL_LATEST=$(curl -s https://api.github.com/repos/s1lentq/ReGameDLL_CS/releases/latest | grep "browser_download_url.*linux" | cut -d '"' -f 4 | head -n1)
    
    if [ -n "$REGAMEDLL_LATEST" ]; then
        wget -q "$REGAMEDLL_LATEST" -O regamedll.zip || wget -q "$REGAMEDLL_URL" -O regamedll.zip
    else
        wget -q "$REGAMEDLL_URL" -O regamedll.zip
    fi
    
    unzip -o regamedll.zip -d regamedll_temp
    
    # Copy ReGameDLL files
    cp -rf regamedll_temp/bin/linux32/* "$INSTALL_DIR/server/cstrike/dlls/"
    
    # Copy config extras if they exist
    if [ -d "regamedll_temp/gamedata" ]; then
        cp -rf regamedll_temp/gamedata/* "$INSTALL_DIR/server/cstrike/"
    fi
    
    rm -rf regamedll_temp regamedll.zip
    
    # Update plugins.ini for ReGameDLL
    mkdir -p "$INSTALL_DIR/server/cstrike/addons/metamod"
    cat >> "$INSTALL_DIR/server/cstrike/addons/metamod/plugins.ini" << 'EOF'
linux addons/regamedll/cs.so
EOF
    
    print_msg "$GREEN" "ReGameDLL_CS installed successfully!"
}

# Download and install AMX Mod X
install_amxmodx() {
    print_header "Installing AMX Mod X"
    
    cd "$INSTALL_DIR/temp"
    
    print_msg "$YELLOW" "Downloading AMX Mod X base..."
    wget -q "$AMXMODX_URL" -O amxmodx_base.tar.gz
    
    print_msg "$YELLOW" "Downloading AMX Mod X cstrike addon..."
    wget -q "$AMXMODX_CSTRIKE_URL" -O amxmodx_cstrike.tar.gz
    
    # Extract to cstrike folder
    tar -xzf amxmodx_base.tar.gz -C "$INSTALL_DIR/server/cstrike/"
    tar -xzf amxmodx_cstrike.tar.gz -C "$INSTALL_DIR/server/cstrike/"
    
    # Add AMX Mod X to metamod plugins
    echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> "$INSTALL_DIR/server/cstrike/addons/metamod/plugins.ini"
    
    rm -f amxmodx_base.tar.gz amxmodx_cstrike.tar.gz
    
    print_msg "$GREEN" "AMX Mod X installed successfully!"
}

# Create server configuration
create_server_config() {
    print_header "Creating Server Configuration"
    
    # Create server.cfg
    cat > "$INSTALL_DIR/server/cstrike/server.cfg" << 'EOF'
// =============================================================================
// Counter-Strike 1.6 Server Configuration
// =============================================================================

// Server Name and Password
hostname "CS 1.6 Server - Powered by ReHLDS"
sv_password ""
rcon_password "change_this_password"

// Network Settings
sv_maxrate 25000
sv_minrate 4000
sv_maxupdaterate 102
sv_minupdaterate 20
sv_uploadmax 1

// Game Settings
mp_timelimit 30
mp_maxrounds 0
mp_winlimit 0
mp_roundtime 2.5
mp_freezetime 5
mp_buytime 1.5
mp_c4timer 35
mp_startmoney 800

// Team Settings
mp_autoteambalance 1
mp_limitteams 2
mp_friendlyfire 0
mp_tkpunish 0
mp_forcechasecam 2
mp_forcecamera 2

// Server Behavior
sv_voiceenable 1
sv_alltalk 0
mp_chattime 5
mp_flashlight 1
mp_footsteps 1

// Anti-Cheat
sv_cheats 0
sv_allowupload 0
sv_allowdownload 1

// Performance
sys_ticrate 1000
fps_max 1000

// Logging
log on
sv_log_onefile 0
sv_logbans 1
sv_logecho 1
sv_logfile 1
mp_logfile 1
mp_logmessages 1

// Execute additional configs
exec listip.cfg
exec banned.cfg
EOF

    # Create mapcycle.txt
    cat > "$INSTALL_DIR/server/cstrike/mapcycle.txt" << 'EOF'
de_dust2
de_inferno
de_nuke
de_train
de_mirage
de_cache
de_cbble
de_overpass
cs_office
cs_italy
cs_assault
de_aztec
de_dust
de_vertigo
EOF

    # Create motd.txt
    cat > "$INSTALL_DIR/server/cstrike/motd.txt" << 'EOF'
<html>
<head>
<style>
body {
    background-color: #1a1a2e;
    color: #eee;
    font-family: Arial, sans-serif;
    padding: 20px;
}
h1 {
    color: #ff6b35;
}
</style>
</head>
<body>
<h1>Welcome to CS 1.6 Server!</h1>
<p>Powered by ReHLDS + AMX Mod X</p>
<p>Have fun and play fair!</p>
</body>
</html>
EOF

    print_msg "$GREEN" "Server configuration created successfully!"
}

# Configure AMX Mod X
configure_amxmodx() {
    print_header "Configuring AMX Mod X"
    
    # Ensure plugins directory exists
    mkdir -p "$INSTALL_DIR/server/cstrike/addons/amxmodx/configs"
    
    # Create admin users list
    cat > "$INSTALL_DIR/server/cstrike/addons/amxmodx/configs/users.ini" << 'EOF'
; AMX Mod X Admin Users
; Format: "name" "password" "access" "flags"
;
; Access flags:
; a - immunity (can't be kicked/banned)
; b - reservation (slot reservation)
; c - amx_kick command
; d - amx_ban and amx_unban commands
; e - amx_slay and amx_slap commands
; f - amx_map command
; g - amx_cvar command
; h - amx_cfg command
; i - amx_chat and admin chat commands
; j - amx_vote commands
; k - access to sv_password
; l - amx_rcon command
; m - amx_modules command (and access to menus)
; n - custom level A
; o - custom level B
; p - custom level C
; q - custom level D
; r - custom level E
; s - custom level F
; t - custom level G
; u - custom level H
; z - user (no admin)
;
; Account flags:
; a - disconnect player on invalid password
; b - clan tag
; c - this is a steamid/WonID (use only STEAM_ format)
; d - this is an IP address
; e - password not checked (only name/ip/steamid needed)
; k - name or tag is case sensitive. The name or tag must match exactly.
;
; Example entries:
; "STEAM_0:0:123456" "" "abcdefghijklmnopqrstu" "ce"
; "admin_name" "admin_password" "abcdefghijklmnopqrstu" "a"

; Add your admins here:
; "your_steam_id" "" "abcdefghijklmnopqrstu" "ce"
EOF

    # Create enabled plugins list
    cat > "$INSTALL_DIR/server/cstrike/addons/amxmodx/configs/plugins.ini" << 'EOF'
; AMX Mod X plugins
; Admin commands
admin.amxx
adminhelp.amxx
admincmd.amxx
adminvote.amxx
adminslots.amxx

; General plugins
plmenu.amxx
telemenu.amxx
mapsmenu.amxx
pluginmenu.amxx
cmdmenu.amxx
menufront.amxx
multilingual.amxx

; Chat plugins
adminchat.amxx
scrollmsg.amxx

; Map settings
mapchooser.amxx
timeleft.amxx
nextmap.amxx

; Counter-Strike specific
csstats.amxx
miscstats.amxx
restmenu.amxx
statscfg.amxx

; Fun plugins
pausecfg.amxx
statsx.amxx
EOF

    print_msg "$GREEN" "AMX Mod X configured successfully!"
}

# Create server control scripts
create_control_scripts() {
    print_header "Creating Control Scripts"
    
    # Create start script
    cat > "$INSTALL_DIR/start.sh" << EOF
#!/bin/bash
cd "$INSTALL_DIR/server"
screen -dmS cs16 ./hlds_run -game cstrike +maxplayers 32 +map de_dust2 -port 27015 +sys_ticrate 1000
echo "Server started in screen session 'cs16'"
echo "Use 'screen -r cs16' to attach to the server console"
echo "Use 'Ctrl+A D' to detach from the console"
EOF
    chmod +x "$INSTALL_DIR/start.sh"
    
    # Create stop script
    cat > "$INSTALL_DIR/stop.sh" << 'EOF'
#!/bin/bash
screen -S cs16 -X quit
echo "Server stopped"
EOF
    chmod +x "$INSTALL_DIR/stop.sh"
    
    # Create restart script
    cat > "$INSTALL_DIR/restart.sh" << EOF
#!/bin/bash
"$INSTALL_DIR/stop.sh"
sleep 3
"$INSTALL_DIR/start.sh"
echo "Server restarted"
EOF
    chmod +x "$INSTALL_DIR/restart.sh"
    
    # Create status script
    cat > "$INSTALL_DIR/status.sh" << 'EOF'
#!/bin/bash
if screen -list | grep -q "cs16"; then
    echo "Server is RUNNING"
    echo "Use 'screen -r cs16' to view console"
else
    echo "Server is STOPPED"
fi
EOF
    chmod +x "$INSTALL_DIR/status.sh"
    
    # Create update script
    cat > "$INSTALL_DIR/update.sh" << EOF
#!/bin/bash
echo "Stopping server..."
"$INSTALL_DIR/stop.sh"
sleep 3

echo "Updating server..."
cd "$INSTALL_DIR/steamcmd"
./steamcmd.sh +force_install_dir "$INSTALL_DIR/server" +login anonymous +app_update 90 validate +quit

echo "Update complete!"
echo "You may need to reinstall ReHLDS and plugins after major updates."
EOF
    chmod +x "$INSTALL_DIR/update.sh"
    
    print_msg "$GREEN" "Control scripts created successfully!"
}

# Clean up temporary files
cleanup() {
    print_header "Cleaning Up"
    
    rm -rf "$INSTALL_DIR/temp"
    
    print_msg "$GREEN" "Cleanup complete!"
}

# Display final information
show_final_info() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}Counter-Strike 1.6 Server has been installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Installation Directory:${NC} $INSTALL_DIR"
    echo ""
    echo -e "${YELLOW}Server Control Commands:${NC}"
    echo -e "  Start:   ${BLUE}$INSTALL_DIR/start.sh${NC}"
    echo -e "  Stop:    ${BLUE}$INSTALL_DIR/stop.sh${NC}"
    echo -e "  Restart: ${BLUE}$INSTALL_DIR/restart.sh${NC}"
    echo -e "  Status:  ${BLUE}$INSTALL_DIR/status.sh${NC}"
    echo -e "  Update:  ${BLUE}$INSTALL_DIR/update.sh${NC}"
    echo ""
    echo -e "${YELLOW}Important Files:${NC}"
    echo -e "  Server Config: ${BLUE}$INSTALL_DIR/server/cstrike/server.cfg${NC}"
    echo -e "  AMX Admins:    ${BLUE}$INSTALL_DIR/server/cstrike/addons/amxmodx/configs/users.ini${NC}"
    echo -e "  AMX Plugins:   ${BLUE}$INSTALL_DIR/server/cstrike/addons/amxmodx/configs/plugins.ini${NC}"
    echo -e "  Map Cycle:     ${BLUE}$INSTALL_DIR/server/cstrike/mapcycle.txt${NC}"
    echo ""
    echo -e "${RED}IMPORTANT:${NC} Change the RCON password in server.cfg before running the server!"
    echo -e "${RED}IMPORTANT:${NC} Configure your firewall to allow port 27015 (UDP)"
    echo ""
    echo -e "${YELLOW}To connect to your server:${NC}"
    echo -e "  connect <your_server_ip>:27015"
    echo ""
}

# Main installation process
main() {
    print_header "CS 1.6 Server Installation Script"
    print_msg "$YELLOW" "Installation directory: $INSTALL_DIR"
    echo ""
    
    check_root
    install_dependencies
    create_directories
    install_steamcmd
    install_cs16_base
    install_rehlds
    install_metamod
    install_regamedll
    install_amxmodx
    create_server_config
    configure_amxmodx
    create_control_scripts
    cleanup
    show_final_info
}

# Run main function
main "$@"
