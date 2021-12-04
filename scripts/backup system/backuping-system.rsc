# Backuping system by VVS
# v.1.4 
#
/system scheduler
add interval=15m name=logo_update on-event="/system script run logo" policy=\
    read,write start-date=nov/21/2016 start-time=12:30:00
add interval=1w name=backupweek_generate on-event=backups_generate policy=\
    ftp,read,write,policy,test start-date=nov/26/2016 start-time=00:00:00
add interval=15m name=backups_ftp on-event=backups_send2ftp policy=\
    ftp,read,write,policy,test,sensitive start-date=nov/20/2016 start-time=\
    00:05:00
add interval=1w name=backups_cleanup on-event=backups_cleanup policy=\
    ftp,read,write,policy,test,sensitive start-date=jan/22/2017 start-time=\
    00:00:00
/system script
add name=backups_config policy=ftp,read,write,policy,test source="\
    ######################################\r\
    \n# Backups generating by VVS aka BlackVS, Ukraine\r\
    \n#                                Config file\r\
    \n######################################\r\
    \n:put \"Load config\"\r\
    \n\r\
    \n# to use config insert next lines:\r\
    \n#:local fconfig [:parse [/system script get backups_config source]]\r\
    \n#:local config [\$fconfig]\r\
    \n#:put \$config\r\
    \n\r\
    \n######################################\r\
    \n# Common parameters\r\
    \n######################################\r\
    \n\r\
    \n:local config {\r\
    \n\r\
    \n#place of backups to store\r\
    \n\"storage\"=\"disk1\";\r\
    \n\r\
    \n# backups and logs storage, empty if root\r\
    \n\"backups_password\"=\"12345\";\r\
    \n\r\
    \n# auto-backuped files will have same suffix\r\
    \n\"backup_suffix\"=\"auto\";\r\
    \n\r\
    \n# add backup to Mail queue. Not supported yet\r\
    \n\"store2email\"=false;\r\
    \n\r\
    \n# add backup to FTP queue\r\
    \n\"store2ftp\"=true;\r\
    \n\r\
    \n# generate RSC files (export)\r\
    \n\"generate_rsc\"=true;\r\
    \n\r\
    \n# generate BACKUP files\r\
    \n\"generate_bkp\"=true;\r\
    \n\r\
    \n#FTP parameters\r\
    \n\"ftp_host\"=192.168.0.10;\r\
    \n\"ftp_port\"=21;\r\
    \n\"ftp_path\"=\"backups/HapAC\";\r\
    \n\"ftp_user\"=\"mkbackup\";\r\
    \n\"ftp_password\"=\"12345\";\r\
    \n\r\
    \n#Mail notifications\r\
    \n\"mailto\"=\"admin@sweet.home\";\r\
    \n\"mailsubject\"=\"[Router]: \$[/system identity get name]\";\r\
    \n\r\
    \n#logging\r\
    \n\"logfile\"=\"backups-log\";\r\
    \n\"logftp\"=\"backups-ftp-log.txt\";\r\
    \n\r\
    \n}\r\
    \n\r\
    \nreturn \$config"
add name=logo policy=read,write source=":local logcontent \"\"\r\
    \n:local ppp [:len [/ppp active find]]\r\
    \n \r\
    \n:set logcontent \"\\\r\
    \n\\nYou are logged into: \$[/system identity get name]\\n\\\r\
    \n############### system health ###############\\n\\\r\
    \n# Uptime    : \$[/system resource get uptime]\\n\\\r\
    \n# CPU       : \$[/system resource get cpu-load]%\\n\\\r\
    \n# RAM       : \$(([/system resource get total-memory]-[/system resource \
    get free-memory])/(1024*1024))M/\$([/system resource get total-memory]/(10\
    24*1024))M\\n\\\r\
    \n# Voltage   : \$[:pick [/system health get voltage] 0 2]V\\n\\\r\
    \n# Temp      : \$[ /system health get temperature]C\\n\\\r\
    \n############# user auth details #############\\n\\\r\
    \n# PPP users : \$ppp online\\n\\\r\
    \n############################################\\n\"\r\
    \n \r\
    \n/system note set note=\"\$logcontent\"\r\
    \n:return \"\$logcontent\""
