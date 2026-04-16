:local baseUrl "https://raw.githubusercontent.com/EyeTeaSwedenAB/routeros-scripts/main/auto-update"

:local files {
    "update-check"
    "update-firmware"
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
}

$waitFile install-auto-updater.rsc
/file remove install-auto-updater.rsc

/system routerboard settings set auto-upgrade=yes

# 2001-01-01 is a Monday! Adjust day of month as desired.
/system scheduler add name="update-check" interval=7d start-date=jan/03/2001 start-time=01:00:00 on-event=[/file get update-check.rsc contents]
/system scheduler add name="update-firmware" disabled=yes start-time=startup on-event=[/file get update-firmware.rsc contents] comment="Update firmware following software update (automatically enabled)"

/file remove update-check.rsc
/file remove update-firmware.rsc
