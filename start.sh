#!/bin/bash

# ███████████████████████████████████████████████████████████████████████████████
# █                                                                             █
# █                        𝗖𝗭𝗔𝗥𝗔𝗖𝗧𝗬𝗟 𝗦𝗘𝗥𝗩𝗘𝗥 𝗠𝗔𝗡𝗔𝗚𝗘𝗥                              █
# █                                                                             █
# █                      Made by Arpit for Czar                                 █
# █                                                                             █
# ███████████████████████████████████████████████████████████████████████████████

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ CONFIGURATION                                                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Version information
VERSION="1.0.0"
CODENAME="Phoenix"

# Default settings
DEFAULT_MEMORY="1G"
DEFAULT_PORT="25565"
DEFAULT_MC_VERSION="1.20.4"

# Enhanced color palette
RESET="\033[0m"
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
BOLD_BLACK="\033[1;30m"
BOLD_RED="\033[1;31m"
BOLD_GREEN="\033[1;32m"
BOLD_YELLOW="\033[1;33m"
BOLD_BLUE="\033[1;34m"
BOLD_PURPLE="\033[1;35m"
BOLD_CYAN="\033[1;36m"
BOLD_WHITE="\033[1;37m"
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_PURPLE="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Unicode symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➤"
STAR="★"
DIAMOND="♦"
ROCKET="🚀"
FIRE="🔥"
GEAR="⚙️"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ UTILITY FUNCTIONS                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Function to print centered text
print_centered() {
    local text="$1"
    local color="${2:-$RESET}"
    local width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (width - ${#text}) / 2 ))
    
    printf "%${padding}s" ""
    echo -e "${color}${text}${RESET}"
}

# Function to print a horizontal line
print_line() {
    local character="${1:-═}"
    local color="${2:-$BOLD_CYAN}"
    local width=$(tput cols 2>/dev/null || echo 80)
    
    echo -ne "$color"
    for ((i=0; i<width; i++)); do
        echo -n "$character"
    done
    echo -e "$RESET"
}

# Function to print a section header
print_header() {
    local title="$1"
    local color="${2:-$BOLD_CYAN}"
    
    echo
    print_line "═" "$color"
    print_centered "$title" "$color"
    print_line "═" "$color"
    echo
}

# Function to display a spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to display a menu with options
display_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    print_header "$title"
    
    for ((i=0; i<${#options[@]}; i++)); do
        local option_num=$((i+1))
        echo -e " ${BOLD_WHITE}${option_num})${RESET} ${options[$i]}"
    done
    
    echo
    echo -ne " ${BOLD_YELLOW}${ARROW} ${RESET}Enter your choice (1-${#options[@]}): "
}

# Function to get user input with validation
get_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    echo -ne "${BOLD_YELLOW}${ARROW} ${RESET}${prompt}"
    if [ -n "$default" ]; then
        echo -ne " [${BOLD_GREEN}${default}${RESET}]: "
    else
        echo -ne ": "
    fi
    
    read -r result
    
    # Use default if input is empty
    if [ -z "$result" ] && [ -n "$default" ]; then
        result="$default"
    fi
    
    echo "$result"
}

# Function to get yes/no input
get_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local result
    
    while true; do
        echo -ne "${BOLD_YELLOW}${ARROW} ${RESET}${prompt} (${default^^}/${default:0:1==y?n:y}): "
        read -r result
        
        # Use default if input is empty
        if [ -z "$result" ]; then
            result="$default"
        fi
        
        # Convert to lowercase
        result=$(echo "$result" | tr '[:upper:]' '[:lower:]')
        
        # Validate input
        if [[ "$result" == "y" || "$result" == "yes" || "$result" == "n" || "$result" == "no" ]]; then
            break
        else
            echo -e "${BOLD_RED}${CROSS_MARK} Invalid input. Please enter Y/N.${RESET}"
        fi
    done
    
    [[ "$result" == "y" || "$result" == "yes" ]]
}

# Function to download with retry
download_with_retry() {
    local url="$1"
    local output_file="$2"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -s -L -o "$output_file" "$url"; then
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Download failed. Retrying ($retry_count/$max_retries)..."
            sleep 2
        else
            echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download after $max_retries attempts."
            return 1
        fi
    done
    
    return 1
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ CORE FUNCTIONS                                                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Function to display the banner
show_banner() {
    clear
    echo -e "${BOLD_CYAN}"
    cat << "EOF"
   ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
  ██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
  ██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
  ██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
  ╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
   ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
    echo -e "${RESET}"
    
    print_centered "✧ MULTI-SOFTWARE SERVER MANAGER ✧" "$BOLD_YELLOW"
    print_centered "Version ${VERSION} - ${CODENAME}" "$BOLD_WHITE"
    print_centered "Made by Arpit for Czar" "$BOLD_PURPLE"
    print_line "═" "$BOLD_CYAN"
    echo
}

# Function to detect Java version
setup_java() {
    print_header "Java Configuration"
    
    # Get Java version
    if command -v java >/dev/null 2>&1; then
        local java_version_output
        java_version_output=$(java -version 2>&1)
        JAVA_VERSION=$(echo "$java_version_output" | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        
        echo -e "${BOLD_GREEN}${CHECK_MARK} Java detected:${RESET} Java ${JAVA_VERSION}"
    else
        echo -e "${BOLD_RED}${CROSS_MARK} Java not found. Please install Java 8 or higher.${RESET}"
        JAVA_VERSION=0
    fi
    
    # Set memory allocation
    if [ -n "$MEMORY" ]; then
        echo -e "${BOLD_WHITE}Memory:${RESET} Using configured value: ${BOLD_GREEN}${MEMORY}${RESET}"
    else
        MEMORY="$DEFAULT_MEMORY"
        echo -e "${BOLD_WHITE}Memory:${RESET} Using default: ${BOLD_GREEN}${MEMORY}${RESET}"
    fi
    
    # Set JVM flags
    JAVA_FLAGS=(
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
    )
}

# Function to download and install server software
install_server() {
    local server_type=$1
    local mc_version=$2
    
    print_header "Installing ${server_type^} Server"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Preparing to install ${BOLD_CYAN}${server_type^}${RESET} server (Minecraft ${BOLD_CYAN}${mc_version}${RESET})..."
    
    # Save the Minecraft version for plugin compatibility
    echo "$mc_version" > .mc-version
    
    # Create temporary directory for downloads
    local temp_dir=".czar_temp"
    mkdir -p "$temp_dir"
    
    case $server_type in
        "paper")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Paper server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            local download_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/latest/downloads/paper-$mc_version-latest.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Paper server jar."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Paper server jar downloaded successfully!"
            echo "paper" > .server-type
            ;;
            
        "forge")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            # Get latest Forge version for the specified Minecraft version
            local forge_version
            case "$mc_version" in
                "1.20.4") forge_version="49.0.14" ;;
                "1.19.4") forge_version="45.1.0" ;;
                "1.18.2") forge_version="40.2.0" ;;
                "1.17.1") forge_version="37.1.1" ;;
                "1.16.5") forge_version="36.2.39" ;;
                *) forge_version="49.0.14" ;;
            esac
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Forge installer for Minecraft ${BOLD_CYAN}${mc_version}${RESET} (Forge ${BOLD_CYAN}${forge_version}${RESET})..."
            
            local download_url="https://maven.minecraftforge.net/net/minecraftforge/forge/$mc_version-$forge_version/forge-$mc_version-$forge_version-installer.jar"
            local installer_jar="$temp_dir/forge-installer.jar"
            
            if ! download_with_retry "$download_url" "$installer_jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Forge installer."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installing Forge server (this may take a while)..."
            java -jar "$installer_jar" --installServer >/dev/null 2>&1 &
            spinner $!
            
            # Find the forge jar
            local forge_jar
            forge_jar=$(find . -name "forge-$mc_version-$forge_version*.jar" | grep -v installer | head -1)
            
            if [ -z "$forge_jar" ]; then
                echo -e "${BOLD_RED}${CROSS_MARK} Failed to find Forge server jar${RESET}"
                rm -rf "$temp_dir"
                return 1
            fi
            
            # Rename to server.jar
            cp "$forge_jar" "server.jar"
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Forge server installed successfully!"
            echo "forge" > .server-type
            ;;
            
        "fabric")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Fabric installer..."
            
            # Download Fabric installer
            local fabric_version="0.15.7"
            local installer_jar="$temp_dir/fabric-installer.jar"
            local download_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer/$fabric_version/fabric-installer-$fabric_version.jar"
            
            if ! download_with_retry "$download_url" "$installer_jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Fabric installer."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installing Fabric server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            java -jar "$installer_jar" server -mcversion "$mc_version" -downloadMinecraft >/dev/null 2>&1 &
            spinner $!
            
            if [ -f "fabric-server-launch.jar" ]; then
                # Rename to server.jar
                cp "fabric-server-launch.jar" "server.jar"
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Fabric server installed successfully!"
            else
                echo -e "${BOLD_RED}${CROSS_MARK} Failed to install Fabric server${RESET}"
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo "fabric" > .server-type
            ;;
            
        "sponge")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.16.5"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Sponge server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            local download_url="https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/$mc_version-8.0.0/spongevanilla-$mc_version-8.0.0.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Sponge server jar."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Sponge server downloaded successfully!"
            echo "sponge" > .server-type
            ;;
            
        "bungeecord")
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading latest BungeeCord server..."
            
            local download_url="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download BungeeCord server jar."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}BungeeCord server downloaded successfully!"
            echo "bungeecord" > .server-type
            ;;
            
        "velocity")
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading latest Velocity server..."
            
            local download_url="https://api.papermc.io/v2/projects/velocity/versions/3.2.0-SNAPSHOT/builds/263/downloads/velocity-3.2.0-SNAPSHOT-263.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Velocity server jar."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Velocity server downloaded successfully!"
            echo "velocity" > .server-type
            ;;
            
        "purpur")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Purpur server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            local download_url="https://api.purpurmc.org/v2/purpur/$mc_version/latest/download"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Purpur server jar."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Purpur server downloaded successfully!"
            echo "purpur" > .server-type
            ;;
            
        *)
            echo -e "${BOLD_RED}${CROSS_MARK} Unsupported server type: $server_type${RESET}"
            rm -rf "$temp_dir"
            return 1
            ;;
    esac
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    echo -e "${BOLD_GREEN}${ROCKET} Server software installed successfully! ${ROCKET}${RESET}"
    return 0
}