add name=backups_generate policy=ftp,read,write,policy,test \
    source="######################################\r\
    \n# Backups generating by VVS aka BlackVS, Ukraine\r\
    \n######################################\r\
    \n# define or declare global saving queues. If no - they will be empty.\r\
    \n:global QBACKUPS2MAIL\r\
    \n:global QBACKUPS2FTP\r\
    \n\r\
    \n# Get config\r\
    \n######################################\r\
    \nlocal fconfig [:parse [/system script get backups_config source]]\r\
    \nlocal cfg [\$fconfig]\r\
    \n#:put \$cfg\r\
    \n\r\
    \n:local bkpassword (\$cfg->\"backups_password\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local cSuffix (\$cfg->\"backup_suffix\")\r\
    \n:local fSendViaMail (\$cfg->\"store2email\")\r\
    \n:local fSendViaFTP (\$cfg->\"store2ftp\")\r\
    \n:local fgenRSC (\$cfg->\"generate_rsc\")\r\
    \n:local fgenBACKUP (\$cfg->\"generate_bkp\")\r\
    \n:local logfile (\$cfg->\"logfile\")\r\
    \n\r\
    \n#LOCAL CONSTANTS\r\
    \n\r\
    \n:local logprefix \"BACKUPS_GENERATE: \"\r\
    \n\r\
    \n# END of CONSTANTS #####################\r\
    \n\r\
    \n############### LOGGING ##############\r\
    \n:local log2file [:parse [/system script get func_log2file source]]\r\
    \n:if ([:len \$storage]>0) do={:set logfile \"\$storage/\$logfile\"}\r\
    \n\r\
    \n\$log2file file=\$logfile console=no   log=no   text=(\$logprefix.\"----\
    --------------------------------------------------------------------------\
    -\")\r\
    \n\$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"Back\
    up file generating is started\")\r\
    \n\r\
    \n# get external functions. I set it as local to not overload /environment\
    \_\r\
    \n# due to this funsction will be called rarely\r\
    \n:local datetime2str [:parse [/system script get func_datetime2str source\
    ]]\r\
    \n\r\
    \n# generate backup name\r\
    \n:local sysname [/system identity get name]\r\
    \n:local datetime [\$datetime2str]\r\
    \n:local backupName \"\$sysname-\$datetime-\$cSuffix\"\r\
    \n\r\
    \n# create export\r\
    \n:if (\$fgenRSC) do={\r\
    \n :local ffile \"\$backupName.rsc\"\r\
    \n \$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"Exp\
    orting \$ffile\")\r\
    \n :do {\r\
    \n   /export compact file=(\$storage.\"/\".\$ffile)\r\
    \n   :if (\$fSendViaMail) do={:set QBACKUPS2MAIL (\$QBACKUPS2MAIL,\"\$ffil\
    e\")}\r\
    \n   :if (\$fSendViaFTP) do={:set QBACKUPS2FTP (\$QBACKUPS2FTP,\"\$ffile\"\
    )}\r\
    \n } on-error={ \$log2file file=\$logfile console=yes  log=error text=(\$l\
    ogprefix.\"Failed to export\") }\r\
    \n}\r\
    \n\r\
    \n# create backup\r\
    \n:if (\$fgenBACKUP) do={\r\
    \n \$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"Mak\
    ing backup \$backupName.backup\")\r\
    \n :do {\r\
    \n   :local ffile \"\$backupName.backup\"\r\
    \n   :system backup save name=(\$storage.\"/\".\$ffile) password=\$bkpassw\
    ord\r\
    \n   :if (\$fSendViaMail) do={:set QBACKUPS2MAIL (\$QBACKUPS2MAIL,\"\$ffil\
    e\")}\r\
    \n   :if (\$fSendViaFTP) do={:set QBACKUPS2FTP (\$QBACKUPS2FTP,\"\$ffile\"\
    )}\r\
    \n } on-error={ \$log2file file=\$logfile console=yes  log=error text=(\$l\
    ogprefix.\"Failed to backup\")}\r\
    \n}\r\
    \n\r\
    \n#return name of backup (without extensions)\r\
    \n\$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"Back\
    up file generating is ended\")\r\
    \n\r\
    \n:return \$backupName\r\
    \n"
