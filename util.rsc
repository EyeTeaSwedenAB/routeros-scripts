:global readInput do={ :put $1; :return }

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
