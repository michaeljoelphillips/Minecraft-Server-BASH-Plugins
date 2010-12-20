#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
CONSOLE_IN="/opt/MinecraftServer/console.in"
x=0
echo "say Commands have been enabled!  Type 'server[colon] help' for help!" > $CONSOLE_IN

while x=1; do
	sleep 1s
	COMMAND=`tail -1 $SERVERLOG | grep "server:" | awk '{print $6}'`
	COMMAND_PARAMETERS=`tail -1 $SERVERLOG | grep "server:" | awk '{print $8}'`
	TESTPLAYER=`tail -1 $SERVERLOG | grep "server:" | awk '{gsub(/\</, "", $4) ; gsub(/\>/, "", $4) ; print $4}'`
	if [ $COMMAND ]; then
		case $COMMAND in
			teleport)
				echo "tp $TESTPLAYER $COMMAND_PARAMETERS" > $CONSOLE_IN
			;;
			list)
				for line in $(cat $PLAYERSLIST); do
					CURRENT_PLAYERS="$CURRENT_PLAYERS $line,"
				done
				
				echo "tell $TESTPLAYER Connected Players: $CURRENT_PLAYERS" | sed s/.$// > $CONSOLE_IN
				CURRENT_PLAYERS=''
			;;
			help)
				echo "tell $TESTPLAYER Usage: server[colon] [command]" > $CONSOLE_IN
				echo "tell $TESTPLAYER Commands: teleport, help, list" > $CONSOLE_IN
				#COMMAND=''
			;;
			*)
				echo "tell $TESTPLAYER Unknown Command" > $CONSOLE_IN
			;;
		esac
	fi
done
