:global readInput do={ :put $1; :return }

:global readBool do={
    :global readInput
    :global readBool
    :local promptY "y"
    :local promptN "n"
    :local defaultValue $"default-value"
    :local hasDefaultValue ([:typeof $defaultValue] != "nothing")
    :if ($hasDefaultValue) do={
        if ($defaultValue = "yes") do={
            :set promptY "Y"
        } else={
            if ($defaultValue = "no") do={
                :set promptN "N"
            } else={
                :error "Invalid default value $defaultValue"
            }
        }
    }
    :local prompt "$1 [$promptY/$promptN]"
    :local r [$readInput $prompt]
    :local inputIsYes ($r = "y" || $r = "Y")
    :local inputIsNo  ($r = "n" || $r = "N")
    if (!($inputIsYes || $inputIsNo)) do={
        if ($r = "" && $hasDefaultValue) do={
            :return ($defaultValue = "yes")
        } else={
            :return [$readBool $1 default-value=$defaultValue]
        }
    } else={
        :return $inputIsYes
    }
}

:global replaceChar do={
    :local output
    :for i from=0 to=([:len $1] - 1) do={
        :local char [:pick $1 $i]
        :if ($char = $2) do={
            :set $char $3
        }
        :set $output ($output . $char)
    }
    :return $output
}
