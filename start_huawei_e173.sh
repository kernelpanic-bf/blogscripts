#!/bin/bash
#
# Script to startup Huawei e173 3G USB modem
# Could no doubt be rewritten to use EXPECT or something similar
# Also could do with a trap to cleanup for when its interrupted
# Signal strength is reported asynchronusly on ttyUSB2, 
# look at it usng minicom or putty
#
# Ref: http://forums.freebsd.org/showthread.php?t=15952
# Ref: http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=734
#
APN=${APN:-CONNECTCAP}
TTY=/dev/ttyUSB0
# set -x # Uncomment to debug scripts
set -e # Exit on fault in script

ifdown wwan0 && true > /dev/null 2>&1


# Report signal strength while working
# 0-31 where 31 is best but I get about 7 in the study
cat /dev/ttyUSB2 | grep RSSI &
PID=$!
cat /dev/ttyUSB0 | sed -e 's/^/LOG: /' &
PID2=$!

trap "kill $PID $PID2 ; exit 0" INT TERM EXIT

stty -F $TTY ispeed 406800 ospeed 406800 -echo

# Reset
echo -ne 'ATZ\r\n' > $TTY
sleep 1
echo -ne 'AT&F\r\n' > $TTY
sleep 1
# Reneable RSSI if needed
echo -ne 'AT^CURC=1\r\n' > $TTY
sleep 1

# Prepare to work
echo -ne 'AT+CFUN=1\r\n' > $TTY
sleep 1
echo -ne 'AT+CMEE=2\r\n' > $TTY
sleep 1
echo -ne 'AT+CSQ\r\n' > $TTY
sleep 1

# Print out available networks - 50502 is optus
# Should see: +COPS: 0,2,"50502",2
echo -ne 'AT+COPS?\r\n' > $TTY
sleep 1

# Enable wwan0 for DHCP - connects to the service
# At this point the blue led finally stops flashing and turns on solid
echo -ne 'AT^NDISDUP=1,1,"'$APN'"\r\n' > $TTY
sleep 1
#NEWMAC=`ifconfig | sed -n -e '/wwan0/ s/^.*HWaddr \([0-9a-f]\{2\}:[0-9a-f]\{2\}:[0-9a-f]\{2\}\).*$/\1:03:04:05/p'`
# Note - for some reason the WMAC is dodgy, set it to the following bogus MAC address and it works.
ifconfig wwan0 hw ether 00:01:02:03:04:05
ifup wwan0
ifconfig | grep -A1 wwan0
kill $PID $PID2
exit 0

