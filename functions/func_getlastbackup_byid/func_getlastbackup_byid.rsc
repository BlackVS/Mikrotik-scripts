/system script
add name=func_getlastbackup_byid owner=admin policy=read source="#############\
    ########################\r\
    \n# Script: func_getlastbackup_byid                                     \r\
    \n# Input: None                                                           \
    \_ \r\
    \n# Output: return name of last backup                         \r\
    \n#####################################\r\
    \n\r\
    \n#local variables\r\
    \n:local numBackup\r\
    \n:local idBackup\r\
    \n:local nameBackup\r\
    \n\r\
    \n#get last backup number\r\
    \n:set numBackup ([:len [/file find type=backup]]-1)\r\
    \n#:put \$numBackup\r\
    \n\r\
    \n#return nil if none backups\r\
    \n:if (\$numBackup<0) do={:return nil}\r\
    \n\r\
    \n#get id of needed backup \r\
    \n:set idBackup ([/file find type=backup]->\$numBackup)\r\
    \n#put \$idBackup\r\
    \n\r\
    \n#find name of backup\r\
    \n:set nameBackup [/file get \$idBackup name]\r\
    \n#:put \$nameBackup\r\
    \n\r\
    \n#return found result - for case of functions\r\
    \n:return \$nameBackup"
    \n"