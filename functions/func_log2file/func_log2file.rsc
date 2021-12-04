/system script
add name=func_log2file owner=admin policy=read source="#######################\
    ################################\r\
    \n# func_log2file - logs text to file\r\
    \n# Input: \r\
    \n#   file - name of log file without \".txt\" extension\r\
    \n#   text - text to log\r\
    \n#   maxsize - maximum size of file.\r\
    \n#   log - duplicate to specific local log. Values: info, error, warning,\
    \_debug, no, by default=info. If \"no\" - don't output\r\
    \n#   console - duplicate to console. yes/no. By default \"no\"\r\
    \n# Warning - txt file can't be longer 4096 bytes. It is due to string siz\
    e limitation. MAXSIZE\r\
    \n#######################################################\r\
    \n:local MAXSIZE 4000\r\
    \nif ([:len \$file]=0) do={\r\
    \n :put \"Wrong parameter - file\"\r\
    \n :return nil\r\
    \n}\r\
    \n\r\
    \n#set names for main and bak\r\
    \n:local file0 \"\$file.txt\"\r\
    \n:local file1 \"\$file.bak.txt\"\r\
    \n \r\
    \n#set maximum allowed lines in file\r\
    \n:local msize \$MAXSIZE\r\
    \n:if ([:len \$maxsize]>0) do={:set msize \$maxsize}\r\
    \n:if (\$msize>\$MAXSIZE) do={\r\
    \n :put \"Wrong parameter - maxsize\"\r\
    \n :set msize \$MAXSIZE\r\
    \n}\r\
    \n#:put \"msize=\$msize\"\r\
    \n\r\
    \n#set text\r\
    \n:if ([:len \$text]=0) do={\r\
    \n :put \"func_log2file: no text for output\"\r\
    \n :return nil\r\
    \n}\r\
    \n\r\
    \n:local outtext \"\$[/system clock get date] \$[/system clock get time] \
    \$text\"\r\
    \n\r\
    \n#output to local log\r\
    \n:local loglevel \"info\"\r\
    \n:if ([:len \$log]>0) do={:set loglevel \$log}\r\
    \n#use execute due to direct call like \"/log \$loglevel text\" gives erro\
    r\r\
    \n:if (\$loglevel!=\"no\") do={ :execute script=\"/log \$loglevel \\\"\$te\
    xt\\\"\" }\r\
    \n\r\
    \n#output to console\r\
    \n:if ([:len \$console]>0 and \$console=\"yes\") do={\r\
    \n :put \"\$loglevel: \$outtext\"\r\
    \n}\r\
    \n\r\
    \n#appent topic to message\r\
    \n:set outtext \"\$loglevel\\t\$outtext\"\r\
    \n\r\
    \n#create file if none and exit\r\
    \n:if ([:len [:file find name=\$file0]]=0) do={\r\
    \n :execute script=\":put \\\"\$outtext\\\"\" file=\$file0\r\
    \n #delay is need to give time to file appearing\r\
    \n :delay 1s\r\
    \n :return nil\r\
    \n} \r\
    \n\r\
    \n#else get content of file\r\
    \n:local content [/file get [/file find name=\$file0] contents]\r\
    \n:local csize [ :len \$content ] ;\r\
    \n\r\
    \n:if ((\$csize+[:len \$outtext]+2)>\$msize) do={\r\
    \n :execute script=\":put \\\"\$content\\\"\" file=\$file1\r\
    \n /file set \$file0 contents=\"\$outtext\\r\\n\"\r\
    \n} else={\r\
    \n /file set \$file0 contents=\"\$content\$outtext\\r\\n\"\r\
    \n}\r\
    \n\r\
    \n:return nil\r\
    \n"
