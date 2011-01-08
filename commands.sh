#!/bin/sh

SERVERLOG="/opt/MinecraftServer/server.log"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
CONSOLE_IN="/opt/MinecraftServer/console.in"
MODS_ENABLED="/opt/MinecraftServer/scripts/mods.enabled"
VOTE_LIST="/opt/MinecraftServer/scripts/vote.list"
VOTE_LIST_NEW="/opt/MinecraftServer/scripts/vote.list.new"
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
				if [ ! $COMMAND_PARAMETERS ]; then
					echo "tell $TESTPLAYER Please select a player to kick." # > $CONSOLE_IN
				else
					# Find the number of votes we need.
					for line in $(cat $PLAYERSLIST); do
						TOTAL_PLAYERS=$(expr $TOTAL_PLAYERS + 1)
					done
					MINIMUM_VOTES=$(echo "$TOTAL_PLAYERS - ($TOTAL_PLAYERS/2)" | bc)

					if [ "$(grep $COMMAND_PARAMETERS $PLAYERSLIST)" ]; then
						# Player Exists!  Execute vote_kick
						# Check to see if we are already voting on player
						if [ "$(grep $COMMAND_PARAMETERS $VOTE_LIST)" != "" ]; then
							# Voting started, but player has been voted!  Increment votes by one.
							#grep $PLAYERSLIST $COMMAND_PARAMETERS | awk '{print $2}'
							# Increment Vote count by one for the player
							grep $COMMAND_PARAMETERS $VOTE_LIST | awk '{n=$NF+1; gsub(/[0-9]+/,n, $2); print}' < $VOTE_LIST > $VOTE_LIST_NEW
							# Push the changes
							mv vote.list.new vote.list
							PLAYER_VOTES=$(grep $COMMAND_PARAMETERS $VOTE_LIST | awk '{print $2}')
							VOTES_TO_KICK=$(expr $MINIMUM_VOTES - $PLAYER_VOTES)
							echo $MINIMUM_VOTES
							echo $PLAYER_VOTES
							echo $VOTES_TO_KICK
							sleep 10
							
							if [ $VOTES_TO_KICK = 0 ]; then
								echo "say $COMMAND_PARAMETERS Has received $PLAYER_VOTES total votes and will now be kicked!" > $CONSOLE_IN
								echo "kick $COMMAND_PARAMETERS" > $CONSOLE_IN
							else
								echo "tell $TESTPLAYER Your vote has been cast!" > $CONSOLE_IN
								echo "say $VOTES_TO_KICK more votes needed to kick $COMMAND_PARAMETER" > $CONSOLE_IN
							fi
								
						else
							# Adding Player to VOTE_LIST with 1 vote!
							echo "$COMMAND_PARAMETERS 1" >> $VOTE_LIST
							echo "1 Vote Against $COMMAND_PARAMETERS." > $CONSOLE_IN
							echo $MINIMUM_VOTES
							#echo "$(expr $MINIMUM_VOTES - 1) more votes needed to kick." > $CONSOLE_IN
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
