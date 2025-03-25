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
VERSION="2.0.0"
CODENAME="Inferno"

# Default settings
DEFAULT_MEMORY="2G"
DEFAULT_PORT="25565"
DEFAULT_MC_VERSION="1.20.4"

# Plugin URLs
CHUNKY_URL="https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar"
MEMORY_REST_URL="https://cdn.modrinth.com/data/BETNSd2r/versions/n8DhYGER/LetUrMemoryRest-4.0.jar"
MEMORY_LEAK_FIX_URL="https://www.spigotmc.org/resources/memoryleakfix-1-18-1-20-x.117491/download?version=546137"

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
LIGHTNING="⚡"
CROWN="👑"
SPARKLES="✨"
HEART="❤️"
SKULL="💀"
DRAGON="🐉"
SWORD="⚔️"
SHIELD="🛡️"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ ERROR HANDLING                                                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Set up error handling
set -o pipefail

# Error handling function
handle_error() {
    local exit_code=$1
    local error_line=$2
    local error_command=$3
    
    echo -e "\n${BOLD_RED}${SKULL} ERROR: Command '${error_command}' failed with exit code ${exit_code} at line ${error_line}${RESET}"
    echo -e "${BOLD_YELLOW}The script encountered an error. Please check the output above for details.${RESET}"
    
    # Clean up any temporary files or processes
    cleanup
    
    # Exit with error code
    exit $exit_code
}

# Set up trap for errors
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Cleanup function
cleanup() {
    # Kill any background processes
    if [ -f .spinner.pid ]; then
        kill $(cat .spinner.pid) > /dev/null 2>&1 || true
        rm .spinner.pid
    fi
    
    # Remove temporary files
    rm -f .temp_* 2>/dev/null || true
}

# Set up trap for script exit
trap cleanup EXIT

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
    local icon="${3:-}"
    
    echo
    print_line "═" "$color"
    if [ -n "$icon" ]; then
        print_centered "$icon $title $icon" "$color"
    else
        print_centered "$title" "$color"
    fi
    print_line "═" "$color"
    echo
}

