/system script
add name=tg_config owner=admin policy=read source="###########################\
    ###########\r\
    \n# Telegram bot API, VVS/BlackVS 2017\r\
    \n#                                Config file\r\
    \n######################################\r\
    \n:put \"tg: Load config\"\r\
    \n\r\
    \n# to use config insert next lines:\r\
    \n#:local fconfig [:parse [/system script get tg_config source]]\r\
    \n#:local config [\$fconfig]\r\
    \n#:put \$config\r\
    \n\r\
    \n######################################\r\
    \n# Common parameters\r\
    \n######################################\r\
    \n\r\
    \n:local config {\r\
    \n\r\
    \n\"botAPI\"=\"XXXXXXXXX:YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY\";\r\
    \n\"defaultChatID\"=\"XXXXXXXXX\";\r\
    \n\"trusted\"=\"AAAAAAAAA,BBBBBBBBB,CCCCCCCCC\";\r\
    \n\"storage\"=\"disk1/\";\r\
    \n\"timeout\"=1;\r\
    \n}\r\
    \n\r\
    \nreturn \$config"
add name=tg_getUpdates owner=admin policy=read source=":global TGLASTMSGID\r\
    \n:global TGLASTUPDID\r\
    \n\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n:local http [:parse [/system script get func_fetch source]]\r\
    \n:local gkey [:parse [/system script get tg_getkey source]]\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local trusted [:toarray (\$cfg->\"trusted\")]\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local timeout (\$cfg->\"timeout\")\r\
    \n\r\
    \n:put \"cfg=\$cfg\"\r\
    \n:put \"trusted=\$trusted\"\r\
    \n:put \"botID=\$botID\"\r\
    \n:put \"storage=\$storage\"\r\
    \n:put \"timeout=\$timeout\"\r\
    \n\r\
    \n:local file (\$storage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$storage.\"tg_fetch_log.txt\")\r\
    \n#get 1 message per time\r\
    \n:local url (\"https://api.telegram.org/bot\".\$botID.\"/getUpdates\?time\
    out=\$timeout&limit=1\")\r\
    \n:if ([:len \$TGLASTUPDID]>0) do={\r\
    \n  :set url \"\$url&offset=\$(\$TGLASTUPDID+1)\"\r\
    \n}\r\
    \n\r\
    \n:put \"Reading updates...\"\r\
    \n:local res [\$http dst-path=\$file url=\$url resfile=\$logfile]\r\
    \n:if (\$res!=\"success\") do={\r\
    \n  :put \"Error getting updates\"\r\
    \n  return \"Failed get updates\"\r\
    \n}\r\
    \n:put \"Finished to read updates.\"\r\
    \n\r\
    \n:local content [/file get [/file find name=\$file] contents]\r\
    \n\r\
    \n:local msgid [\$gkey key=\"message_id\" text=\$content]\r\
    \n:if (\$msgid=\"\") do={ \r\
    \n :put \"No new updates\"\r\
    \n :return 0 \r\
    \n}\r\
    \n:set TGLASTMSGID \$msgid\r\
    \n\r\
    \n:local updid [\$gkey key=\"update_id\" text=\$content]\r\
    \n:set TGLASTUPDID \$updid\r\
    \n\r\
    \n:local fromid [\$gkey block=\"from\" key=\"id\" text=\$content]\r\
    \n:local username [\$gkey block=\"from\" key=\"username\" text=\$content]\
    \r\
    \n:local firstname [\$gkey block=\"from\" key=\"first_name\" text=\$conten\
    t]\r\
    \n:local lastname [\$gkey block=\"from\" key=\"last_name\" text=\$content]\
    \r\
    \n:local chatid [\$gkey block=\"chat\" key=\"id\" text=\$content]\r\
    \n:local chattext [\$gkey block=\"chat\" key=\"text\" text=\$content]\r\
    \n\r\
    \n:put \"message id=\$msgid\"\r\
    \n:put \"update id=\$updid\"\r\
    \n:put \"from id=\$fromid\"\r\
    \n:put \"first name=\$firstname\"\r\
    \n:put \"last name=\$lastname\"\r\
    \n:put \"username=\$username\"\r\
    \n:local name \"\$firstname \$lastname\"\r\
    \n:if ([:len \$name]<2) do {\r\
    \n :set name \$username\r\
    \n}\r\
    \n\r\
    \n:put \"in chat=\$chatid\"\r\
    \n:put \"command=\$chattext\"\r\
    \n\r\
    \n:local allowed ( [:type [:find \$trusted \$fromid]]!=\"nil\" or [:type [\
    :find \$trusted \$chatid]]!=\"nil\")\r\
    \n:if (!\$allowed) do={\r\
    \n :put \"Unknown sender, keep silence\"\r\
    \n :return -1\r\
    \n}\r\
    \n\r\
    \n:local cmd \"\"\r\
    \n:local params \"\"\r\
    \n:local ltext [:len \$chattext]\r\
    \n\r\
    \n:local pos [:find \$chattext \" \"]\r\
    \n:if ([:type \$pos]=\"nil\") do={\r\
    \n :set cmd [:pick \$chattext 1 \$ltext]\r\
    \n} else={\r\
    \n :set cmd [:pick \$chattext 1 \$pos]\r\
    \n :set params [:pick \$chattext (\$pos+1) \$ltext]\r\
    \n}\r\
    \n\r\
    \n:local pos [:find \$cmd \"@\"]\r\
    \n:if ([:type \$pos]!=\"nil\") do={\r\
    \n :set cmd [:pick \$cmd 0 \$pos]\r\
    \n}\r\
    \n\r\
    \n:put \"cmd=<\$cmd>\"\r\
    \n:put \"params=<\$params>\"\r\
    \n\r\
    \n:global TGLASTCMD \$cmd\r\
    \n\r\
    \n:put \"Try to invoke external script tg_cmd_\$cmd\"\r\
    \n:local script [:parse [/system script get \"tg_cmd_\$cmd\" source]]\r\
    \n\$script params=\$params chatid=\$chatid from=\$name"
