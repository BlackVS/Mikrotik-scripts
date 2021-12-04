/system script
add name=func_filescleanup owner=admin policy=ftp,read,write,policy,test \
    source="######################################\r\
    \n# Backups cleaning by VVS aka BlackVS, Ukraine\r\
    \n# v.1 02/01/2017\r\
    \n#Input:\r\
    \n#        \$ext - extension of file\r\
    \n#        \$prefix - prefix of file\r\
    \n#        \$count - how much files to leave. Rest will be deleted\r\
    \n######################################\r\
    \n# Some constants\r\
    \n#  change them for customizing\r\
    \n######################################\r\
    \n#use external functions\r\
    \n:local cmp2dates [:parse [/system script get func_cmp2dates source]]\r\
    \n\r\
    \n# backups and logs storage, empty if root\r\
    \n#:local prefix \"disk1/\"\r\
    \n#:local ext \"auto.backup\"\r\
    \n#:local count 30\r\
    \n\r\
    \n:local reg \"^\$prefix.*\$ext\\\$\"\r\
    \n#:put (\$reg)\r\
    \n:local arrBackups ([/file find name~\$reg])\r\
    \n#:put (\$arrBackups)\r\
    \n\r\
    \n:local files2delete ([:len \$arrBackups]-\$count)\r\
    \n\r\
    \n#:put \"Files to delete = \$files2delete\"\r\
    \n\r\
    \n:if (\$files2delete>0) do={\r\
    \n  :for i from 1 to \$files2delete do={\r\
    \n   #local variables\r\
    \n   :local resName \"\"\r\
    \n   :local resId\r\
    \n   :local resDate \"\"\r\
    \n   :local resTime \"\"\r\
    \n   :foreach id in \$arrBackups do={\r\
    \n     #get properties\r\
    \n     :local backup [/file get \$id]\r\
    \n     :local curName (\$backup->\"name\")\r\
    \n     :local curCreationTime (\$backup->\"creation-time\")\r\
    \n     :local curDate [:pick \$curCreationTime 0 11]\r\
    \n     :local curTime [:pick \$curCreationTime 12 20]\r\
    \n     :if (\$resName=\"\" ) do={\r\
    \n       :set \$resId \$id\r\
    \n       :set \$resName \$curName\r\
    \n       :set \$resDate \$curDate\r\
    \n       :set \$resTime \$curTime\r\
    \n     }\r\
    \n\r\
    \n    :local cmp [\$cmp2dates date1=\$curDate date2=\$resDate]\r\
    \n    :if (\$cmp=-1 or (\$cmp=0 and [:totime \$curTime]<[:totime \$resTime\
    ])) do={\r\
    \n      :set \$resId \$id\r\
    \n      :set \$resName \$curName\r\
    \n      :set \$resDate \$curDate\r\
    \n      :set \$resTime \$curTime\r\
    \n     }\r\
    \n   }\r\
    \n   #:put (\">> \".\$resName)\r\
    \n   :if (\$resName!=\"\") do={ /file remove \$resId }\r\
    \n   #remove from array\r\
    \n   :local newArray []\r\
    \n   :foreach i in \$arrBackups do={\r\
    \n     :if (\$i!=\$resId) do={ :set \$newArray (\$newArray,\$i) }\r\
    \n   }\r\
    \n   :set \$arrBackups \$newArray\r\
    \n  }\r\
    \n}"
