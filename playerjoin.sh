#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
CONSOLE_IN="/opt/MinecraftServer/console.in"
x=0

while x=1; do
	TESTPLAYER=`tail -1 $SERVERLOG | grep "logged in with entity id" | awk '{print $4}'`
	sleep 1s
	if [ $TESTPLAYER ]; then
		if [ "$(grep $TESTPLAYER $PLAYERSLIST)" != $TESTPLAYER ]; then
			echo "$TESTPLAYER" >> $PLAYERSLIST
			echo "tell $TESTPLAYER Welcome to Minecraft!" >> $CONSOLE_IN
		fi
	fi
done