add name=func_fetch owner=admin policy=ftp,read,write,policy,test source="####\
    #####################################################\r\
    \n# Wrapper for /tools fetch\r\
    \n#  Input:\r\
    \n#    mode\r\
    \n#    upload=yes/no\r\
    \n#    user\r\
    \n#    password\r\
    \n#    address\r\
    \n#    host\r\
    \n#    httpdata\r\
    \n#    httpmethod\r\
    \n#    check-certificate\r\
    \n#    src-path\r\
    \n#    dst-path\r\
    \n#    ascii=yes/no\r\
    \n#    url\r\
    \n#    resfile\r\
    \n\r\
    \n:local res \"fetchresult.txt\"\r\
    \n:if ([:len \$resfile]>0) do={:set res \$resfile}\r\
    \n#:put \$res\r\
    \n\r\
    \n:local cmd \"/tool fetch\"\r\
    \n:if ([:len \$mode]>0) do={:set cmd \"\$cmd mode=\$mode\"}\r\
    \n:if ([:len \$upload]>0) do={:set cmd \"\$cmd upload=\$upload\"}\r\
    \n:if ([:len \$user]>0) do={:set cmd \"\$cmd user=\\\"\$user\\\"\"}\r\
    \n:if ([:len \$password]>0) do={:set cmd \"\$cmd password=\\\"\$password\\\
    \"\"}\r\
    \n:if ([:len \$address]>0) do={:set cmd \"\$cmd address=\\\"\$address\\\"\
    \"}\r\
    \n:if ([:len \$host]>0) do={:set cmd \"\$cmd host=\\\"\$host\\\"\"}\r\
    \n:if ([:len \$\"http-data\"]>0) do={:set cmd \"\$cmd http-data=\\\"\$\"ht\
    tp-data\"\\\"\"}\r\
    \n:if ([:len \$\"http-method\"]>0) do={:set cmd \"\$cmd http-method=\\\"\$\
    \"http-method\"\\\"\"}\r\
    \n:if ([:len \$\"check-certificate\"]>0) do={:set cmd \"\$cmd check-certif\
    icate=\\\"\$\"check-certificate\"\\\"\"}\r\
    \n:if ([:len \$\"src-path\"]>0) do={:set cmd \"\$cmd src-path=\\\"\$\"src-\
    path\"\\\"\"}\r\
    \n:if ([:len \$\"dst-path\"]>0) do={:set cmd \"\$cmd dst-path=\\\"\$\"dst-\
    path\"\\\"\"}\r\
    \n:if ([:len \$ascii]>0) do={:set cmd \"\$cmd ascii=\\\"\$ascii\\\"\"}\r\
    \n:if ([:len \$url]>0) do={:set cmd \"\$cmd url=\\\"\$url\\\"\"}\r\
    \n\r\
    \n:put \">> \$cmd\"\r\
    \n\r\
    \n:global FETCHRESULT\r\
    \n:set FETCHRESULT \"none\"\r\
    \n\r\
    \n:local script \"\\\r\
    \n :global FETCHRESULT;\\\r\
    \n :do {\\\r\
    \n   \$cmd;\\\r\
    \n   :set FETCHRESULT \\\"success\\\";\\\r\
    \n } on-error={\\\r\
    \n  :set FETCHRESULT \\\"failed\\\";\\\r\
    \n }\\\r\
    \n\"\r\
    \n:execute script=\$script file=\$res\r\
    \n:local cnt 0\r\
    \n#:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n:while (\$cnt<100 and \$FETCHRESULT=\"none\") do={ \r\
    \n :delay 1s\r\
    \n :set \$cnt (\$cnt+1)\r\
    \n #:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n}\r\
    \n:local content [/file get [find name=\$res] content]\r\
    \n#:put \$content\r\
    \nif (\$content~\"finished\") do={:return \"success\"}\r\
    \n:return \$FETCHRESULT"
