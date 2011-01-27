#!/bin/sh

CONSOLE_IN="/opt/MinecraftServer/console.in"
VOTE_LIST="/opt/MinecraftServer/scripts/vote.list"
VOTE_LIST_NEW="/opt/MinecraftServer/scripts/vote.list.new"
PLAYER_KICK="$(cat /opt/MinecraftServer/scripts/player.kick)"
PLAYERSLIST="/opt/MinecraftServer/scripts/players.list"
BALLOT_IN_PROGRESS="$(cat /opt/MinecraftServer/scripts/ballot)"

# Set vote time.
sleep 60s

# Remove duplicate lines for those cheat0rz.  :(
cat $VOTE_LIST | uniq > $VOTE_LIST_NEW
TOTAL_VOTES=$(cat $VOTE_LIST_NEW | wc -l)
TOTAL_PLAYERS=$(cat $PLAYERSLIST | wc -l)
if [ "$(echo "scale=2; $TOTAL_VOTES/$TOTAL_PLAYERS >= 0.66" | bc)" = 1 ]; then
	echo "kick $PLAYER_KICK" > $CONSOLE_IN
	echo "Voting is over.  Player $PLAYER_KICK has been kicked." > $CONSOLE_IN
else
	echo "Voting is over.  There were an insufficient number of votes." > $CONSOLE_IN
	echo "$PLAYER_KICK was not kicked." > $CONSOLE_IN
fi

#Clean up variables and close voting
cat /dev/null > $VOTE_LIST
cat /dev/null > $VOTE_LIST_NEW
echo "false" > $BALLOT_IN_PROGRESS