add name=func_datetime2str policy=read source="###################\
    ###############################################\r\
    \n# func_datetime2str - generates string from date and time\r\
    \n# Input:  \r\
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
add name=func_log2file policy=read source="#######################\
    ################################\r\
    \n# func_log2file - logs text to file\r\
    \n# Input: \r\
    \n#   file - name of log file without \".txt\" extension\r\
    \n#   text - text to log \r\
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
add name=backups_send2ftp policy=\
    ftp,read,write,policy,test,sensitive source="#############################\
    #########\r\
    \n# Backups sending script by VVS aka BlackVS, Ukraine\r\
    \n######################################\r\
    \n#check global FTP queue and exit if empty\r\
    \n:global QBACKUPS2FTP\r\
    \n:local qlen [:len \$QBACKUPS2FTP]\r\
    \n:if (\$qlen=0) do={:return 0 } \r\
    \n\r\
    \n# Get config\r\
    \n######################################\r\
    \nlocal fconfig [:parse [/system script get backups_config source]]\r\
    \nlocal cfg [\$fconfig]\r\
    \n#:put \$cfg\r\
    \n\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local ftphost (\$cfg->\"ftp_host\")\r\
    \n:local ftpport (\$cfg->\"ftp_port\")\r\
    \n:local ftppath (\$cfg->\"ftp_path\")\r\
    \n:local ftpuser (\$cfg->\"ftp_user\")\r\
    \n:local ftppassword (\$cfg->\"ftp_password\")\r\
    \n:local logfile (\$cfg->\"logfile\")\r\
    \n:local logftp (\$cfg->\"logftp\")\r\
    \n:local mailto (\$cfg->\"mailto\")\r\
    \n:local mailsubject (\$cfg->\"mailsubject\")\r\
    \n\r\
    \n### LOCAL\r\
    \n:local logprefix \"BACKUPS_SEND2FTP: \"\r\
    \n# END of CONSTANTS #####################\r\
    \n\r\
    \n############### ERRORS ######\r\
    \n:local ERRNO 0\r\
    \n:local ERRFILENOTFOUND 1\r\
    \n:local ERRFTPFAILED 2\r\
    \n:local error \$ERRNO\r\
    \n\r\
    \n############### GET LOGGING ##############\r\
    \n:local log2file [:parse [/system script get func_log2file source]]\r\
    \n\r\
    \n:if ([:len \$storage]>0) do={\r\
    \n :set logfile \"\$storage/\$logfile\"\r\
    \n :set logftp \"\$storage/\$logftp\"\r\
    \n}\r\
    \n\r\
    \n###Start log ####################\r\
    \n\$log2file file=\$logfile console=no   log=no   text=(\$logprefix.\"----\
    --------------------------------------------------------------------------\
    -\")\r\
    \n\r\
    \n############### GET FTP ##############\r\
    \n:local ftp [:parse [/system script get func_ftp source]]\r\
    \n\r\
    \n### START\r\
    \n#get first from queue\r\
    \n:local bname [:pick \$QBACKUPS2FTP 0]\r\
    \n\r\
    \n:local bfile2save \$bname\r\
    \n:if ([:len \$storage]>0) do={:set bfile2save \"\$storage/\$bname\"}\r\
    \n\r\
    \n#check if file exists\r\
    \nif ([:len [/file find name=\$bfile2save]]=0) do={\r\
    \n \$log2file file=\$logfile console=yes  log=warning text=(\$logprefix.\"\
    file \$bfile2save not found\")\r\
    \n :set error \$ERRFILENOTFOUND\r\
    \n}\r\
    \n\r\
    \n:if (\$error=\$ERRNO) do={\r\
    \n  \$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"st\
    art sending \$bfile2save via ftp\")\r\
    \n  :local ftpdst \$bname\r\
    \n  :if ([:len \$ftppath]>0) do={:set ftpdst \"\$ftppath/\$ftpdst\"}\r\
    \n  :local res [\$ftp upload=yes user=\$ftpuser password=\$ftppassword src\
    -path=\$bfile2save address=\$ftphost dst-path=\$ftpdst resfile=\$logftp]\r\
    \n  :local content [/file get [find name=\$logftp] content]\r\
    \n  :if (\$res=\"success\") do={\r\
    \n    \$log2file file=\$logfile console=yes  log=info text=(\$logprefix.\"\
    SUCCESS sending \$bname via ftp\")  \r\
    \n    :do {\r\
    \n      /tool e-mail send to=\$mailto subject=\"\$mailsubject - backup, su\
    ccess\" body=\"Backup\\n\$bfile2save\\nwas succesfully created and sent vi\
    a FTP to\\nftp://\$ftphost/\$ftppath/\"\r\
    \n    } on-error { \$log2file file=\$logfile console=yes  log=error text=(\
    \$logprefix.\"WTF1\") }\r\
    \n  } else={\r\
    \n    \$log2file file=\$logfile console=yes  log=error text=(\$logprefix.\
    \"FAILED sending \$bname via ftp\")\r\
    \n    \$log2file file=\$logfile console=yes  log=error text=(\"FTP log: \$\
    logftp\")\r\
    \n    :set error (\$error|\$ERRFTPFAILED )\r\
    \n    :set QBACKUPS2FTP ([:pick \$QBACKUPS2FTP 1 \$qlen], \$bname)\r\
    \n    :do {\r\
    \n      /tool e-mail send to=\$mailto subject=\"\$mailsubject - backup, FA\
    ILED\" body=\"FAILED to save backup\\n\$bfile2save to\\n\\rftp://\$ftphost\
    /\$ftppath/\\n\\r\\n\\rLOG:\\n\\r\$content\$logftp\"\r\
    \n    } on-error { \$log2file file=\$logfile console=yes  log=error text=(\
    \$logprefix.\"WTF1\") }\r\
    \n  }\r\
    \n}\r\
    \n\r\
    \n#remove processed file from list\r\
    \nif (\$error=0 or \$error=\$ERRFILENOTFOUND) do={\r\
    \n :set QBACKUPS2FTP [:pick \$QBACKUPS2FTP 1 \$qlen]\r\
    \n}\r\
    \n### END"
