/system script
add name=func_datetime2str owner=admin policy=read source="###################\
    ###############################################\r\
    \n# func_datetime2str - generates string from date and time\r\
    \n# Input: \r\
    \n#     \$date in format \"jan/01/1970\". If none use current date\r\
    \n#     \$time in format \"HH:MM:SS\". If none use current time\r\
    \n# Output: return string in format \"YYYY-MM-DD_HHMMSS\"\r\
    \n\r\
    \n:local sres \"\"\r\
    \n:local sdate\r\
    \n:local stime \r\
    \n:local monthsDict {\"jan\"=\"01\";\"feb\"=\"02\";\"mar\"=\"03\";\"apr\"=\
    \"04\";\"may\"=\"05\";\"jun\"=\"06\";\"jul\"=\"07\";\"aug\"=\"08\";\"sep\"\
    =\"09\";\"oct\"=\"10\";\"nov\"=\"11\";\"dec\"=\"12\"};\r\
    \n:if ([:len \$date]>0) do={:set \$sdate \$date} else={:set \$sdate [/syst\
    em clock get date]}\r\
    \n:if ([:len \$time]>0) do={:set \$stime \$time} else={:set \$stime [/syst\
    em clock get time]}\r\
    \n:if (\$sdate!=nil) do={:set sres (\$sres.[:pick \$sdate 7 11].\"-\".(\$m\
    onthsDict->([:pick \$sdate 0 3])).\"-\".[:pick \$sdate 4 6])}\r\
    \n:if (\$stime!=nil) do={:set sres (\$sres.\"_\".[:pick \$stime 0 2].[:pic\
    k \$stime 3 5].[:pick \$stime 6 8])}\r\
    \n:return \$sres"