# WebDetective

WebDetective is a Bash script designed to perform various web vulnerability scans on specified IP addresses or domains. It automates the process of running scans such as Nmap SYN scan, WhatWeb, Nikto, dirsearch, Gobuster, FFuf, and Nmap aggressive scan, providing a comprehensive assessment of potential vulnerabilities in web applications.

https://github.com/jlavery249/WebDetective/assets/121765789/d7a38e4d-623d-485f-b55c-f380372f964d

## Features

- Automated web vulnerability scans
- Customizable with different scan options
- Can route all tools through proxy (tested with Burpsuite Pro)
- Suitable for security testing and vulnerability assessment

## Prerequisites

Before using WebDetective, ensure you have the following packages installed:

- `dirsearch`: For directory enumeration (install using `sudo apt install dirsearch`)
- `nikto`: For running Nikto scans (install using `sudo apt install nikto`)
- `nmap`: For Nmap SYN scan and aggressive scan (install using `sudo apt install nmap`)
- `whatweb`: For WhatWeb scans (install using `sudo apt install whatweb`)
- `gobuster`: For Gobuster scans (install using `sudo apt install gobuster`)
- `ffuf`: For FFuf scans (install using `sudo apt install ffuf`)
- `figlet`: For displaying the banner (install using `sudo apt install figlet`)
- `lolcat`: For colorful output (install using `sudo apt install lolcat`)

## Usage

To run WebDetective, use the following command format:

```bash
sudo ./webdetective.sh [options] -i <ip_address/domain>
```

Options:
- `-A`: Run all scans in order (Nmap SYN, WhatWeb, Nikto, dirsearch, Gobuster, FFuf, Nmap aggressive)
- `-n`: Run Nikto scan
- `-W`: Run WhatWeb scan
- `-d`: Run dirsearch scan
- `-g`: Run Gobuster scan
- `-f`: Run FFuf scan
- `-N`: Run both nmap scans
- `-l <ip_list_file>`: Specify a file containing a list of IPs or domains
- `-w <custom_wordlist>`: Specify a custom wordlist file

Examples:
- Run all scans on a single target:
  ```bash
  sudo ./webdetective.sh -A -i 192.168.1.100
  ```
- Run Nikto scan on a domain:
  ```bash
  sudo ./webdetective.sh -n -i example.com
  ```
- Run scans on multiple targets from a list file:
  ```bash
  sudo ./webdetective.sh -A -l /path/to/ip_list.txt
  ```
# Future Improvements
- Adding Burp Suite proxy functionality
- Future conversion to Python3 for improved performance and compatibility
- Additional user-friendly features such as package checks, interactive mode, etc.
- Allow multiple combination of switches to be used

# Current Bugs 
- Issue with the lolcat command not found in some environments, needs to be installed manually and path needs to be manually hardcoded into the script.


## Disclaimer

This is an alpha version of the script, use it at your own risk. Things may be broken and features will improve as this project progresses. I am not responsible for any damage or misuse. Ensure that this script is used against an environment that has provided permission for security testing or in an isolated/test environment.

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
