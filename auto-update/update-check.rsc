:local holdoffTime 14d
:local releaseChannel "stable"
:local versionInfoUrl "https://upgrade.mikrotik.com/routeros/NEWESTa7.$releaseChannel"

:local latestVersionInfo ([/tool fetch url=$versionInfoUrl as-value output=user]->"data")
:local latestVersion [:pick $latestVersionInfo 0 [:find $latestVersionInfo "\_" -1]]

:local installedVersion [/system package get [find where name="routeros"] version]

:if ($installedVersion != $latestVersion) do={
    # result ends with \n - future proof by adding \n and match string up to \n
    :local latestVersionDate [:totime [:pick $latestVersionInfo ([:len $latestVersion] + 1) [:find "$latestVersionInfo\n" "\n" -1]]]
    :local latestVersionAge ([:timestamp] - $latestVersionDate)
    :if ($latestVersionAge > $holdoffTime) do={
        :log info "Latest $releaseChannel version ($latestVersion) is $([:tonum $latestVersionAge] / 3600 / 24) days old; installing..."
        /system scheduler enable update-firmware
        /system package update check-for-updates
        /system package update install
    }
}