# Function to display a spinner animation
spinner() {
    local message="$1"
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while true; do
        for ((i=0; i<${#spinstr}; i++)); do
            echo -ne "\r$message [${spinstr:$i:1}]"
            sleep $delay
        done
    done
}

# Function to start spinner in background
start_spinner() {
    local message="$1"
    spinner "$message" &
    echo $! > .spinner.pid
}

# Function to stop spinner
stop_spinner() {
    if [ -f .spinner.pid ]; then
        kill $(cat .spinner.pid) > /dev/null 2>&1 || true
        rm .spinner.pid
    fi
    echo -e "\r\033[K"
}

# Function to display a fancy box with text
fancy_box() {
    local text="$1"
    local color="${2:-$BOLD_CYAN}"
    local width=$(tput cols 2>/dev/null || echo 80)
    local text_width=${#text}
    local padding=$(( (width - text_width - 4) / 2 ))
    
    echo -ne "$color"
    printf "%${width}s" | tr " " "═"
    echo -e "$RESET"
    
    echo -ne "$color║$RESET"
    printf "%${padding}s" ""
    echo -ne "$text"
    printf "%$(( width - padding - text_width - 2 ))s" ""
    echo -e "$color║$RESET"
    
    echo -ne "$color"
    printf "%${width}s" | tr " " "═"
    echo -e "$RESET"
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
    local max_retries=5
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading: ${BOLD_CYAN}$(basename "$output_file")${RESET}"
        start_spinner "Downloading"
        
        if curl -s -L -o "$output_file" "$url"; then
            stop_spinner
            # Verify the file was downloaded and is not empty
            if [ -s "$output_file" ]; then
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Downloaded successfully: ${BOLD_CYAN}$(basename "$output_file")${RESET}"
                return 0
            else
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Downloaded file is empty. Retrying..."
            fi
        else
            stop_spinner
            echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Download failed. Retrying..."
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Retry attempt ($retry_count/$max_retries)..."
            sleep 2
        else
            stop_spinner
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
██╔════╝╚███╔═╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║      ╚███╔╝███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔═╝██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
    echo -e "${RESET}"
    
    echo -e "${BOLD_RED}"
    cat << "EOF"
                                 /|
                                / |
                               /__|______
                              |  __  __  |
                              | |  ||  | |
                              | |__||__| |
                              |  __  __()| 
                              | |  ||  | |
                              | |__||__| |
                              |__________|
EOF
    echo -e "${RESET}"
    
    print_centered "${FIRE} ULTIMATE SERVER MANAGER ${FIRE}" "$BOLD_YELLOW"
    print_centered "Version ${VERSION} - ${CODENAME}" "$BOLD_WHITE"
    print_centered "Made by Arpit for Czar" "$BOLD_PURPLE"
    print_line "═" "$BOLD_CYAN"
    echo
}

# Function to detect Java version
setup_java() {
    print_header "Java Configuration" "$BOLD_CYAN" "$GEAR"
    
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
        "-Dusing.aikars.flags=https://mcflags.emc.gs"
        "-Daikars.new.flags=true"
    )
}

# Function to download and install server software
install_server() {
    local server_type="paper"
    local mc_version="$DEFAULT_MC_VERSION"
    
    print_header "Installing ${server_type^} Server" "$BOLD_CYAN" "$ROCKET"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Preparing to install ${BOLD_CYAN}${server_type^}${RESET} server (Minecraft ${BOLD_CYAN}${mc_version}${RESET})..."
    
    # Save the Minecraft version for plugin compatibility
    echo "$mc_version" > .mc-version
    
    # Create temporary directory for downloads
    local temp_dir=".czar_temp"
    mkdir -p "$temp_dir"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Paper server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
    
    # Try direct download first
    local download_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/latest/downloads/paper-$mc_version-latest.jar"
    
    if ! download_with_retry "$download_url" "server.jar"; then
        # Try alternative method - get build info first
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Direct download failed. Trying alternative method..."
        
        # Get latest build info
        local build_info
        if build_info=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds"); then
            # Extract latest build number
            local latest_build
            latest_build=$(echo "$build_info" | grep -o '"build":[0-9]*' | grep -o '[0-9]*' | tail -1)
            
            if [ -n "$latest_build" ]; then
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Found build: ${BOLD_CYAN}#${latest_build}${RESET}"
                
                # Construct download URL with specific build number
                local specific_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/$latest_build/downloads/paper-$mc_version-$latest_build.jar"
                
                if ! download_with_retry "$specific_url" "server.jar"; then
                    echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Paper server jar."
                    rm -rf "$temp_dir"
                    return 1
                fi
            else
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to parse build information."
                rm -rf "$temp_dir"
                return 1
            fi
        else
            echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to get build information."
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Paper server jar downloaded successfully!"
    echo "paper" > .server-type
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    fancy_box "${SPARKLES} Server software installed successfully! ${SPARKLES}" "$BOLD_GREEN"
    return 0
}

# Function to download plugins
download_plugins() {
    print_header "Downloading Performance Plugins" "$BOLD_CYAN" "$LIGHTNING"
    
    # Create plugins directory if it doesn't exist
    mkdir -p plugins
    
    # Download Chunky plugin
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Chunky plugin..."
    if ! download_with_retry "$CHUNKY_URL" "plugins/Chunky-Bukkit-1.4.28.jar"; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Chunky plugin."
    fi
    
    # Download LetUrMemoryRest plugin
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading LetUrMemoryRest plugin..."
    if ! download_with_retry "$MEMORY_REST_URL" "plugins/LetUrMemoryRest-4.0.jar"; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download LetUrMemoryRest plugin."
    fi
    
    # Download MemoryLeakFix plugin
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading MemoryLeakFix plugin..."
    if ! download_with_retry "$MEMORY_LEAK_FIX_URL" "plugins/MemoryLeakFix.jar"; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download MemoryLeakFix plugin."
    fi
    
    fancy_box "${SPARKLES} Performance plugins downloaded successfully! ${SPARKLES}" "$BOLD_GREEN"
    return 0
}

# Function to configure server properties
configure_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Configuration" "$BOLD_CYAN" "$GEAR"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Configuring ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Ask about cracked mode
    local online_mode="true"
    if get_yes_no "Are you using cracked Minecraft? (This will allow non-premium accounts)" "n"; then
        online_mode="false"
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Cracked mode enabled (online-mode=false)"
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Premium mode enabled (online-mode=true)"
    fi
    
    # Create server.properties
    if [ ! -f "server.properties" ]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating server.properties file..."
        
        # Get server port
        local port=${SERVER_PORT:-$DEFAULT_PORT}
        
        cat > server.properties << EOL
#Minecraft server properties
#Generated by Czaractyl Server Manager
#$(date)
server-port=${port}
motd=\\u00A7c\\u00A7l\\u00A7nCzaractyl\\u00A7r \\u00A78| \\u00A7d\\u00A7lMade by Arpit for Czar
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
    
    # Accept EULA
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Accepting Minecraft EULA..."
    echo "eula=true" > eula.txt
    echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}EULA accepted!"
    
    fancy_box "${SPARKLES} Server configured successfully! ${SPARKLES}" "$BOLD_GREEN"
    return 0
}

# Function to start the server
start_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Startup" "$BOLD_CYAN" "$ROCKET"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Starting ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Set memory allocation
    if [ -z "$MEMORY" ]; then
        MEMORY="$DEFAULT_MEMORY"
    fi
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Memory allocation: ${BOLD_CYAN}${MEMORY}${RESET}"
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using optimized startup flags"
    
    # Start the server
    echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching server with command:"
    echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
    echo
    java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
    
    return 0
}

# Main function
main() {
    # Display banner
    show_banner
    
    # Setup Java
    setup_java
    
    # Ask to start
    if get_yes_no "Do you want to start the server?" "y"; then
        # Check if server is already installed
        if [ -f "server.jar" ]; then
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Found existing server installation."
        else
            # Install server
            if ! install_server; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Server installation failed. Please check the logs above."
                exit 1
            fi
        fi
        
        # Download plugins
        download_plugins
        
        # Configure server
        configure_server
        
        # Start server
        start_server
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Exiting Czaractyl Server Manager. Goodbye!"
        exit 0
    fi
}

# Execute main function
main
