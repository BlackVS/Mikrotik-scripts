# VPN channels auto-switcher
# v1.0
# (c) VVS aka BlackVS, 2018
/system script
add name=vpn-interfaces owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    global VPNINTERFACESRUN\r\
    \n#################################\r\
    \n# try up the next channel.\r\
    \n# Logic:\r\
    \n#  0. If none channels enabled - start from first.\r\
    \n#  1. If some channel enabled - disable it and try next. After last go t\
    o first\r\
    \n:put \"STARTING: vpn-interfaces\"\r\
    \n:log info \"STARTING: vpn-interfaces\"\r\
    \n\r\
    \n:if (\$VPNINTERFACESRUN=true) do={\r\
    \n  :put \"LOCK: vpn-interfaces already run. Exit If yor sure that it is n\
    ot - delete VPNINTERFACESRUN variable in Environment \"\r\
    \n  :log warning \"LOCK: vpn-interfaces already run. Exit If yor sure that\
    \_it is not - delete VPNINTERFACESRUN variable in Environment \"\r\
    \n  :return 0\r\
    \n}\r\
    \n:set VPNINTERFACESRUN true\r\
    \n\r\
    \n#### CONFIG ##################\r\
    \n:local imask \"^VPN*\"\r\
    \n:local delayBeforeChecks 1s\r\
    \n\r\
    \n#:local checkIfRunning false\r\
    \n:local checkIfRunning true\r\
    \n:local runningDelay 1s\r\
    \n:local runningMaxCount 15\r\
    \n\r\
    \n:local checkIfPing true\r\
    \n#!!! checkPing2Interface must be false if checkIfRunning is false\r\
    \n:local checkPing2Interface true\r\
    \n:local ping2host \"8.8.8.8\"\r\
    \n:local pingMaxCount 10\r\
    \n:local pingMinCount 3 \r\
    \n#############################\r\
    \n\r\
    \n\r\
    \n#############################\r\
    \n#get all needed interfaces\r\
    \n:local ifall [/interface find name~\$imask]\r\
    \n:local cntAll [:len \$ifall]\r\
    \n:put \"All (cntAll=\$cntAll): \"\r\
    \n:put \$ifall\r\
    \n\r\
    \n:local ifenabled [/interface find name~\$imask and !disabled]\r\
    \n:put \"Enabled:\"\r\
    \n:put \$ifenabled\r\
    \n\r\
    \n#disable enabled first\r\
    \n:foreach id in=\$ifenabled do={\r\
    \n  :local ifd [/interface get \$id]\r\
    \n  :put (\"Disabling \".\$ifd->\"name\")\r\
    \n  /interface disable \$id\r\
    \n}\r\
    \n\r\
    \n:local ifnext 0\r\
    \n:if ([:len \$ifenabled]=0) do={\r\
    \n  :put \"None enabled - start from first\"\r\
    \n} else={\r\
    \n  :local ifup [:pick \$ifenabled 0]\r\
    \n  :set ifnext [:find \$ifall \$ifup]\r\
    \n  :put \"Current: \$ifup\"\r\
    \n  :put \"Current index is \$ifnext\"\r\
    \n  #get next\r\
    \n  :set ifnext (\$ifnext+1)\r\
    \n  :if (\$ifnext>=\$cntAll) do={\r\
    \n    :set ifnext 0\r\
    \n  }\r\
    \n  :put \"Start index is \$ifnext\"\r\
    \n}\r\
    \n\r\
    \n#enum all interfaces startig from next from enabled\r\
    \n:for i from=1 to=\$cntAll do={\r\
    \n    :put \"\\n>>>>>>>>> \$i\"\r\
    \n    :put \">>> ifnext = \$ifnext\"\r\
    \n    :local ifup [:pick \$ifall \$ifnext]\r\
    \n\r\
    \n    :local iface [/interface get \$ifup]\r\
    \n    :put \"Inteface id to try is \$ifup\"\r\
    \n    :put (\"Interface name to check is \".\$iface->\"name\")\r\
    \n    :log warning (\"SCRIPT: try up channel: \".\$iface->\"name\")\r\
    \n\r\
    \n    :put (\"Enabling \".\$iface->\"name\")\r\
    \n    /interface enable \$ifup\r\
    \n\r\
    \n    :put \"Waiting  \$delayBeforeChecks (delay before checks)\"\r\
    \n    :delay \$delayBeforeChecks\r\
    \n\r\
    \n    :local fOk true\r\
    \n\r\
    \n    #####      check until running   ##############################\r\
    \n    :if (\$fOk=true && \$checkIfRunning=true) do={\r\
    \n       :put \"\\n#### CHECK: check if running ####\"\r\
    \n       :local cnt 0\r\
    \n       :while ( \$cnt<=\$runningMaxCount && \$iface->\"running\"!=true )\
    \_ do={\r\
    \n          :put (\$cnt.\" -> \".\$iface->\"name\".\" running is \".\$ifac\
    e->\"running\")\r\
    \n          :set iface [/interface get \$ifup]\r\
    \n          :set \$cnt (\$cnt+1)\r\
    \n          :delay \$runningDelay\r\
    \n       }\r\
    \n       :set fOk (\$iface->\"running\"=true) \r\
    \n       :put \"### running is \$fOk\"\r\
    \n       :log info (\"SCRIPT: \".\$iface->\"name\".\" running=\".\$iface->\
    \"running\")\r\
    \n    }\r\
    \n \r\
    \n    :if (\$fOk=true && \$checkIfPing=true ) do={\r\
    \n       :put \"\\n#### CHECK: check via ping ####\"\r\
    \n       :set iface [/interface get \$ifup]\r\
    \n       :local cntPings 0\r\
    \n       :if (\$checkPing2Interface=true) do={\r\
    \n         :put (\"Ping via \".\$iface->\"name\".\" interface\")\r\
    \n         :set cntPings ([/ping \$ping2host count=\$pingMaxCount interfac\
    e=\$ifup])\r\
    \n       } else={\r\
    \n         :put \"Ping using global default route\"\r\
    \n         :set cntPings ([/ping \$ping2host count=\$pingMaxCount])\r\
    \n       }\r\
    \n       :set fOk (\$cntPings>=\$pingMinCount )\r\
    \n       :log info (\"SCRIPT: \".\$iface->\"name\".\" pingable=\".\$fOk)\r\
    \n    }   \r\
    \n\r\
    \n    if (\$fOk) do={\r\
    \n       #stop and exit\r\
    \n       :set VPNINTERFACESRUN false\r\
    \n       :log warning (\"SCRIPT: \".\$iface->\"name\".\" is activated\")\r\
    \n       :return \$fOk\r\
    \n    } \r\
    \n\r\
    \n    :put \">> Interface is not up - go to the next\"\r\
    \n    :put (\">> first disabling tested interface \".\$ifup->\"name\")\r\
    \n    :log warning (\"SCRIPT: \".\$iface->\"name\".\" is dead, try next\")\
    \r\
    \n    /interface disable \$ifup\r\
    \n\r\
    \n    #try next\r\
    \n   :set ifnext (\$ifnext+1)\r\
    \n   :if (\$ifnext>=\$cntAll) do={\r\
    \n     :set ifnext 0\r\
    \n   }\r\
    \n   :put \">> and go to the next \$ifnext\"\r\
    \n}\r\
    \n\r\
    \n:set VPNINTERFACESRUN false\r\
    \n:return \$fOk"
