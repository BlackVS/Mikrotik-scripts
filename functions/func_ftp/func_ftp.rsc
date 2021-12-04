/system script
add name=func_ftp owner=admin policy=ftp,read,write,policy,test,sensitive \
    source="#########################################################\r\
    \n# Wrapper for /tools fetch mode=ftp\r\
    \n#  Input:\r\
    \n#    upload=yes/no\r\
    \n#    user\r\
    \n#    password\r\
    \n#    address\r\
    \n#    host\r\
    \n#    src-path\r\
    \n#    dst-path\r\
    \n#    ascii=yes/no\r\
    \n#    url\r\
    \n#    resfile\r\
    \n\r\
    \n:local ftpres \"ftpresult.txt\"\r\
    \n:if ([:len \$resfile]>0) do={:set ftpres \$resfile}\r\
    \n\r\
    \n:local cmd \"/tool fetch mode=ftp\"\r\
    \n:if ([:len \$upload]>0) do={:set cmd \"\$cmd upload=\$upload\"}\r\
    \n:if ([:len \$user]>0) do={:set cmd \"\$cmd user=\\\"\$user\\\"\"}\r\
    \n:if ([:len \$password]>0) do={:set cmd \"\$cmd password=\\\"\$password\\\
    \"\"}\r\
    \n:if ([:len \$address]>0) do={:set cmd \"\$cmd address=\\\"\$address\\\"\
    \"}\r\
    \n:if ([:len \$host]>0) do={:set cmd \"\$cmd hos=\\\"\$hos\\\"\"}\r\
    \n:if ([:len \$\"src-path\"]>0) do={:set cmd \"\$cmd src-path=\\\"\$\"src-\
    path\"\\\"\"}\r\
    \n:if ([:len \$\"dst-path\"]>0) do={:set cmd \"\$cmd dst-path=\\\"\$\"dst-\
    path\"\\\"\"}\r\
    \n:if ([:len \$ascii]>0) do={:set cmd \"\$cmd ascii=\\\"\$ascii\\\"\"}\r\
    \n:if ([:len \$url]>0) do={:set cmd \"\$cmd url=\\\"\$url\\\"\"}\r\
    \n\r\
    \n#:put \">> \$cmd\"\r\
    \n\r\
    \n:global FTPRESULT\r\
    \n:set FTPRESULT \"none\"\r\
    \n\r\
    \n:local script \"\\\r\
    \n :global FTPRESULT;\\\r\
    \n :do {\\\r\
    \n   \$cmd;\\\r\
    \n   :set FTPRESULT \\\"success\\\";\\\r\
    \n } on-error={\\\r\
    \n  :set FTPRESULT \\\"failed\\\";\\\r\
    \n }\\\r\
    \n\"\r\
    \n:execute script=\$script file=\$ftpres\r\
    \n:local cnt 0\r\
    \n#:put \"\$cnt -> \$FTPRESULT\"\r\
    \n:while (\$cnt<100 and \$FTPRESULT=\"none\") do={ \r\
    \n :delay 1s\r\
    \n :set \$cnt (\$cnt+1)\r\
    \n #:put \"\$cnt -> \$FTPRESULT\"\r\
    \n}\r\
    \n:local content [/file get [find name=\$ftpres] content]\r\
    \nif (\$content~\"finished\") do={:return \"success\"}\r\
    \n:return \$FTPRESULT"