# Function to configure server properties
configure_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Configuration"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Configuring ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Ask about cracked mode
    local online_mode="true"
    if get_yes_no "Enable cracked mode (allows non-premium Minecraft accounts)?" "n"; then
        online_mode="false"
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Cracked mode enabled (online-mode=false)"
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Premium mode enabled (online-mode=true)"
    fi
    
    # Create server.properties for Minecraft servers
    if [[ "$server_type" != "bungeecord" && "$server_type" != "velocity" ]]; then
        if [ ! -f "server.properties" ]; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating server.properties file..."
            
            # Get server port
            local port=${SERVER_PORT:-$DEFAULT_PORT}
            
            cat > server.properties << EOL
#Minecraft server properties
#Generated by Czaractyl Server Manager
#$(date)
server-port=${port}
motd=\\u00A7b\\u00A7lCzaractyl \\u00A78| \\u00A7fMade by Arpit for Czar
enable-command-block=true
spawn-protection=0
view-distance=10
simulation-distance=10
max-players=20
online-mode=${online_mode}
allow-flight=true
white-list=false
difficulty=normal
gamemode=survival
EOL
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}server.properties created successfully!"
        else
            echo -e "  ${BOLD_BLUE}${ARROW} ${RESET}Updating existing server.properties..."
            # Update online-mode in existing server.properties
            sed -i "s/online-mode=.*/online-mode=${online_mode}/" server.properties
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}server.properties updated successfully!"
        fi
    fi
    
    # Create config for BungeeCord
    if [ "$server_type" == "bungeecord" ] && [ ! -f "config.yml" ]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating BungeeCord configuration..."
        
        # Get server port
        local port=${SERVER_PORT:-$DEFAULT_PORT}
        
        cat > config.yml << EOL
