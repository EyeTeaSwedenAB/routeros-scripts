:local baseUrl "https://raw.githubusercontent.com/EyeTeaSwedenAB/routeros-scripts/main"

:local files {
    "util"
    "add-network"
    "add-vlan"
    "add-wireguard-interface"
    "add-wireguard-peer"
}

:foreach file in=$files do={
    :put "Downloading $file.rsc..."
    /tool fetch "$baseUrl/$file.rsc" as-value
}

:delay 0.1

:foreach file in=$files do={
    :local fileName "$file.rsc"
    import $fileName
    /file remove $fileName
}

/file remove install-scripts.rsc
