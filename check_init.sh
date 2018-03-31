#!/bin/bash
COUNT=120

function logtofile() {
echo -e "[`date`](init) $1" >> /var/log/check_connection.log
}

# Check wlan0
while [[ -z "$(ifconfig | grep wlan0)" && $COUNT -gt 0 ]]
then
        logtofile "[ERROR] No inteface wlan0"
	COUNT=$((COUNT-1))
done

if [ -z "$(ifconfig | grep wlan0)" ]
then
	logtofile "[ERROR] Still no wlan interface, rebooting"
	sleep 1
	reboot
fi

COUNT=120
logtofile "[INFO] Inteface wlan0 found"
# Check wlan0 addr
while [[ -z "$(ifconfig | grep -A 1 wlan0 | grep -Eo 'inet ([0-9]*\.){3}[0-9]*')" && $COUNT -gt 0 ]]
do
	logtofile "[ERROR] No addr for wlan0"
	COUNT=$((COUNT-1))
	sleep 1
done

if [[ $COUNT -le 0 && -z "$(ifconfig | grep -A 1 wlan0 | grep -Eo 'inet ([0-9]*\.){3}[0-9]*')" ]]
then
        logtofile "[ERROR] No response from dhclient after ${COUNT}sec"
	sleep 10
	reboot
else
	logtofile "[INFO] Wlan0 @ $(ifconfig | grep -A 1 wlan0 | grep -Eo 'inet ([0-9]*\.){3}[0-9]*')"
fi

### Check ping google
#ping -c 1 www.google.fr &> /dev/null
#if [ $? -ne 0 ]
#then
#	echo "ping Failed"
#fi

logtofile "Connection OK\n"