server_connect_timeout: 5000
listeners:
- query_port: 25577
  motd: '&b&lCzaractyl &8| &fMade by Arpit for Czar'
  tab_list: GLOBAL_PING
  query_enabled: false
  proxy_protocol: false
  forced_hosts:
    pvp.md-5.net: pvp
  ping_passthrough: false
  priorities:
  - lobby
  bind_local_address: true
  host: 0.0.0.0:${port}
  max_players: 500
  tab_size: 60
  force_default_server: false
online_mode: ${online_mode}
EOL
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}BungeeCord config.yml created successfully!"
    fi
    
    # Accept EULA
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Accepting Minecraft EULA..."
    echo "eula=true" > eula.txt
    echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}EULA accepted!"
    
    echo -e "${BOLD_GREEN}${GEAR} Server configured successfully! ${GEAR}${RESET}"
    return 0
}

# Function to start the server
start_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Startup"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Starting ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Set memory allocation
    if [ -z "$MEMORY" ]; then
        MEMORY="$DEFAULT_MEMORY"
    fi
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Memory allocation: ${BOLD_CYAN}${MEMORY}${RESET}"
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using optimized startup flags"
    
    # Start the server based on type
    case $server_type in
        "paper"|"purpur"|"sponge")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            ;;
        "forge")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching Forge server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            ;;
        "fabric")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching Fabric server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            ;;
        "bungeecord"|"velocity")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching proxy server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} -jar server.jar${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY -jar server.jar
            ;;
        *)
            echo -e "${BOLD_RED}${CROSS_MARK} Unknown server type: $server_type${RESET}"
            return 1
            ;;
    esac
    
    return 0
}

