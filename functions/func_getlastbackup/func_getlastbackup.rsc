/system script
add name=func_getlastbackup owner=admin policy=read source="##################\
    ###################\r\
    \n# Script: func_getlastbackup                                 \r\
    \n# Input: None                                                           \
    \_ \r\
    \n# Output: return name of last backup using creation-time                \
    \_   \r\
    \n#####################################\r\
    \n#use external functions\r\
    \n:global cmp2dates [:parse [/system script get func_cmp2dates source]]\r\
    \n\r\
    \n#local variables\r\
    \n:local resName \"\"\r\
    \n:local resDate \"\"\r\
    \n:local resTime \"\"\r\
    \n\r\
    \n#get list of backups\r\
    \n:local arrBackups ([/file find type=backup])\r\
    \n\r\
    \n:foreach id in \$arrBackups do={\r\
    \n #get properties\r\
    \n :local backup [/file get \$id]\r\
    \n :local curName (\$backup->\"name\")\r\
    \n :local curCreationTime (\$backup->\"creation-time\")\r\
    \n :local curDate [:pick \$curCreationTime 0 11]\r\
    \n :local curTime [:pick \$curCreationTime 12 20]\r\
    \n :if (\$resName=\"\" ) do={\r\
    \n   :set \$resName \$curName\r\
    \n   :set \$resDate \$curDate\r\
    \n   :set \$resTime \$curTime\r\
    \n }\r\
    \n\r\
    \n :local cmp [\$cmp2dates date1=\$curDate date2=\$resDate]\r\
    \n :if (\$cmp=1 or (\$cmp=0 and [:totime \$curTime]>[:totime \$resTime])) \
    do={\r\
    \n   :set \$resName \$curName\r\
    \n   :set \$resDate \$curDate\r\
    \n   :set \$resTime \$curTime\r\
    \n }\r\
    \n}\r\
    \n:return \$resName \r\
    \n"