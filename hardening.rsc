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

# Update system packages
:put "[+] Updating system packages"
:do {
    /system package update check-for-updates
    /system package update install
} on-error={
    $handleError "Failed to update system packages"
}

# Add new user and disable the admin user
:put "[+] Adding new account named 'hardened'"
:do {
    /user add name=hardened password=hardened group=full
} on-error={
    $handleError "Failed to add new user 'hardened'"
}

:if ( [/user find name=admin] != "" ) do={
    :put "[+] Disabling admin account"
    :do {
        /user disable admin
    } on-error={
        $handleError "Failed to disable admin account"
    }
} else={
    $handleError "Admin account not found"
}

# Disable unnecessary services
:put "[+] Disabling unnecessary services"
:foreach service in={ "api"; "api-ssl"; "telnet"; "ftp"; "www"; "www-ssl" } do={
    :do {
        /ip service disable [find name=$service]
    } on-error={
        $handleError "Failed to disable $service service"
    }
}

# Disable IP Cloud
:put "[+] Disabling IP Cloud service"
:do {
    /ip cloud set ddns-enabled=no update-time=no
} on-error={
    $handleError "Failed to disable IP Cloud service"
}

# Disable Proxy and Socks
:put "[+] Disabling proxy and socks services"
:do {
    /ip proxy set enabled=no
} on-error={
    $handleError "Failed to disable proxy service"
}
:do {
    /ip socks set enabled=no
} on-error={
    $handleError "Failed to disable socks service"
}

# Disable UPNP
:put "[+] Disabling UPNP service"
:do {
    /ip upnp set enabled=no
} on-error={
    $handleError "Failed to disable UPNP service"
}

# Disable MAC server and related services
:put "[+] Disabling MAC server and related services"
:do {
    /tool mac-server ping set enabled=no
} on-error={
    $handleError "Failed to disable MAC ping"
}
:do {
    /tool mac-server set allowed-interface-list=none
} on-error={
    $handleError "Failed to disable MAC server"
}
:do {
    /tool mac-server mac-winbox set allowed-interface-list=none
} on-error={
    $handleError "Failed to disable MAC winbox"
}

# Disable Bandwidth server
:put "[+] Disabling bandwidth-server"
:do {
    /tool bandwidth-server set enabled=no
} on-error={
    $handleError "Failed to disable bandwidth-server"
}

# Disable DNS cache
:put "[+] Disabling DNS cache"
:do {
    /ip dns set allow-remote-requests=no
} on-error={
    $handleError "Failed to disable DNS cache"
}

# Disable Neighbor Discovery
:put "[+] Disabling neighbor discovery"
:do {
    /ip neighbor discovery-settings set discover-interface-list=none
} on-error={
    $handleError "Failed to disable neighbor discovery"
}

# Disable IPv6 Neighbor Discovery
:put "[+] Disabling IPv6 neighbor discovery"
:do {
    /ipv6 nd set [find] disabled=yes
} on-error={
    $handleError "Failed to disable IPv6 neighbor discovery"
}

# Disable ROMON
:put "[+] Disabling Router Management Overlay Network (ROMON)"
:do {
    /tool romon set enabled=no
} on-error={
    $handleError "Failed to disable ROMON"
}

# Enable Reverse Path Filtering (RPF)
:put "[+] Enabling Reverse Path Filtering (RPF)"
:do {
    /ip settings set rp-filter=strict
} on-error={
    $handleError "Failed to enable Reverse Path Filtering (RPF)"
}

# Enable stronger SSH crypto
:put "[+] Enabling stronger crypto for SSH"
:do {
    /ip ssh set strong-crypto=yes
} on-error={
    $handleError "Failed to enable stronger crypto for SSH"
}

# Change default SSH port
:put "[+] Changing default SSH port"
:do {
    /ip service set ssh port=2200
} on-error={
    $handleError "Failed to change default SSH port"
}

# Configure logging to disk if not already configured
:put "[+] Configuring logging to disk"
:global logActionExists [/system logging action find where name="disk"]
:if ($logActionExists = "") do={
    :do {
        /system logging action add name=disk target=disk disk-file-name=log
    } on-error={
        $handleError "Failed to create logging action 'disk'"
    }
    :put "[+] Logging action 'disk' created"
} else={
    :put "[+] Logging action 'disk' already exists"
}
:do {
    /system logging add topics=info action=disk
} on-error={
    $handleError "Failed to add info logging to disk"
}
:do {
    /system logging add topics=warning action=disk
} on-error={
    $handleError "Failed to add warning logging to disk"
}
:do {
    /system logging add topics=error action=disk
} on-error={
    $handleError "Failed to add error logging to disk"
}

# Enable NTP clock synchronization
:put "[+] Enabling NTP clock synchronization"
:do {
    /system ntp client set enabled=yes servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org
} on-error={
    $handleError "Failed to enable NTP clock synchronization"
}

# Disable LCD Module if compatible
:put "[+] Disabling LCD module (if available)"
:do {
    /lcd set enabled=no
} on-error={
    :put "[-] LCD command not found, skipping"
    :log error "[-] LCD command not found, skipping"
}

# Build firewall rules
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
    $handleError "Failed to build firewall rules"
}

# Create a config backup
:put "[+] Creating a config backup file named 'backup_config'"
:do {
    /export compact file=backup_config
} on-error={
    $handleError "Failed to create config backup"
}

:put "[+] Hardening script completed"