add name=func_ftp policy=ftp,read,write,policy,test,sensitive \
    source="#########################################################\r\
    \n# Wrapper for /tools fetch mode=ftp\r\
    \n#  Input:\r\
    \n#    upload=yes/no\r\
    \n#    user\r\
    \n#    password\r\
    \n#    address\r\
    \n#    host\r\
    \n#    src-path \r\
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
add name=func_cmp2dates policy=read source="######################\
    ####################################################\r\
    \n# func_cmp2dates - compare two dates\r\
    \n#  Input: date1, date2 in format \"mmm/dd/yyyy\". For example \"jan/01/1\
    970\"\r\
    \n#  Output: \r\
    \n#    -1 if date1<date2  \r\
    \n#     0 if date1=date2 \r\
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
add name=func_filescleanup policy=ftp,read,write,policy,test \
    source="######################################\r\
    \n# Backups cleaning by VVS aka BlackVS, Ukraine\r\
    \n# v.1 02/01/2017\r\
    \n#Input: \r\
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
add name=backups_cleanup policy=\
    ftp,read,write,policy,test,sensitive source="#############################\
    #########\r\
    \n# Backups cleanup by VVS aka BlackVS, Ukraine\r\
    \n######################################\r\
    \n\r\
    \n# Get config\r\
    \n######################################\r\
    \nlocal fconfig [:parse [/system script get backups_config source]]\r\
    \nlocal cfg [\$fconfig]\r\
    \n#:put \$cfg\r\
    \n\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local cSuffix (\$cfg->\"backup_suffix\")\r\
    \n\r\
    \n######################################\r\
    \n#use external functions\r\
    \n:log info \"Starting backups cleanup\"\r\
    \n:local filescleanup [:parse [/system script get func_filescleanup source\
    ]]\r\
    \n\r\
    \n:local ext1 \"\$cSuffix.backup\"\r\
    \n:local ext2 \"\$cSuffix.rsc\"\r\
    \n\r\
    \n\$filescleanup prefix=\$storage ext=\$ext1 count=3\r\
    \n\$filescleanup prefix=\$storage ext=\$ext2 count=3\r\
    \n:log info \"Backups cleanup ended\""