add name=vpn-tunnel-check owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    global VPNCHECKRUN\r\
    \n:global VPNINTERFACESRUN\r\
    \n\r\
    \n:local gw \"8.8.8.8\"\r\
    \n:local cnt2ping 10\r\
    \n:local minlevel 6\r\
    \n\r\
    \n:if (\$VPNCHECKRUN=true) do={\r\
    \n  :put \"VPN-TUNNEL-CHECK: vpn-tunnel-check script is running. Skip chec\
    k\"\r\
    \n  #:log warning \"VPN-TUNNEL-CHECK: vpn-tunnel-check script is running. \
    Skip check\"\r\
    \n  :return 0\r\
    \n}\r\
    \n:set VPNCHECKRUN true\r\
    \n\r\
    \n:if (\$VPNINTERFACESRUN=true) do={\r\
    \n  :put \"VPN-TUNNEL-CHECK: vpn-interfaces script is running. Skip check\
    \"\r\
    \n  :log warning \"VPN-TUNNEL-CHECK:  vpn-interfaces script is running. Sk\
    ip check\"\r\
    \n  :set VPNCHECKRUN false\r\
    \n  :return 0\r\
    \n}\r\
    \n\r\
    \n:local cntGate ([/ping \$gw count=\$cnt2ping])\r\
    \n\r\
    \n:if (\$cntGate<\$minlevel) do={\r\
    \n  :put \"VPN broken - try switch channel\"\r\
    \n  :log warning \"VPN broken - try switch channel\"\r\
    \n  #async call not returns - may have blocks\r\
    \n  #/system script run vpn-interfaces\r\
    \n  #use sync instead\r\
    \n  :log warning \"vpn-interfaces is calling\"\r\
    \n  :local vpnscript [:parse [/system script get vpn-interfaces source]]\r\
    \n  \$vpnscript\r\
    \n  :log warning \"vpn-interfaces finished\"\r\
    \n} else={\r\
    \n  :log info \"VPN is live\"\r\
    \n}\r\
    \n:set VPNCHECKRUN false\r\
    \n\r\
    \n"
/system scheduler
add disabled=yes interval=6s name=vpn-check-task on-event=vpn-tunnel-check \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/25/2018 start-time=12:47:28