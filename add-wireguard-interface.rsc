:global addWireguardInterface do={
    :global readInput

    :local vpnScope 10.95.0.0

    /interface wireguard add name=wireguard listen-port=51820
    /ip address add interface=wireguard address="$($vpnScope | 0.0.0.1)/24"

    :local getDropFilter do={
        :local filterChain $chain
        :local dropFilter
        :local dropFilters [/ip firewall filter find chain=$filterChain action=drop !disabled]
        :if ([:len $dropFilters] > 0) do={
            :set dropFilter [:pick $dropFilters 0]
        }
        :return $dropFilter
    }

    :local inputDropFilter [$getDropFilter chain=input]

    :if ($inputDropFilter) do={
        /ip firewall filter add chain=input action=accept dst-port=51820 protocol=udp comment="allow WireGuard" place-before=$inputDropFilter
    } else={
        /ip firewall filter add chain=input action=accept dst-port=51820 protocol=udp comment="allow WireGuard"
    }

    :local forwardDropFilter [$getDropFilter chain=forward]

    :if ($forwardDropFilter) do={
        /ip firewall filter add chain=forward action=accept in-interface=wireguard dst-address-list=WG_ALLOWED_IP comment="allow WireGuard" place-before=$forwardDropFilter
    } else={
        /ip firewall filter add chain=forward action=accept in-interface=wireguard dst-address-list=WG_ALLOWED_IP comment="allow WireGuard"
    }

    :put ""
    /ip firewall address-list add list=WG_ENDPOINT address=[$readInput "Enter endpoint address:"] disabled=yes comment="Used for generating WireGuard configuration"
    :put ""

    :local continue true

    :while ($continue) do={
        :local allowedAddress [$readInput ("Enter allowed IP address: (or press Enter to continue)")]

        :if ($allowedAddress != "") do={
            do {
                /ip firewall address-list add list=WG_ALLOWED_IP address=$allowedAddress comment="Used for generating WireGuard configuration"
            } on-error={
                /terminal style error
                :put "Invalid address"
                /terminal style none
            }
        } else={
            :set continue false
        }
    }
}
