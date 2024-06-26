![image](https://github.com/MikeHorn-git/RouterOS-Hardening/assets/123373126/fec74d01-aa82-46ff-85dd-4059cb4ba272)

# Warning
Read a script before running it.

# Description
This script is designed to harden your RouterOS device by disabling unnecessary services, enhancing security settings, and configuring logging. The script follow best practices from the [Securing your router](https://help.mikrotik.com/docs/display/ROS/Securing+your+router) section of MikroTik documentation and a [Manito Networks blog](https://www.manitonetworks.com/networking/2017/7/25/mikrotik-router-hardening) post.

# Installation
```bash
/tool fetch url="https://raw.githubusercontent.com/MikeHorn-git/RouterOS-Hardening/main/hardening.rsc" mode=https
/import file-name=hardened.rsc
```

# Features
* Update System Packages [Optional] (Need a valid license)
* Create new user hardened (Need to change password, the temporary password is hardened)
* Disable admin user
* Disable Unnecessary Services (API, FTP, IP Cloud, Telnet, Proxy, SOCKS, UPNP, WWW, WWW-SSL)
* Disable MAC Server (Ping, Server, Winbox)
* Disable Bandwidth Server
* Disable DNS Cache 
* Disable Neighbor Discovery
* Disable IPv6 Neighbor Discovery
* Disable Router Management Overlay Network (ROMON)
* Enable Reverse Path Filtering (RPF)
* Enable Stronger SSH Crypto
* Configure Logging to Disk
* Configure NTP
* Change SSH Port (2200)
* Disable LCD Module [Optional] (Need a compatible RouterBoard)
* Build a Firewall [Partially]
* Create Configuration Backup

# Recommendations
This part cannot be done automatically.
* Firewall Configuration [Partially]
* Backup Strategy
* Change credentials
* Monitor Log File Size
