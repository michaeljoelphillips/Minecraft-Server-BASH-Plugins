#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
x=0

while x=1; do
	sleep 1s
	TESTPLAYER=`tail -1 $SERVERLOG | grep "lost connection" | awk '{print $4}'`
	if [ $TESTPLAYER ]; then
		if [ "$(grep $TESTPLAYER $PLAYERSLIST)" = $TESTPLAYER ]; then
			sed -i /${TESTPLAYER}/d $PLAYERSLIST
		fi
	fi
done
