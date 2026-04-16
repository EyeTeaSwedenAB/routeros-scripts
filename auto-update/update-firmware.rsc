/system scheduler disable update-firmware
:local system [/system routerboard get]
:if ($system->"current-firmware" != $system->"upgrade-firmware") do={
    :log info "Firmware update available. Rebooting..."
    /system reboot
}
