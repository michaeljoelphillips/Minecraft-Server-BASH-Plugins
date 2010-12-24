#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
CONSOLE_IN="/opt/MinecraftServer/console.in"
MODS_ENABLED="/opt/MinecraftServer/scripts/mods.enabled"
x=0

if [ ! -e $SERVERLOG ]; then
	echo "Cannot find server.log!"
fi

if [ ! -e $PLAYERSLIST ]; then
	echo "Cannot find players.list!\nGoing ahead and creating players.list"
	touch $PLAYERSLIST
fi

if [ ! -p $CONSOLE_IN ]; then
	echo "Cannot find console.in!  Please create fifo."
fi

echo "say Commands have been enabled!  Type 'server[colon] help' for help!" > $CONSOLE_IN
while x=1; do
	sleep 1s
	COMMAND=`tail -1 $SERVERLOG | grep "server:" | awk '{print $6}'`
	COMMAND_PARAMETERS=`tail -1 $SERVERLOG | grep "server:" | awk '{print $7}'`
	TESTPLAYER=`tail -1 $SERVERLOG | grep "server:" | awk '{gsub(/\</, "", $4) ; gsub(/\>/, "", $4) ; print $4}'`
	if [ $COMMAND ]; then
		case $COMMAND in
			teleport)
				if [ ! $COMMAND_PARAMETERS ]; then
					echo "tell $TESTPLAYER Syntax: server[colon] teleport [player]" > $CONSOLE_IN
				else
					if [ "$(grep $COMMAND_PARAMETERS $PLAYERSLIST)" = $COMMAND_PARAMETERS ]; then
						echo "tp $TESTPLAYER $COMMAND_PARAMETERS" > $CONSOLE_IN
					else
						echo "tell $TESTPLAYER There are no players online with that name." > $CONSOLE_IN
					fi
				fi
			;;
			list)
				for line in $(cat $PLAYERSLIST); do
					CURRENT_PLAYERS="$CURRENT_PLAYERS $line,"
				done
				
				echo "tell $TESTPLAYER Connected Players: $CURRENT_PLAYERS" | sed s/.$// > $CONSOLE_IN
				CURRENT_PLAYERS=''
			;;
			vote_kick)
				if [ ! $COMMAND_PARAMETERS ]; then
					echo "tell $TESTPLAYER Please select a player to start the voting." > $CONSOLE_IN
				else
					if [ "$(grep $COMMAND_PARAMETERS $PLAYERSLIST)" = $COMMAND_PARAMETERS ]; then
						# Player Exists!  Execute vote_kick
						# Check to see if we are already voting on player
						if [ "$(grep $COMMAND_PARAMETERS $VOTELIST)" = $COMMAND_PARAMETERS ]; then
							# Voting started!  How many votes and how many do we need?
							# Set minimum votes var
							MINIMUM_VOTES=
						else
							# Adding Player to VOTELIST with 1 vote!
							echo "$COMMAND_PARAMETERS 1" >> $VOTELIST
							echo "1 Vote cast for $COMMAND_PARAMETERS" > $CONSOLE_IN
							echo "Need (number) of votes to kick!" > $CONSOLE_IN
						fi
					else
						echo "tell $TESTPLAYER There are no players online with that name." > $CONSOLE_IN
					fi
				fi
			;;
			help)
				echo "tell $TESTPLAYER Usage: server[colon] [command]" > $CONSOLE_IN
				echo "tell $TESTPLAYER Commands: teleport, list, vote_kick, help" > $CONSOLE_IN
			;;
			*)
				echo "tell $TESTPLAYER Unknown Command" > $CONSOLE_IN
			;;
		esac
	fi
done
