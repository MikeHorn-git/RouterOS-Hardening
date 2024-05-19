#!rsc by RouterOS
# RouterOS script: hardened
# Copyright (c) 2024 MikeHorn-git
# https://github.com/MikeHorn-git/RouterOS-Hardening/blob/main/LICENSE
# Tested on RouterOS 7.15rc3

:put "[+] Update system"
/system package update check-for-updates
/system package update install

:put "[+] Disable api service"
/ip service disable [find name=api]

:put "[+] Disable api-ssl service"
/ip service disable [find name=api-ssl]

:put "[+] Disable ip cloud service"
/ip cloud set ddns-enabled=no update-time=no

:put "[+] Disable telnet service"
/ip service disable [find name=telnet]

:put "[+] Disable ftp service"
/ip service disable [find name=ftp]

:put "[+] Disable proxy service"
/ip proxy set enabled=no

:put "[+] Disable socks service"
/ip socks set enabled=no

:put "[+] Disable upnp service"
/ip upnp set enabled=no

:put "[+] Disable www service"
/ip service disable [find name=www]

:put "[+] Disable www-ssl service"
/ip service disable [find name=www-ssl]

:put "[+] Disable mac ping"
/tool mac-server ping set enabled=no

:put "[+] Disable mac server"
/tool mac-server set allowed-interface-list=none

:put "[+] Disable mac winbox"
/tool mac-server mac-winbox set allowed-interface-list=none

:put "[+] Disable bandwidth-server"
/tool bandwidth-server set enabled=no

:put "[+] Disable dns cache"
/ip dns set allow-remote-requests=no

:put "[+] Disable neighbor discovery"
/ip neighbor discovery-settings set discover-interface-list=none
/ip neighbor discovery settings set default=no default-for-dynamic=no

:put "[+] Disable IPv6 neighbor discovery"
/ipv6 nd set [find] disabled=yes

:put "[+] Disable Router Management Overlay Network (ROMON)"
/tool romon set enabled=no

:put "[+] Enable Reverse Path Filtering (RPF)"
/ip settings set rp-filter=strict

:put "[+] Enable stronger crypto for SSH"
/ip ssh set strong-crypto=yes

:put "[+] Enabled logs on disk"
/system logging action add name=disk target=disk disk-file-name=log
/system logging add topics=info action=disk
/system logging add topics=warning action=disk
/system logging add topics=error action=disk

:put "[+] Enable NTP clock synchronization"
/system ntp client set enabled=yes server-dns-names=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org

:put "[+] Change default ssh port"
/ip service set ssh port=2200

:put "[+] Disable LCD module for compatible routerBOARD device"
/lcd set enabled=no

:put "[+] Create a config backup"
/export compact file=backup_config

# Manual best practices
:log info "Consider configuring the appropriate firewall configurations to your need."
:log info "Consider create a backup strategy."
:log info "Consider to manually change credentials."
:log info "Consider to regularly monitor the log file size."
