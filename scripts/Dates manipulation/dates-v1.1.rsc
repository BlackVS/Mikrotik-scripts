# nov/01/2017 09:21:19 by RouterOS 6.37.4
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
add name=func_cmp2dates owner=admin policy=read source="######################\
    ####################################################\r\
    \n# func_cmp2dates - compare two dates\r\
    \n#  Input: two dates in format \"mmm/dd/yyyy\". For example \"jan/01/1970\
    \"\r\
    \n#  Output: \r\
    \n#    -1 if date1<date2  \r\
    \n#     0 if date1=date2\r\
    \n#     1 if date1>date2\r\
    \n########################################################################\
    ##\r\
    \n# uncomment for testing\r\
    \n:local date1 \$1\r\
    \n:local date2 \$2\r\
    \n########################################\r\
    \n\r\
    \n#compare years\r\
    \n:local year1 [:tonum [:pick \$date1 7 11]]\r\
    \n:local year2 [:tonum [:pick \$date2 7 11]]\r\
    \nif (\$year1<\$year2) do={ :return -1 }\r\
    \nif (\$year1>\$year2) do={ :return  1 }\r\
    \n\r\
    \n#compare months\r\
    \n:local months {\"jan\"=1;\"feb\"=2;\"mar\"=3;\"apr\"=4;\"may\"=5;\"jun\"\
    =6;\"jul\"=7;\"aug\"=8;\"sep\"=9;\"oct\"=10;\"nov\"=11;\"dec\"=12}\r\
    \n:local month1 (\$months->[:pick \$date1 0 3])\r\
    \n:local month2 (\$months->[:pick \$date2 0 3])\r\
    \nif (\$month1<\$month2) do={ :return -1 }\r\
    \nif (\$month1>\$month2) do={ :return  1 }\r\
    \n\r\
    \n#compare days\r\
    \n:local day1 [:tonum [:pick \$date1 4 6]]\r\
    \n:local day2 [:tonum [:pick \$date2 4 6]]\r\
    \nif (\$day1<\$day2) do={ :return -1 }\r\
    \nif (\$day1>\$day2) do={ :return  1 }\r\
    \n:return 0"
add name=func_daysInMonth owner=admin policy=read source="######### func_daysI\
    nMonth - get days in the month\r\
    \n#  Input: month, year\r\
    \n#    month - 1..12\r\
    \n#    year - yyyy, correct only for years >1918\r\
    \n\r\
    \n######### uncomment for testing\r\
    \n#:local month 2\r\
    \n#:local year 2200\r\
    \n########################################\r\
    \n:local mdays  {31;28;31;30;31;30;31;31;30;31;30;31}\r\
    \n:local mm 0\r\
    \n:local yy \$year\r\
    \n:if ([:typeof \$month]=\"str\") do={\r\
    \n  :set mm (:\$months->\$month)\r\
    \n} else={\r\
    \n  :set mm \$month\r\
    \n}\r\
    \n:local res [:pick \$mdays (\$mm-1)]\r\
    \n:if (\$mm!=2) do={\r\
    \n   :return \$res\r\
    \n}\r\
    \n\r\
    \nif (  (\$yy&3=0 && \$yy/100*100 != \$yy) || \$yy/400*400=\$yy ) do={\r\
    \n   :set res 29\r\
    \n}\r\
    \n:return \$res"
add name=func_daysInYear owner=admin policy=read source="############ func_day\
    sInYear - get days in the year\r\
    \n#  Input: month, year\r\
    \n#    year - yyyy, correct only for years >1918\r\
    \n########### uncomment for testing\r\
    \n#:local year 1918\r\
    \n########################################\r\
    \n:local yy \$year\r\
    \n:local res 365\r\
    \n:if (  ( (\$yy&3=0) && (\$yy/100*100 != \$yy)) || \$yy/400*400=\$yy ) do\
    ={\r\
    \n   :set res 366\r\
    \n}\r\
    \n#:put \"Year \$yy -> \$res days\"\r\
    \n:return \$res"
