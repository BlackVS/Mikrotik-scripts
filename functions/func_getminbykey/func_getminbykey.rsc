/system script
add name=func_getminbykey owner=admin policy=read source="####################\
    ###############################\r\
    \n# func_getminbykey - find element in array with minimal value of some fi\
    eld \r\
    \n#\r\
    \n# Input: inArray - array of elements as array of ids\r\
    \n#           inKey - name of key for comparing\r\
    \n#\r\
    \n# Output: element of array with minimum inKey value\r\
    \n################################################### \r\
    \n\r\
    \n:local res\r\
    \n:local resTime\r\
    \n:foreach i in=[/file find type=backup] do={ \r\
    \n :local t [/file get \$i creation-time]\r\
    \n :put [:totime \$t]\r\
    \n :if ( \$resTime=nil ) do={:set resTime \$t}\r\
    \n :if ( \$t<\$resTime) do={:set resTime \$t}\r\
    \n :put \$resTime\r\
    \n}\r\
    \n"