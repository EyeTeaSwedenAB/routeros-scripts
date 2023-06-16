:local baseUrl "https://raw.githubusercontent.com/EyeTeaSwedenAB/routeros-scripts/release"

:local files {
    "util"
    "add-network"
    "add-vlan"
}

:foreach file in=$files do={
    :local fileName "$file.rsc"	
    /tool fetch "$baseUrl/$fileName"
    import $fileName
    /file remove $fileName
}
