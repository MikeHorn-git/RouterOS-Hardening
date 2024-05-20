![image](https://github.com/MikeHorn-git/RouterOS-Hardening/assets/123373126/46da4a61-63f5-4357-be4d-7cce3392db1d)

# Warning
Read a script before running it.

# Description
This script is designed to harden your RouterOS device by disabling unnecessary services, enhancing security settings, and configuring logging. The script follow best practices from the [Securing your router](https://help.mikrotik.com/docs/display/ROS/Securing+your+router) section of MikroTik documentation and [this](https://www.manitonetworks.com/networking/2017/7/25/mikrotik-router-hardening#credentials) blog post.

# Installation
```bash
/tool fetch url="https://raw.githubusercontent.com/MikeHorn-git/RouterOS-Hardening/main/hardening.rsc" mode=https
/import file-name=hardened.rsc
```

# Features
* Update System Packages [Optional] (Need a valid license)
* Disable Unnecessary Services (API, FTP, IP Cloud, Telnet, Proxy, SOCKS, UPNP, WWW, WWW-SSL)
* Disable MAC Server (Ping, Server, Winbox)
* Disable Bandwidth Server
* Disable DNS Cache 
* Disable Neighbor Discovery
* Disable IPv6 Neighbor Discovery
* Disable Router Management Overlay Network (ROMON)
* Enable Reverse Path Filtering (RPF)
* Enable Stronger SSH Crypto
* Configure NTP
* Change SSH Port (2200)
* Disable LCD Module [Optional] (Need a compatible RouterBoard)
* Configure Logging to Disk
* Create Configuration Backup

# Recommendations
This part cannot be done automatically.
* Firewall Configuration
* Backup Strategy
* Change Credentials / Users
* Monitor Log File Size
