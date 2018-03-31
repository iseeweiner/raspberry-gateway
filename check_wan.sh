#!/bin/bash
COUNT=60
TIMER=60

function logtofile() {
echo -e "[`date`] $1" >> /var/log/check_connection.log
}

while true
do
	# Check wlan0
	while [[ -z "$(ifconfig | grep wlan0)" && $COUNT -gt 0 ]]
	do
		logtofile "[ERROR] No inteface wlan0"
		sleep 2
		COUNT=$((COUNT-1))
	done

	if [[ -z "$(ifconfig | grep wlan0)" && $COUNT -le 0 ]]
	then
		logtofile "[ERROR] Still no interface wlan0 rebooting"
		reboot
	fi

	logtofile "[INFO] Inteface wlan0 found"
	# Check wlan0 addr
	COUNT=60
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
		logtofile "[INFO] Sleeping for ${TIMER}sec"
		sleep $TIMER
	fi
done
