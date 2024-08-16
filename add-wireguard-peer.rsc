:global addWireguardPeer do={
    :global readInput
    :global replaceChar

    :local tmpName $comment
    :local comment $tmpName
    :local interface wireguard

    :local if [/interface wireguard find name=$interface]

    :if ([:len $if] = 0) do={
        :error "No WireGuard interface found. Create one using \$addWireguardInterface."
    }

    :local endpoint [/ip firewall address-list find list=WG_ENDPOINT dynamic=no]
    :local endpointAddress

    :if ([:len $endpoint] > 1) do={
        :error "Multiple endpoint addresses defined."
    }

    :if ([:len $endpoint] = 0) do={
        :put "No endpoint address defined."
        :set endpointAddress [$readInput "Enter endpoint address:"]
        /ip firewall address-list add list=WG_ENDPOINT address=$endpointAddress disabled=yes comment="Used for generating WireGuard configuration"
    } else={
        :set endpointAddress [/ip firewall address-list get $endpoint address]
    }

    :if ([:len [/ip firewall address-list find list=WG_ALLOWED_IP]] = 0) do={
        :put "No allowed IP addresses defined."
        /ip firewall address-list add list=WG_ALLOWED_IP address=[$readInput "Enter allowed IP address:"] comment="Used for generating WireGuard configuration"
    }

    :if ([:typeof $comment] = "nothing") do={
        :set comment [$readInput "Enter peer description:"]
    }

    :local getAvailableAddress do={
        :local i 100
        :local network [/ip address get [find interface=wireguard] network]

        while (true) do={
            :local address ($network | "0.0.0.$i")
            if ([:len [/interface wireguard peers find allowed-address="$address/32"]] = 0) do={
                :return $address
            }
            set i ($i + 1)
        }
    }

    :local address [$getAvailableAddress]

    /interface wireguard
    :local i [add]
    :local peerPrivateKey [get $i private-key]
    :local peerPublicKey [get $i public-key]
    remove $i

    peers add interface=$interface public-key=$peerPublicKey allowed-address=$address comment=$comment

    :local publicKey [get $if public-key]

    :local allowedIp
    :foreach k in=[/ip firewall address-list find list=WG_ALLOWED_IP dynamic=no] do={
        :local address [/ip firewall address-list get $k address]
        :set allowedIp ($allowedIp, $address)
    }

    :set allowedIp [$replaceChar [:tostr $allowedIp] ";" ", "]

    :put ""
    :put "[Interface]"
    :put "PrivateKey = $peerPrivateKey"
    :put "Address = $address"

    :local dnsServer [/ip firewall address-list find list=WG_DNS_SERVER dynamic=no]
    :if ($dnsServer) do={
        :local dnsServerAddress [/ip firewall address-list get $dnsServer address]
        :put "DNS = $dnsServerAddress"
    }

    :put ""
    :put "[Peer]"
    :put "PublicKey = $publicKey"
    :put "Endpoint = $endpointAddress:51820"
    :put "AllowedIPs = $allowedIp"
}
