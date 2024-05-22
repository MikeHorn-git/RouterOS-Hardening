#!rsc by RouterOS
# RouterOS script: hardened
# Copyright (c) 2024 MikeHorn-git
# https://github.com/MikeHorn-git/RouterOS-Hardening/blob/main/LICENSE
# Tested on RouterOS 7.15rc3

# Function to handle errors and log them
:global handleError do={
    :put "[-] Error: $1"
    :log error "[-] Error: $1"
}

:put "[+] Starting hardening script"

:put "[+] Updating system packages"
:do {
    /system package update check-for-updates
    /system package update install
} on-error={
    :local errorMsg "Failed to update system packages"
    $handleError $errorMsg
}

:put "[+] Adding new account named 'hardened'"
:do {
    /user add name=hardened password=hardened group=full
} on-error={
    :local errorMsg "Failed to add new user 'hardened'"
    $handleError $errorMsg
}

:if ( [/user find name=admin] != "" ) do={
    :put "[+] Disabling admin account"
    :do {
        /user disable admin
    } on-error={
        :local errorMsg "Failed to disable admin account"
        $handleError $errorMsg
    }
} else={
    :local errorMsg "Admin account not found"
    $handleError $errorMsg
}

:put "[+] Disabling unnecessary services"
:foreach service in={ "api"; "api-ssl"; "telnet"; "ftp"; "www"; "www-ssl" } do={
    :do {
        /ip service disable [find name=$service]
    } on-error={
        :local errorMsg ("Failed to disable " . $service . " service")
        $handleError $errorMsg
    }
}

:put "[+] Disabling IP Cloud service"
:do {
    /ip cloud set ddns-enabled=no update-time=no
} on-error={
    :local errorMsg "Failed to disable IP Cloud service"
    $handleError $errorMsg
}

:put "[+] Disabling proxy and socks services"
:do {
    /ip proxy set enabled=no
} on-error={
    :local errorMsg "Failed to disable proxy service"
    $handleError $errorMsg
}
:do {
    /ip socks set enabled=no
} on-error={
    :local errorMsg "Failed to disable socks service"
    $handleError $errorMsg
}

:put "[+] Disabling UPNP service"
:do {
    /ip upnp set enabled=no
} on-error={
    :local errorMsg "Failed to disable UPNP service"
    $handleError $errorMsg
}

:put "[+] Disabling MAC server and related services"
:do {
    /tool mac-server ping set enabled=no
} on-error={
    :local errorMsg "Failed to disable MAC ping"
    $handleError $errorMsg
}
:do {
    /tool mac-server set allowed-interface-list=none
} on-error={
    :local errorMsg "Failed to disable MAC server"
    $handleError $errorMsg
}
:do {
    /tool mac-server mac-winbox set allowed-interface-list=none
} on-error={
    :local errorMsg "Failed to disable MAC winbox"
    $handleError $errorMsg
}

:put "[+] Disabling bandwidth-server"
:do {
    /tool bandwidth-server set enabled=no
} on-error={
    :local errorMsg "Failed to disable bandwidth-server"
    $handleError $errorMsg
}

:put "[+] Disabling DNS cache"
:do {
    /ip dns set allow-remote-requests=no
} on-error={
    :local errorMsg "Failed to disable DNS cache"
    $handleError $errorMsg
}

:put "[+] Disabling neighbor discovery"
:do {
    /ip neighbor discovery-settings set discover-interface-list=none
} on-error={
    :local errorMsg "Failed to disable neighbor discovery"
    $handleError $errorMsg
}

:put "[+] Disabling IPv6 neighbor discovery"
:do {
    /ipv6 nd set [find] disabled=yes
} on-error={
    :local errorMsg "Failed to disable IPv6 neighbor discovery"
    $handleError $errorMsg
}

:put "[+] Disabling Router Management Overlay Network (ROMON)"
:do {
    /tool romon set enabled=no
} on-error={
    :local errorMsg "Failed to disable ROMON"
    $handleError $errorMsg
}