add name=func_shiftDate owner=admin policy=read source="######################\
    ############################################# func_shiftDate - add days to\
    \_date\r\
    \n#  Input: date, days\r\
    \n#    date - \"jan/1/2017\"\r\
    \n#    days - number, +/-\r\
    \n################################################################### unco\
    mment for testing\r\
    \n#:local date \"jan/01/2100\"\r\
    \n#:local days 2560\r\
    \n########################################\r\
    \n#:put \"\$date + \$days\"\r\
    \n#use external functions\r\
    \n:local mdays  {31;28;31;30;31;30;31;31;30;31;30;31}\r\
    \n:local months {\"jan\"=1;\"feb\"=2;\"mar\"=3;\"apr\"=4;\"may\"=5;\"jun\"\
    =6;\"jul\"=7;\"aug\"=8;\"sep\"=9;\"oct\"=10;\"nov\"=11;\"dec\"=12}\r\
    \n:local monthr  {\"jan\";\"feb\";\"mar\";\"apr\";\"may\";\"jun\";\"jul\";\
    \"aug\";\"sep\";\"oct\";\"nov\";\"dec\"}\r\
    \n\r\
    \n:local dd  [:tonum [:pick \$date 4 6]]\r\
    \n:local yy [:tonum [:pick \$date 7 11]]\r\
    \n:local month [:pick \$date 0 3]\r\
    \n\r\
    \n:local mm (\$months->\$month)\r\
    \n:set dd (\$dd+\$days)\r\
    \n#:put \$dd\r\
    \n\r\
    \n:local dm [:pick \$mdays (\$mm-1)]\r\
    \n:if (\$mm=2 && ((\$yy&3=0 && \$yy/100*100 != \$yy) || \$yy/400*400=\$yy)\
    \_) do={ :set dm 29 }\r\
    \n\r\
    \n:while (\$dd>\$dm) do={\r\
    \n  :set dd (\$dd-\$dm)\r\
    \n  :set mm (\$mm+1)\r\
    \n  :if (\$mm>12) do={\r\
    \n    :set mm 1\r\
    \n    :set yy (\$yy+1)\r\
    \n  }\r\
    \n :set dm [:pick \$mdays (\$mm-1)]\r\
    \n :if (\$mm=2 &&  ((\$yy&3=0 && \$yy/100*100 != \$yy) || \$yy/400*400=\$y\
    y) ) do={ :set dm 29 }\r\
    \n};\r\
    \n\r\
    \n:while (\$dd<=0) do={\r\
    \n :set mm (\$mm-1)\r\
    \n  :if (\$mm=0) do={\r\
    \n    :set mm 12\r\
    \n    :set yy (\$yy-1)\r\
    \n  }\r\
    \n :set dm [:pick \$mdays (\$mm-1)]\r\
    \n :if (\$mm=2 &&  ((\$yy&3=0 && \$yy/100*100 != \$yy) || \$yy/400*400=\$y\
    y) ) do={ :set dm 29 }\r\
    \n :set dd (\$dd+\$dm)\r\
    \n};\r\
    \n\r\
    \n:local res \"\$[:pick \$monthr (\$mm-1)]/\"\r\
    \n:if (\$dd<10) do={ :set res (\$res.\"0\") }\r\
    \n:set \$res \"\$res\$dd/\$yy\"\r\
    \n:return \$res"
add name=test_dates owner=admin policy=read source=":local date0 \"jan/01/1970\
    \"\r\
    \n:local date1 \"jan/01/2017\"\r\
    \n:local date2 \"sep/13/2017\"\r\
    \n:local date3 \"mar/08/2000\"\r\
    \n:local today [/system clock get date] \r\
    \n\r\
    \n:local getDate  [:parse [/system script get func_datetime2str source]]\r\
    \n:local cmpDates [:parse [/system script get func_cmp2dates source]]\r\
    \n:local date2days [:parse [/system script get func_date2days source]]\r\
    \n:local daysInMonth [:parse [/system script get func_daysInMonth source]]\
    \r\
    \n:local daysInYear [:parse [/system script get func_daysInYear source]]\r\
    \n:local shiftDate [:parse [/system script get func_shiftDate source]]\r\
    \n:local subDates [:parse [/system script get func_subDates source]]\r\
    \n\r\
    \n:put \"Testing func_datetime2str\"\r\
    \n:put \"The current date/time is \$[\$getDate]\"\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_cmp2dates\"\r\
    \n:local res [\$cmpDates \$date1 \$date2]\r\
    \n:put \"Compare \$date1 to \$date2 is \$res\"\r\
    \n:set res [\$cmpDates \$date2 \$date1]\r\
    \n:put \"Compare \$date2 to \$date1 is \$res\"\r\
    \n:set res [\$cmpDates \$date1 \$date1]\r\
    \n:put \"Compare \$date1 to \$date1 is \$res\"\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_date2days\"\r\
    \n:set res [\$date2days \$date0]\r\
    \n:put \"From jan/01/1970 to \$date0 is \$res days\"\r\
    \n:set res [\$date2days \$date1]\r\
    \n:put \"From jan/01/1970 to \$date1 is \$res days\"\r\
    \n:set res [\$date2days \$date2]\r\
    \n:put \"From jan/01/1970 to \$date2 is \$res days\"\r\
    \n:set res [\$date2days \$date3]\r\
    \n:put \"From jan/01/1970 to \$date3 is \$res days\"\r\
    \n:set res [\$date2days \$today]\r\
    \n:put \"From jan/01/1970 to \$today is \$res days\"\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_daysInMonth\"\r\
    \n:local year 2016\r\
    \n:for mm from=1 to=12 do={\r\
    \n :local res [\$daysInMonth month=\$mm year=\$year]\r\
    \n :put \"In month #\$mm of year \$year is \$res days\"\r\
    \n}\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_daysInYear\"\r\
    \n:for yy from=2000 to=2017 do={\r\
    \n :local res [\$daysInYear year=\$yy]\r\
    \n :put \"In year \$yy is \$res days\"\r\
    \n}\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_shiftDate\"\r\
    \n:local days {50;100;255;1000}\r\
    \n:foreach d in=\$days do={\r\
    \n :local res2 [\$shiftDate date=\$date2 days=(-\$d)]\r\
    \n :put \"If cut from \$date2 \$d days we will get \$res2\"\r\
    \n}\r\
    \n:foreach d in=\$days do={\r\
    \n :local res1 [\$shiftDate date=\$date1 days=\$d]\r\
    \n :put \"If add to \$date1 \$d days we will get \$res1\"\r\
    \n}\r\
    \n:put \"----------------------------------------\"\r\
    \n\r\
    \n:put \"Testing func_subDate\"\r\
    \n:local res [\$subDates \$date2 \$date1]\r\
    \n:put \"From \$date1 to \$date2 is \$res days\"\r\
    \n:set res [\$subDates \$date1 \$date2]\r\
    \n:put \"From \$date2 to \$date1 is \$res days\"\r\
    \n:local d1 \$date2\r\
    \n:local d   1000\r\
    \n:local d2 [\$shiftDate date=\$d1 days=\$d]\r\
    \n:put \"If add \$d days to \$d1 we will receive \$d2\"\r\
    \n:set res [\$subDates \$d2 \$d1]\r\
    \n:put \"I.e. between \$d1 and \$d2  there are  \$res days\"\r\
    \n:put \"----------------------------------------\"\r\
    \n:put \"*** END ***\""