add name=tg_getkey owner=admin policy=read source="###########################\
    ###############################################\r\
    \n# tg_getkey - get key in message\r\
    \n#  Input: \r\
    \n#     text - source text\r\
    \n#     block - starting from which block to check for key\r\
    \n#     key\r\
    \n#  Output: \r\
    \n#    -1 if not found \r\
    \n#     value if found\r\
    \n########################################################################\
    ##\r\
    \n\r\
    \n:local cur 0\r\
    \n:local lkey [:len \$key]\r\
    \n:local res \"\"\r\
    \n:local p\r\
    \n\r\
    \n:if ([:len \$block]>0) do={\r\
    \n :set p [:find \$text \$block \$cur]\r\
    \n :if ([:type \$p]=\"nil\") do={\r\
    \n  :return \$res\r\
    \n }\r\
    \n :set cur (\$p+[:len \$block]+2)\r\
    \n}\r\
    \n\r\
    \n:set p [:find \$text \$key \$cur]\r\
    \n:if ([:type \$p]!=\"nil\") do={\r\
    \n :set cur (\$p+lkey+2)\r\
    \n :set p [:find \$text \",\" \$cur]\r\
    \n :if ([:type \$p]!=\"nil\") do={\r\
    \n   if ([:pick \$text \$cur]=\"\\\"\") do={\r\
    \n    :set res [:pick \$text (\$cur+1) (\$p-1)]\r\
    \n   } else={\r\
    \n    :set res [:pick \$text \$cur \$p]\r\
    \n   }\r\
    \n } \r\
    \n}\r\
    \n:return \$res"
add name=tg_sendMessage owner=admin policy=read source="######################\
    ###################################\r\
    \n# Send message to Telegram\r\
    \n#  Input:\r\
    \n#    chat - if none send to default chat \r\
    \n#    text - text to send\r\
    \n#    mode - empty or Markdown/HTML\r\
    \n\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local chatID (\$cfg->\"defaultChatID\")\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n\r\
    \n:if ([:len \$chat]>0) do={:set chatID \$chat}\r\
    \n\r\
    \n:local url \"https://api.telegram.org/bot\$botID/sendmessage\\\?chat_id=\
    \$chatID&text=\$text\"\r\
    \n:if ([:len \$mode]>0) do={:set url (\$url.\"&parse_mode=\$mode\")}\r\
    \n\r\
    \n:local file (\$storage.\"tg_send_msgs.txt\")\r\
    \n:local logfile (\$storage.\"tg_send_log.txt\")\r\
    \n\r\
    \n/tool fetch url=\$url keep-result=no"
add name=tg_cmd_health owner=admin policy=read source="#######################\
    ###\r\
    \n# /hi text\r\
    \n# Just echo to check bot is alive\r\
    \n# Input:\r\
    \n#  params - parameters\r\
    \n#  chatid - id of chat\r\
    \n#  from - name of who sent command\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local ppp [:len [/ppp active find]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n \r\
    \n:local text \"Router Id:* \$[/system identity get name] * %0A\\\r\
    \nUptime: _\$[/system resource get uptime]_%0A\\\r\
    \nCPU: _\$[/system resource get cpu-load]_%0A\\\r\
    \nRAM: _\$(([/system resource get total-memory]-[/system resource get free\
    -memory])/(1024*1024))M/\$([/system resource get total-memory]/(1024*1024)\
    )M_%0A\\\r\
    \nVoltage: _\$[:pick [/system health get voltage] 0 2]V_%0A\\\r\
    \nTemp: _\$[ /system health get temperature]C_%0A\\\r\
    \nPPP users: _\$ppp online_\"\r\
    \n \r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add name=tg_cmd_hi owner=admin policy=read source="##########################\
    \r\
    \n# /hi text\r\
    \n# Just echo to check bot is alive\r\
    \n# Input:\r\
    \n#  params - parameters\r\
    \n#  chatid - id of chat\r\
    \n#  from - name of who sent command\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n\$send chat=\$chatid text=(\"Hi \$from, how are you\?\")\r\
    \nreturn true\r\
    \n"
/system scheduler
add disabled=yes interval=15s name=Telegram on-event=\
    "/system script run tg_getUpdates" policy=\
    ftp,read,write,policy,test,sensitive start-date=dec/04/2017 start-time=\
    00:00:00