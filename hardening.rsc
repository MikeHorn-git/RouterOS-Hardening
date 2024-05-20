#!rsc by RouterOS
# RouterOS script: hardened
# Copyright (c) 2024 MikeHorn-git
# https://github.com/MikeHorn-git/RouterOS-Hardening/blob/main/LICENSE
# Tested on RouterOS 7.15rc3

:put "[+] Update system"
/system package update check-for-updates
/system package update install

:put "[+] Add new account named hardened"
/user add name=hardened password=hardened group=full

:put "[+] Disable admin account"
/user disable admin

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

:put "[+] Disable IPv6 neighbor discovery"
/ipv6 nd set [find] disabled=yes

:put "[+] Disable Router Management Overlay Network (ROMON)"
/tool romon set enabled=no

:put "[+] Enable Reverse Path Filtering (RPF)"
/ip settings set rp-filter=strict

:put "[+] Enable stronger crypto for SSH"
/ip ssh set strong-crypto=yes

:put "[+] Check if logging action 'disk' exists"
:global logActionExists [/system logging action find where name="disk"]
:if ($logActionExists = "") do={
    :put "[+] Creating logging action 'disk'"
    /system logging action add name=disk target=disk disk-file-name=log
} else={
    :put "[+] Logging action 'disk' already exists"
}

:put "[+] Set logging topics to use 'disk' action"
/system logging add topics=info action=disk
/system logging add topics=warning action=disk
/system logging add topics=error action=disk

:put "[+] Enable NTP clock synchronization"
/system ntp client set enabled=yes servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org

:put "[+] Change default ssh port"
/ip service set ssh port=2200

:do {
    :put "[+] Disable LCD module for compatible routerBOARD device"
    /lcd set enabled=no
} on-error={
    :put "[-] LCD command not found, skipping"
}

:put "[+] Build firewall"
/ip firewall filter
add action=accept chain=input comment="default configuration" connection-state=established,related
add action=accept chain=input src-address-list=allowed_to_router
add action=drop chain=input protocol=icmp
add action=drop chain=input

/ip firewall address-list
add address=0.0.0.0/8 comment=RFC6890 list=not_in_internet
add address=172.16.0.0/12 comment=RFC6890 list=not_in_internet
add address=192.168.0.0/16 comment=RFC6890 list=not_in_internet
add address=10.0.0.0/8 comment=RFC6890 list=not_in_internet
add address=169.254.0.0/16 comment=RFC6890 list=not_in_internet
add address=127.0.0.0/8 comment=RFC6890 list=not_in_internet
add address=224.0.0.0/4 comment=Multicast list=not_in_internet
add address=198.18.0.0/15 comment=RFC6890 list=not_in_internet
add address=192.0.0.0/24 comment=RFC6890 list=not_in_internet
add address=192.0.2.0/24 comment=RFC6890 list=not_in_internet
add address=198.51.100.0/24 comment=RFC6890 list=not_in_internet
add address=203.0.113.0/24 comment=RFC6890 list=not_in_internet
add address=100.64.0.0/10 comment=RFC6890 list=not_in_internet
add address=240.0.0.0/4 comment=RFC6890 list=not_in_internet
add address=192.88.99.0/24 comment="6to4 relay Anycast [RFC 3068]" list=not_in_internet

/ip firewall filter
add action=fasttrack-connection chain=forward comment=FastTrack connection-state=established,related
add action=accept chain=forward comment="Established, Related" connection-state=established,related
add action=drop chain=forward comment="Drop invalid" connection-state=invalid log=yes log-prefix=invalid

/ipv6 firewall filter
add action=accept chain=forward comment=established,related connection-state=established,related
add action=drop chain=forward comment=invalid connection-state=invalid log=yes log-prefix=ipv6,invalid
add action=accept chain=forward comment="local network" in-interface=!in_interface_name src-address-list=allowed
add action=drop chain=forward log-prefix=IPV6

:put "[+] Create a config backup file named backup_config"
/export compact file=backup_config

:put "[+] Manual best practices recommendations"
:put "* Consider configuring the appropriate firewall configurations to your need."
:put "* Consider create a backup strategy."
:put "* Consider to manually CHANGE credentials."
:put "* Consider to regularly monitor the log file size."

# Log recommendations
:log info "Consider configuring the appropriate firewall configurations to your need."
:log info "Consider create a backup strategy."
:log info "Consider to manually CHANGE credentials."
:log info "Consider to regularly monitor the log file size."