add name=func_subDates owner=admin policy=read source="########## func_subDate\
    s -subs dates\r\
    \n#  Input: two dates like \"jan/1/2017\"\r\
    \n########## uncomment for testing\r\
    \n#:put \"\$1 vs \$2\"\r\
    \n:local date1 \$1\r\
    \n:local date2 \$2\r\
    \n#:local date1 \"jan/01/2017\"\r\
    \n#:local date2 \"sep/14/2017\"\r\
    \n\r\
    \n########################################\r\
    \n# external functions\r\
    \n:local days2date [:parse [/system script get func_date2days source]]\r\
    \n:local res ([\$days2date \$date1]-[\$days2date \$date2])\r\
    \n:return \$res"
add name=func_date2days owner=admin policy=read source="########## func_date2d\
    ays - count days from base to given date. \r\
    \n#  Input: two dates like \"jan/1/2017\"\r\
    \n########## uncomment for testing\r\
    \n:local date \$1\r\
    \n#:local date \"sep/13/2017\"\r\
    \n#:put \$date\r\
    \n\r\
    \n# Base MUST BE lower of any given date. Mikrotik counts from jan/01/1970\
    . \r\
    \n#correct only for years>1918\r\
    \n:local base 1970\r\
    \n\r\
    \n########################################\r\
    \n:local mdays  {31;28;31;30;31;30;31;31;30;31;30;31}\r\
    \n:local months {\"jan\"=1;\"feb\"=2;\"mar\"=3;\"apr\"=4;\"may\"=5;\"jun\"\
    =6;\"jul\"=7;\"aug\"=8;\"sep\"=9;\"oct\"=10;\"nov\"=11;\"dec\"=12}\r\
    \n\r\
    \n#date \r\
    \n:local dd  [:tonum [:pick \$date 4 6]]\r\
    \n:local yy [:tonum [:pick \$date 7 11]]\r\
    \n:local mm [:pick \$date 0 3]\r\
    \n:set mm (\$months->\$mm)\r\
    \n\r\
    \n#0. We have dd/mm/yy\r\
    \n:local res 0\r\
    \n\r\
    \n#1. Move to 01/mm/yy\r\
    \n:set res (\$res+\$dd-1)\r\
    \n\r\
    \n#2. Move to 01/01/yy\r\
    \n:while (\$mm>1) do={\r\
    \n  :set mm (\$mm-1)\r\
    \n  :local dm [:pick \$mdays (\$mm-1)]\r\
    \n  :if (\$mm=2 && ((\$yy&3=0 && \$yy/100*100 != \$yy) || \$yy/400*400=\$y\
    y) ) do={ :set dm 29 }\r\
    \n  :set res (\$res+\$dm)\r\
    \n}\r\
    \n\r\
    \n#3. Move to 01/01/1900\r\
    \n:while (\$yy>\$base) do={\r\
    \n  :set yy (\$yy-1)\r\
    \n  :set res (\$res+365)\r\
    \n  :if (  ( (\$yy&3=0) && (\$yy/100*100 != \$yy)) || \$yy/400*400=\$yy ) \
    do={\r\
    \n   :set res (\$res+1)\r\
    \n  }\r\
    \n}\r\
    \n\r\
    \n:return \$res"
