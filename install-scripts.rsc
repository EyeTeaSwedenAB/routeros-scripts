:local baseUrl "https://raw.githubusercontent.com/EyeTeaSwedenAB/routeros-scripts/main"

:local files {
    "util"
    "add-network"
    "add-vlan"
    "add-wireguard-interface"
    "add-wireguard-peer"
}

:local waitFile do={
    :local timeoutThreshold 10
    :local delayIncrement "0.1"
    :local delayTotal 0
    :local continue true
    :while ($continue) do={
        :if [/file find name=$1] do={
            :set continue false
        } else={
            :if ($delayTotal >= $timeoutThreshold) do={
                :error "Timed out"
            }
            :delay $delayIncrement
            :set delayTotal ($delayTotal + $delayIncrement)
        }
    }
}

:foreach file in=$files do={
    :put "Downloading $file.rsc..."
    /tool fetch "$baseUrl/$file.rsc" as-value
}

:foreach file in=$files do={
    :local fileName "$file.rsc"
    $waitFile $fileName
    import $fileName
    /file remove $fileName
}

$waitFile install-scripts.rsc
/file remove install-scripts.rsc
