/system script
add name=func_time2int owner=admin policy=read source="#######################\
    ################################\r\
    \n# func_time2int - convert time to int\r\
    \n# Input: \r\
    \n#    time in format \"HH:MM:SS\"\r\
    \n# Output:\r\
    \n#    integer equal to seconds total. Can be used to compare time\r\
    \n#######################################################\r\
    \n:local res ([:tonum [:pick \$time 0 2]]*3600+[:tonum [:pick \$time 3 5]]\
    *60+[:tonum [:pick \$time 6 8]])\r\
    \n:return \$res\r\
    \n"