:global addNetwork do={
    :global readInput

    :local tmpName $name
    :local tmpAddress $address
    :local tmpInterface $interface
    :local name $tmpName
    :local address $tmpAddress
    :local interface $tmpInterface

    :if ([:typeof $name] = "nothing") do={
        :set name [$readInput "Enter network name:"]
    }

    :if ([:typeof $address] = "nothing") do={
        :set address [$readInput "Enter local IP address: (CIDR notation)"]
    }
    :local slash [:find $address "/"]
    :if (![:tobool $slash]) do={
        :error "Invalid address format."
    }
    :local gatewayAddress [:pick $address 0 $slash]
    :local prefixLength [:pick $address ($slash + 1) [:len $address]]

    :if ([:typeof $interface] = "nothing") do={
        :set interface [$readInput "Enter interface name:"]
    }
    :if ([/interface find name=$interface] = "") do={
        :error "Invalid interface '$interface'."
    }

    :local networkAddress ($gatewayAddress & (~(255.255.255.255 >> $prefixLength)))
    /ip address add address="$gatewayAddress/$prefixLength" interface=$interface

    :local poolName "dhcp-$name"
    /ip pool add name=$poolName ranges="$($networkAddress | 0.0.0.100)-$($networkAddress | 0.0.0.199)"
    /ip dhcp-server add name=$name interface=$interface address-pool=$poolName lease-time=1:00:00 disabled=no
    /ip dhcp-server network add address="$networkAddress/$prefixLength" gateway=$gatewayAddress
}