:put "[+] Enabling Reverse Path Filtering (RPF)"
:do {
    /ip settings set rp-filter=strict
} on-error={
    :local errorMsg "Failed to enable Reverse Path Filtering (RPF)"
    $handleError $errorMsg
}

:put "[+] Enabling stronger crypto for SSH"
:do {
    /ip ssh set strong-crypto=yes
} on-error={
    :local errorMsg "Failed to enable stronger crypto for SSH"
    $handleError $errorMsg
}

:put "[+] Changing default SSH port"
:do {
    /ip service set ssh port=2200
} on-error={
    :local errorMsg "Failed to change default SSH port"
    $handleError $errorMsg
}

:put "[+] Configuring logging to disk"
:global logActionExists [/system logging action find where name="disk"]
:if ($logActionExists = "") do={
    :do {
        /system logging action add name=disk target=disk disk-file-name=log
    } on-error={
        :local errorMsg "Failed to create logging action 'disk'"
        $handleError $errorMsg
    }
    :put "[+] Logging action 'disk' created"
} else={
    :put "[+] Logging action 'disk' already exists"
}
:do {
    /system logging add topics=info action=disk
} on-error={
    :local errorMsg "Failed to add info logging to disk"
    $handleError $errorMsg
}
:do {
    /system logging add topics=warning action=disk
} on-error={
    :local errorMsg "Failed to add warning logging to disk"
    $handleError $errorMsg
}
:do {
    /system logging add topics=error action=disk
} on-error={
    :local errorMsg "Failed to add error logging to disk"
    $handleError $errorMsg
}

:put "[+] Enabling NTP clock synchronization"
:do {
    /system ntp client set enabled=yes servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org
} on-error={
    :local errorMsg "Failed to enable NTP clock synchronization"
    $handleError $errorMsg
}

:put "[+] Disabling LCD module (if available)"
:do {
    /lcd set enabled=no
} on-error={
    :put "[-] LCD command not found, skipping"
    :log error "[-] LCD command not found, skipping"
}

:put "[+] Building firewall rules"
:do {
    /ip firewall filter add action=accept chain=input comment="default configuration" connection-state=established,related
    /ip firewall filter add action=accept chain=input src-address-list=allowed_to_router
    /ip firewall filter add action=drop chain=input protocol=icmp
    /ip firewall filter add action=drop chain=input
    /ip firewall address-list add address=0.0.0.0/8 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=172.16.0.0/12 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=192.168.0.0/16 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=10.0.0.0/8 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=169.254.0.0/16 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=127.0.0.0/8 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=224.0.0.0/4 comment=Multicast list=not_in_internet
    /ip firewall address-list add address=198.18.0.0/15 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=192.0.0.0/24 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=192.0.2.0/24 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=198.51.100.0/24 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=203.0.113.0/24 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=100.64.0.0/10 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=240.0.0.0/4 comment=RFC6890 list=not_in_internet
    /ip firewall address-list add address=192.88.99.0/24 comment="6to4 relay Anycast [RFC 3068]" list=not_in_internet
    /ip firewall filter add action=fasttrack-connection chain=forward comment=FastTrack connection-state=established,related
    /ip firewall filter add action=accept chain=forward comment="Established, Related" connection-state=established,related
    /ip firewall filter add action=drop chain=forward comment="Drop invalid" connection-state=invalid log=yes log-prefix=invalid
    /ipv6 firewall filter add action=accept chain=forward comment=established,related connection-state=established,related
    /ipv6 firewall filter add action=drop chain=forward comment=invalid connection-state=invalid log=yes log-prefix=ipv6,invalid
    /ipv6 firewall filter add action=drop chain=forward log-prefix=IPV6
} on-error={
    :local errorMsg "Failed to build firewall rules"
    $handleError $errorMsg
}

:put "[+] Creating a config backup file named 'backup_config'"
:do {
    /export compact file=backup_config
} on-error={
    :local errorMsg "Failed to create config backup"
    $handleError $errorMsg
}

:put "[+] Hardening script completed"