# Function to handle server selection and installation
select_and_install_server() {
    # Display server type selection menu
    server_options=(
        "${GREEN}Paper${RESET} - High performance fork with plugin support (Recommended)"
        "${YELLOW}Forge${RESET} - For modded Minecraft"
        "${BLUE}Fabric${RESET} - Lightweight, modular mod loader"
        "${PURPLE}Purpur${RESET} - Fork of Paper with additional features"
        "${CYAN}BungeeCord${RESET} - Proxy server for connecting multiple servers"
        "${BLUE}Velocity${RESET} - Modern, high-performance proxy server"
        "${RED}Sponge${RESET} - Plugin API for Minecraft"
    )
    
    display_menu "Select Server Software" "${server_options[@]}"
    read -r choice
    
    case $choice in
        1) server_type="paper";;
        2) server_type="forge";;
        3) server_type="fabric";;
        4) server_type="purpur";;
        5) server_type="bungeecord";;
        6) server_type="velocity";;
        7) server_type="sponge";;
        *) 
            echo -e "${BOLD_RED}${CROSS_MARK} Invalid choice. Defaulting to Paper.${RESET}"
            sleep 2
            server_type="paper"
            ;;
    esac
    
    # Get Minecraft version
    mc_version=$(get_input "Enter Minecraft version (e.g., 1.20.4) or press Enter for latest" "$DEFAULT_MC_VERSION")
    
    # Install server
    if ! install_server "$server_type" "$mc_version"; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Server installation failed. Please check the logs above."
        return 1
    fi
    
    # Configure server
    configure_server
    
    # Ask to start server
    if get_yes_no "Start the server now?" "y"; then
        start_server
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Server setup completed. Run the script again to start the server."
    fi
    
    return 0
}

# Main function
main() {
    # Display banner
    show_banner
    
    # Setup Java
    setup_java
    
    # Check if server is already installed
    if [ -f ".server-type" ]; then
        local server_type
        server_type=$(cat .server-type 2>/dev/null || echo "unknown")
        
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Found existing ${BOLD_CYAN}${server_type^}${RESET} server installation."
        
        # Display main menu
        main_options=(
            "${GREEN}Start Server${RESET} - Launch the existing server"
            "${YELLOW}Reinstall Server${RESET} - Change server software or version"
            "${BLUE}Server Settings${RESET} - Configure server properties"
            "${RED}Exit${RESET} - Exit without starting the server"
        )
        
        display_menu "Main Menu" "${main_options[@]}"
        read -r choice
        
        case $choice in
            1) # Start server
                configure_server
                start_server
                ;;
            2) # Reinstall server
                select_and_install_server
                ;;
            3) # Server settings
                configure_server
                if get_yes_no "Start the server now?" "y"; then
                    start_server
                fi
                ;;
            4) # Exit
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Exiting Czaractyl Server Manager. Goodbye!"
                exit 0
                ;;
            *) # Invalid choice
                echo -e "${BOLD_RED}${CROSS_MARK} Invalid choice. Starting server with current configuration.${RESET}"
                sleep 2
                start_server
                ;;
        esac
    else
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}No server installation found. Let's set up a new server!"
        select_and_install_server
    fi
}

# Execute main function
main
