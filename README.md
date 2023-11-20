# Reverse DNS scanner (bash/powershell scripts)
## Overview
Welcome to the ReverseDNSScaner Repository! This set of scripts provides a convenient solution for scanning networks using reverse DNS lookups. You can use these scripts when examining the segment being tested, provided that reverse DNS queries are enabled.
The main advantage is that the scripts use native methods and do not require the installation of additional utilities (powershell for Windows, bash for Linux).

You can use this script directly on the infected machine, without installing additional software, unlike in dnsrecon and hakrevdns.

## Usage
### bash
```
Usage: ./reversednsscan.sh <ipaddress> <mask> [OPTIONS]
Options:
 -h --help      Display this help message
 -s --server    Specify a dns server address
 -o --output    Save output to file
 -d --debug     Enable debug mode

For example:
./reversednsscan.sh 10.10.10.10 30
./reversednsscan.sh 192.168.1.0 24 -s 192.168.1.1 -f output.txt
```

***output:***

![2023-11-18_00-57](https://github.com/sergo2048/reversednsscaner/assets/40056618/b71b9aa2-a575-44ff-9319-9efbc11a9f6b)


### powershell
**params:**
-ip - address from the subnet to scan (default value is network interface address)
-mask - subnet mask for scanning (default value is network interface mask)
-server - dns server address (default value is default dns server ip)

**usage:**
You can use the utility as a powershell script 
```powershell
.\reversednsscan.ps1 -ip 10.10.10.10 -mask 23 -server 10.10.10.1
```

```powershell
.\reversednsscan.ps1 -mask 24
```

*Example output*
![2023-11-20_15-22](https://github.com/3eVeHbIu/reversednsscaner/assets/40056618/7643b22a-64e1-489f-a155-3b15f8355850)

or as a powershell module:
```powershell
Import-Module .\reversednsscan.ps1
```

then the ReverseDNSQuery and Scan-ReserseDNS functions will become available to you.

* ReverseDNSQuery sends a reverse DNS request to the server
* Scan-ReserseDNS scans the network in the same way as the reversednsscan script

**usage:**
```powershell
Scan-ReserseDNS -mask 24
```

```powershell
Scan-ReserseDNS -ip 10.10.10.10 -mask 25
```

```powershell
ReverseDNSQuery -ip 8.8.8.8 -server 8.8.8.8
```

*Example output*
![2023-11-20_15-23](https://github.com/3eVeHbIu/reversednsscaner/assets/40056618/3c057d27-3b49-41c7-a84c-11accd8a31fa)


## Issues and Support
If you encounter any issues or have questions, please open an issue on the GitHub repository. We'll do our best to assist you.

Happy scanning! 🌐✨
