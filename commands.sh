#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
CONSOLE_IN="/opt/MinecraftServer/console.in"
MODS_ENABLED="/opt/MinecraftServer/scripts/mods.enabled"
VOTE_LIST="/opt/MinecraftServer/scripts/vote.list"
VOTE_LIST_NEW="/opt/MinecraftServer/scripts/vote.list.new"
START_VOTE="/opt/MinecraftServer/scripts/startvote.sh"
PLAYER_KICK="/opt/MinecraftServer/scripts/player.kick"
BALLOT_IN_PROGRESS="$(cat /opt/MinecraftServer/scripts/ballot)"

x=0

if [ ! -e $SERVERLOG ]; then
	echo "Cannot find server.log!"
fi

if [ ! -e $PLAYERSLIST ]; then
	echo "Cannot find players.list!\nGoing ahead and creating players.list"
	touch $PLAYERSLIST
fi

#if [ ! -p $CONSOLE_IN ]; then
#	echo "Cannot find console.in!  Please create fifo."
#fi

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
				if [ ! $COMMAND_PARAMETERS ]; then #No Player Specified
					echo "tell $TESTPLAYER Syntax: server[colon] vote_kick [player]" > $CONSOLE_IN
				else
					if [ $BALLOT_IN_PROGRESS = "false" ]; then #We are not voting.
						# Voting not started.  Initializing vote process.
						echo "say $TESTPLAYER is voting to kick $COMMAND_PARAMETERS" > $CONSOLE_IN
						echo "say You have 1 minute to cast your vote." > $CONSOLE_IN
						PLAYER_TO_KICK="$COMMAND_PARAMETERS"
						# Send the PLAYER_TO_KICK variable to a file for the fork.
						echo $PLAYER_TO_KICK > $PLAYER_KICK
						echo $TESTPLAYER >> $VOTE_LIST
						sh $START_VOTE &
						BALLOT_IN_PROGRESS="true"
					else
						# Voting already started.  Who are we voting on?
						if [ $COMMAND_PARAMETERS = $PLAYER_TO_KICK ]; then
							echo "tell $TESTPLAYER Your vote has been cast." > $CONSOLE_IN
							echo $TESTPLAYER >> $VOTE_LIST
						else
							echo "tell $TESTPLAYER Voting has already started.  Wait until voting closes and try again." > $CONSOLE_IN
						fi
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
