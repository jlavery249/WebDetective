#!/bin/bash

# Function to display the Figlet banner
display_banner() {
    # Get a list of fonts in the figlet directory
    fonts=(/usr/share/figlet/*.flf)

    # Select a random font from the list
    random_font="${fonts[RANDOM % ${#fonts[@]}]}"

    # Get the font name from the path
    font_name=$(basename "$random_font" .flf)

    # Print a message using the random font
    figlet -f "$random_font" "WebDetective" | sed "1s/.*/Using Font: $font_name/" | /usr/games/lolcat
    echo -e "Version: v1.0b\nCreated by: John Lavery" | /usr/games/lolcat
}

# Call the banner function to display it
display_banner

# Constants
DEFAULT_WORDLIST="/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt"
WORDLISTS=(
    "$DEFAULT_WORDLIST"
    "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    "/usr/share/seclists/Discovery/Web-Content/big.txt"
    "/usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt"
)
OUTPUT_DIR_PREFIX="scans"
proxy=""
target=""

# Help function
show_help() {
    echo "Usage: sudo $0 [-A | -n | -W | -d | -g | -f | -N] -i <ip_address/domain> -p <proxy_ip:proxyport>"
    echo "Run various web vulnerability scans on the specified IP address or domain."
    echo "Options:"
    echo "  -A: Run all scans in order (Nmap SYN, WhatWeb, Nikto, dirsearch, Gobuster, FFuf, Nmap aggressive)"
    echo "  -n: Run Nikto scan"
    echo "  -W: Run WhatWeb scan"
    echo "  -d: Run dirsearch scan"
    echo "  -g: Run Gobuster scan"
    echo "  -f: Run FFuf scan"
    echo "  -N: Run both nmap scans"
    echo "  -p <proxy_ip:proxyport>: Specifies a proxy with the selected options"
    echo "  -i <ip_address/domain>: Specifies the target IP address or domain"
    echo ""
    echo "Examples:"
    echo "  sudo $0 -A -i example.com"
    echo "  sudo $0 -n -i 192.168.1.100"
    echo "  sudo $0 -WNgfn -i example.com"
    echo "  sudo $0 -A -i example.com -p 127.0.0.1:8080"
    echo "  sudo $0 -f -i 192.168.1.100 -p 127.0.0.1:8080"
}

# Parse command-line options
while getopts "AnWdgfNp:i:h" opt; do
    case ${opt} in
        A ) run_all=true ;;
        n ) run_nikto=true ;;
        W ) run_whatweb=true ;;
        d ) run_dirsearch=true ;;
        g ) run_gobuster=true ;;
        f ) run_ffuf=true ;;
        N ) run_nmap=true ;;
        p ) proxy=$OPTARG ;;
        i ) target=$OPTARG ;;
        h ) show_help; exit 0 ;;
        : ) echo "Error: Option -$OPTARG requires an argument" >&2; show_help >&2; exit 1 ;;
        \? ) echo "Error: Invalid option -$OPTARG" >&2; show_help >&2; exit 1 ;;
    esac
done
shift $((OPTIND -1))

# Check if no IP address or domain provided
if [ -z "$target" ]; then
    echo "Error: No IP address/domain provided."
    show_help
    exit 1
fi

# Determine the output directory based on the target
output_dir="scans_${target}"

# Create output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
    mkdir "$output_dir"
fi

# Main script logic
# Check if script is run as sudo
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root (sudo)." >&2
    exit 1
fi

# Function to check dependencies
check_dependencies() {
    local missing_tools=()
    for tool in dirsearch nikto nmap whatweb gobuster ffuf; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Error: The following tools are missing or not installed: ${missing_tools[*]}"
        echo "Please install them before running the script."
        exit 1
    fi
}

# Function to run Nikto scan
run_nikto_scan() {
    if [ -n "$proxy" ]; then
        echo "Running Nikto on $target using proxy $proxy..."
        echo "n" | nikto -h "$target" -useproxy "http://$proxy" | tee "$output_dir/nikto_scan_proxy.txt"
    else
        echo "Running Nikto on $target..."
        echo "n" | nikto -h "$target" | tee "$output_dir/nikto_scan.txt"
    fi
}

