/system script
add name=func_cmp2dates owner=admin policy=read source="######################\
    ####################################################\r\
    \n# func_cmp2dates - compare two dates\r\
    \n#  Input: date1, date2 in format \"mmm/dd/yyyy\". For example \"jan/01/1\
    970\"\r\
    \n#  Output: \r\
    \n#    -1 if date1<date2  \r\
    \n#     0 if date1=date2\r\
    \n#     1 if date1>date2\r\
    \n########################################################################\
    ##\r\
    \n# uncomment for testing\r\
    \n#:local date1 \"nov/10/2016\"\r\
    \n#:local date2 [/system clock get date]\r\
    \n#:put (\$date1.\" compared to \".\$date2)\r\
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