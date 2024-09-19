:global addVlan do={
    :global readInput
    :global readBool
    :global addNetwork

    :local tmpName $name
    :local tmpId $id
    :local tmpInterface $interface
    :local vlanName $tmpName
    :local vlanId $tmpId
    :local interfaceName $tmpInterface

    :if ([:typeof $vlanName] = "nothing") do={
        :set vlanName [$readInput "Enter VLAN name:"]
    }
    :if ([:len [/interface find name=$vlanName]] > 0) do={
        :error "VLAN '$vlanName' already exists."
    }

    :if ([:typeof $vlanId] = "nothing") do={
        :set vlanId [$readInput "Enter VLAN ID:"]
    }

    :local parentInterfacePrompt "Enter parent interface name:"
    :local defaultParentInterface
    :local bridges [/interface bridge find]
    :if ([:len $bridges] > 0) do={
        :set defaultParentInterface [/interface get [:pick $bridges 0] name]
        :set parentInterfacePrompt "$parentInterfacePrompt [$defaultParentInterface]"
    }

    :if ([:typeof $interfaceName] = "nothing") do={
        :set interfaceName [$readInput $parentInterfacePrompt]
        :if ([:typeof $defaultParentInterface] = "str" && $interfaceName = "") do={ :set interfaceName $defaultParentInterface }
    }
    :if ([/interface find name=$interfaceName] = "") do={
        :error "Invalid interface '$interfaceName'."
    }

    :if ([:len [/interface vlan find interface=$interfaceName vlan-id=$vlanId]] > 0) do={
        :error "VLAN ID $vlanId already exists on interface '$interfaceName'."
    }

    :local interfaceValue [/interface find name=$interfaceName]

    /interface vlan add name=$vlanName interface=$interfaceName vlan-id=$vlanId

    :if ([/interface get $interfaceValue type] = "bridge") do={
        /interface bridge vlan add bridge=$interfaceName tagged=$interfaceName vlan-ids=$vlanId comment=$vlanName
    }
    /interface list member add list=LAN interface=$vlanName

    :if ([$readBool "Configure IP addressing for this VLAN?" default-value=yes]) do={
        $addNetwork name=$vlanName interface=$vlanName
    }
}