# Function to run WhatWeb scan
run_whatweb_scan() {
    if [ -n "$proxy" ]; then
        echo "Running Whatweb on $target using proxy $proxy..."
        whatweb "http://$target" --proxy "$proxy" | tee "$output_dir/whatweb_scan_proxy.txt"
    else
        echo "Running WhatWeb on http://$target..."
        whatweb "http://$target" | tee "$output_dir/whatweb_scan.txt"
    fi
}

# Function to run dirsearch
run_dirsearch_scan() {
    if [ -n "$proxy" ]; then
        echo "Running dirsearch on $target using proxy $proxy..."
        dirsearch -u "$target" --proxy="http://$proxy"
        echo "Directory enumeration complete."
    else
        echo "Running directory enumeration using dirsearch..."
        dirsearch -u "$target"
        echo "Directory enumeration complete."
    fi
}

# Function to run Gobuster scan
run_gobuster_scan() {
    if [ -n "$proxy" ]; then
        echo "Adding proxy temporarily to environmental path..."
        # Backup the current HTTP_PROXY value
        backup_http_proxy="$HTTP_PROXY"

        # Set the HTTP_PROXY environment variable temporarily
        export HTTP_PROXY="$proxy"

        echo "Running Gobuster for directory discovery with proxy $proxy..."
        for wordlist in "${WORDLISTS[@]}"; do
            gobuster dir -u "http://$target" -w "$wordlist" | tee "$output_dir/gobuster_scan_${wordlist##*/}.txt"
        done

        # Revert back to the original HTTP_PROXY value
        export HTTP_PROXY="$backup_http_proxy"
        echo "Reverting proxy back to original environmental path."
    else
        echo "Running Gobuster for directory discovery..."
        for wordlist in "${WORDLISTS[@]}"; do
            gobuster dir -u "http://$target" -w "$wordlist" | tee "$output_dir/gobuster_scan_${wordlist##*/}.txt"
        done
    fi
}

# Function to run FFuf scan
run_ffuf_scan() {
    if [ -n "$proxy" ]; then
        echo "Running FFuf with proxy for dir/file discovery..."
        for wordlist in "${WORDLISTS[@]}"; do
            ffuf -u "http://$target/FUZZ" -w "$wordlist" -c -v -replay-proxy "http://$proxy" | tee "$output_dir/ffuf_scan_${wordlist##*/}.txt"
        done
    else
        echo "Running FFuf for dir/file discovery..."
        for wordlist in "${WORDLISTS[@]}"; do
            ffuf -u "http://$target/FUZZ" -w "$wordlist" -c -v | tee "$output_dir/ffuf_scan_${wordlist##*/}.txt"
        done
    fi
}

# Function to run nmap SYN scan
run_nmap_syn_scan() {
    echo "Running nmap SYN scan on $target..."
    nmap -sS -sV -vv "$target" | tee "$output_dir/nmap_syn_scan.txt"
}

# Function to run nmap aggressive scan
run_nmap_aggressive_scan() {
    echo "Running nmap aggressive scan on $target..."
    nmap -T4 -A -vv "$target" | tee "$output_dir/nmap_aggressive_scan.txt"
}

# Function to check dependencies
check_dependencies() {
    local missing_tools=()
    for tool in dirsearch nikto nmap whatweb gobuster ffuf; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Error: The following tools are missing or not installed: ${missing_tools[*]}"
        echo "Please install them before running the script."
        exit 1
    fi
}

# Main script execution

# Check if dependencies are installed
check_dependencies

# Run all scans if -A option is specified
if [ "$run_all" = true ]; then
    run_nmap_syn_scan
    run_whatweb_scan
    run_nikto_scan
    run_dirsearch_scan
    run_gobuster_scan
    run_ffuf_scan
    run_nmap_aggressive_scan
else
    # Run individual scans based on selected options
    if [ "$run_nikto" = true ]; then
        run_nikto_scan
    fi

    if [ "$run_whatweb" = true ]; then
        run_whatweb_scan
    fi

    if [ "$run_dirsearch" = true ]; then
        run_dirsearch_scan
    fi

    if [ "$run_gobuster" = true ]; then
        run_gobuster_scan
    fi

    if [ "$run_ffuf" = true ]; then
        run_ffuf_scan
    fi

    if [ "$run_nmap" = true ]; then
        run_nmap_syn_scan
        run_nmap_aggressive_scan
    fi
fi

# Display completion message
echo "WebDetective scans completed."
