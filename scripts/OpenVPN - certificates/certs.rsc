# OpenVPN certificates generation
# v1.0
# (c) VVS aka BlackVS, 2019
/system script
add dont-require-permissions=no name=certs_createCA owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local fconfig [:parse [/system script get certs_defaults source]]\r\
    \n:local cfg [\$fconfig]\r\
    \n\r\
    \n:local NAME (\$cfg->\"NAME\")\r\
    \n:local CN (\$cfg->\"CNCA\")\r\
    \n:local COUNTRY (\$cfg->\"COUNTRY\")\r\
    \n:local STATE (\$cfg->\"STATE\")\r\
    \n:local LOCALITY (\$cfg->\"LOCALITY\")\r\
    \n:local ORG (\$cfg->\"ORG\")\r\
    \n:local OU (\$cfg->\"OU\")\r\
    \n:local KEYSIZE (\$cfg->\"KEYSIZE\")\r\
    \n:local DAYSVALID (\$cfg->\"DAYSVALID\")\r\
    \n:local ALT (\$cfg->\"ALT\")\r\
    \n\r\
    \n## generate a CA certificate\r\
    \n/certificate\r\
    \n:put \"Creating template:\"\r\
    \n:put \" NAME=\$NAME\"\r\
    \n:put \" CN=\$CN\"\r\
    \n:put \" COUNTRY=\$COUNTRY\"\r\
    \n:put \" STATE=\$STATE\"\r\
    \n:put \" LOCALITY=\$LOCALITY\"\r\
    \n:put \" ORG=\$ORG\"\r\
    \n:put \" OU=\$OU\"\r\
    \n:put \" KEYSIZE=\$KEYSIZE\"\r\
    \n:put \" DAYSVALID=\$DAYSVALID\"\r\
    \n\r\
    \nadd name=tempCA\\\r\
    \ncountry=\"\$COUNTRY\"\\\r\
    \nstate=\"\$STATE\"\\\r\
    \nlocality=\"\$LOCALITY\"\\\r\
    \norganization=\"\$ORG\"\\\r\
    \nunit=\"\$OU\"\\\r\
    \ncommon-name=\"\$CN\"\\\r\
    \nkey-size=\$KEYSIZE\\\r\
    \ndays-valid=\$DAYSVALID\\\r\
    \nsubject-alt-name=\$ALT\\\r\
    \nkey-usage=crl-sign,key-cert-sign\r\
    \n\r\
    \n:put \"Signing \$CN key...\"\r\
    \nsign tempCA ca-crl-host=127.0.0.1 name=\$CN\r\
    \n\r\
    \n:put \"Exporting \$CN key...\"\r\
    \nexport-certificate \"\$CN\" export-passphrase=\"\"\r\
    \n\r\
    \n:put \"Done!\""
add dont-require-permissions=no name=certs_createServer owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local fconfig [:parse [/system script get certs_defaults source]]\r\
    \n:local cfg [\$fconfig]\r\
    \n\r\
    \n:local NAME (\$cfg->\"NAME\")\r\
    \n:local CA (\$cfg->\"CNCA\")\r\
    \n:local CN (\$cfg->\"CNSRV\")\r\
    \n:local COUNTRY (\$cfg->\"COUNTRY\")\r\
    \n:local STATE (\$cfg->\"STATE\")\r\
    \n:local LOCALITY (\$cfg->\"LOCALITY\")\r\
    \n:local ORG (\$cfg->\"ORG\")\r\
    \n:local OU (\$cfg->\"OU\")\r\
    \n:local KEYSIZE (\$cfg->\"KEYSIZE\")\r\
    \n:local DAYSVALID (\$cfg->\"DAYSVALID\")\r\
    \n:local ALT (\$cfg->\"ALT\")\r\
    \n:\r\
    \n## generate a CA certificate\r\
    \n/certificate\r\
    \n:put \"Creating template:\"\r\
    \n:put \" CA=\$CA\"\r\
    \n:put \" CN=\$CN\"\r\
    \n:put \" COUNTRY=\$COUNTRY\"\r\
    \n:put \" STATE=\$STATE\"\r\
    \n:put \" LOCALITY=\$LOCALITY\"\r\
    \n:put \" ORG=\$ORG\"\r\
    \n:put \" OU=\$OU\"\r\
    \n:put \" KEYSIZE=\$KEYSIZE\"\r\
    \n:put \" DAYSVALID=\$DAYSVALID\"\r\
    \n\r\
    \nadd name=tempSERVER\\\r\
    \ncountry=\"\$COUNTRY\"\\\r\
    \nstate=\"\$STATE\"\\\r\
    \nlocality=\"\$LOCALITY\"\\\r\
    \norganization=\"\$ORG\"\\\r\
    \nunit=\"\$OU\"\\\r\
    \ncommon-name=\"\$CN\"\\\r\
    \nkey-size=\$KEYSIZE\\\r\
    \ndays-valid=\$DAYSVALID\\\r\
    \nkey-usage=digital-signature,key-encipherment,tls-server\r\
    \n\r\
    \n:put \"Signing SERVER@\$NAME key...\"\r\
    \nsign tempSERVER ca=\"\$CA\" name=\"SERVER@\$NAME\"\r\
    \n\r\
    \n:put \"Done!\""
add dont-require-permissions=no name=certs_createClient owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local read do={:return}\r\
    \n\r\
    \n:local fconfig [:parse [/system script get certs_defaults source]]\r\
    \n:local cfg [\$fconfig]\r\
    \n\r\
    \n:local NAME (\$cfg->\"NAME\")\r\
    \n:local CA (\$cfg->\"CNCA\")\r\
    \n:local COUNTRY (\$cfg->\"COUNTRY\")\r\
    \n:local STATE (\$cfg->\"STATE\")\r\
    \n:local LOCALITY (\$cfg->\"LOCALITY\")\r\
    \n:local ORG (\$cfg->\"ORG\")\r\
    \n:local OU (\$cfg->\"OU\")\r\
    \n:local KEYSIZE (\$cfg->\"KEYSIZE\")\r\
    \n:local DAYSVALID (\$cfg->\"DAYSVALID\")\r\
    \n:local ALT (\$cfg->\"ALT\")\r\
    \n\r\
    \n:put \"Enter client name (CN):\"\r\
    \n# storing the value entered by the user\r\
    \n:local CLIENTNAME [\$read]\r\
    \n:local CN (\"\$CLIENTNAME@\$NAME\")\r\
    \n\r\
    \n## generate a CA certificate\r\
    \n/certificate\r\
    \n:put \"Creating template:\"\r\
    \n:put \" CA=\$CA\"\r\
    \n:put \" CN=\$CN\"\r\
    \n:put \" COUNTRY=\$COUNTRY\"\r\
    \n:put \" STATE=\$STATE\"\r\
    \n:put \" LOCALITY=\$LOCALITY\"\r\
    \n:put \" ORG=\$ORG\"\r\
    \n:put \" OU=\$OU\"\r\
    \n:put \" KEYSIZE=\$KEYSIZE\"\r\
    \n:put \" DAYSVALID=\$DAYSVALID\"\r\
    \n\r\
    \nadd name=tempCLIENT\\\r\
    \ncountry=\"\$COUNTRY\"\\\r\
    \nstate=\"\$STATE\"\\\r\
    \nlocality=\"\$LOCALITY\"\\\r\
    \norganization=\"\$ORG\"\\\r\
    \nunit=\"\$OU\"\\\r\
    \ncommon-name=\"\$CN\"\\\r\
    \nkey-size=\$KEYSIZE\\\r\
    \ndays-valid=\$DAYSVALID\\\r\
    \nkey-usage=tls-client\r\
    \n\r\
    \n:put \"Signing CLIENT-\$CN key...\"\r\
    \nsign tempCLIENT ca=\"\$CA\" name=\"CLIENT-\$CN\"\r\
    \n\r\
    \n:put \"Exporting CLIENT-\$CN key...\"\r\
    \n:put \"Enter password for new certificate (If used, passphrase must be a\
    t least 8 chars long!):\"\r\
    \n:local PASSW [\$read]\r\
    \nexport-certificate \"CLIENT-\$CN\" export-passphrase=\"\$PASSW\""
add dont-require-permissions=no name=certs_defaults owner=admin policy=read \
    source="######################################\r\
    \n# Certificates defaults, VVS/BlackVS 2019\r\
    \n######################################\r\
    \n:put \"CERTS: Load defaults\"\r\
    \n\r\
    \n# to use config insert next lines:\r\
    \n#:local fconfig [:parse [/system script get certs_defaults source]]\r\
    \n#:local config [\$fconfig]\r\
    \n#:put \$config\r\
    \n\r\
    \n######################################\r\
    \n# Common parameters\r\
    \n######################################\r\
    \n\r\
    \n:local NAME \"\$[/system identity get name]\";\r\
    \n\r\
    \n:local config {\r\
    \n\"NAME\"=\"\$NAME\";\r\
    \n\"CNCA\"=\"CA-\$NAME\";\r\
    \n\"CNSRV\"=\"vpn.example.com\";\r\
    \n\"COUNTRY\"=\"UA\";\r\
    \n\"STATE\"=\"ZH\";\r\
    \n\"LOCALITY\"=\"Zhytomyr\";\r\
    \n\"ORG\"=\"Example Systems LLC\";\r\
    \n\"OU\"=\"IT Department\";\r\
    \n\"KEYSIZE\"=4096;\r\
    \n\"DAYSVALID\"=3650;\r\
    \n\"ALT\"=\"email:admin@example.com\";\r\
    \n}\r\
    \n\r\
    \nreturn \$config"
