# WebDetective

WebDetective is a Bash script designed to perform various web vulnerability scans on specified IP addresses or domains. It automates the process of running scans such as Nmap SYN scan, WhatWeb, Nikto, dirsearch, Gobuster, FFuf, and Nmap aggressive scan, providing a comprehensive assessment of potential vulnerabilities in web applications.

https://github.com/jlavery249/WebDetective/assets/121765789/d7a38e4d-623d-485f-b55c-f380372f964d

## Features

- Automated web vulnerability scans
- Customizable with different scan options
- Supports custom wordlists for directory and file enumeration
- Suitable for security testing and vulnerability assessment
- Can route all tools through proxy (tested with Burpsuite Pro)

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
- `Proxy`: For routing traffic through proxy (optional)

## Usage

To run WebDetective, use the following command format:

```bash
sudo ./webdetective.sh [options] -i <ip_address/domain> -p <proxy_ip:proxyport>
```

## Options:

  - `-A`: Run all scans in order (Nmap SYN, WhatWeb, Nikto, dirsearch, Gobuster, FFuf, Nmap aggressive)
  - `-n`: Run Nikto scan
  - `-W`: Run WhatWeb scan
  - `-d`: Run dirsearch scan
  - `-g`: Run Gobuster scan
  - `-f`: Run FFuf scan
  - `-N`: Run both nmap scans
  - `-p`: Specifies a proxy with the selected options
  - `-i`: Specifies the target IP address or doma
  

## Examples:
- Run all scans on a domain:
  ```bash
  sudo ./webdetective.sh -A -i example.com
  ```
- Run Nikto scan on a single target:
  ```bash
  sudo ./webdetective.sh -n -i 192.168.1.100
  ```
- Run scans on multiple options together:
  ```bash
  sudo ./WebDetective.sh -WNgfn -i example.com
  ```
- Run all scans through proxy
  ```bash
  sudo ./WebDetective.sh -A -i example.com -p 127.0.0.1:8080
  ```
- Run single option through proxy
  ```bash
  sudo ./WebDetective.sh -f -i 192.168.1.100 -p 127.0.0.1:8080
  ```
  
# Future Improvements
- Future conversion to Python3 for improved performance and compatibility
- Additional user-friendly features such as package checks, interactive mode, etc.
- Implement file with a list of domains or IPs to allow multiple targets

# Current Bugs 
- Issue with the lolcat command not found in some environments, needs to be installed manually and path needs to be manually hardcoded into the script
- It is recommended to use the address `127.0.0.1` with the proxy feature (`-p`), things may break if you use `localhost:8080` as an example


## Disclaimer

This is the beta version of the script, although it may be more stable than the previous release, still use it at your own risk. Things may be broken and features will improve as this project progresses. I am not responsible for any damage or misuse. Ensure that this script is used against an environment that has provided permission for security testing or in an isolated/test environment.

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
