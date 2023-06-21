/file remove install-scripts.rsc

:local baseUrl "https://raw.githubusercontent.com/EyeTeaSwedenAB/routeros-scripts/main"

:local files {
    "util"
    "add-network"
    "add-vlan"
}

:foreach file in=$files do={
    :local fileName "$file.rsc"
    /tool fetch "$baseUrl/$fileName"
    :delay 0.5
    import $fileName
    /file remove $fileName
}
