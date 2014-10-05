#!/bin/bash
# Get email notifications about Twitter unfollowers
# This script will work for Twitter accounts with up to 5000 followers

# Set your configuration
mail="you@example.com" # Where should notifications arrive?
frommail="noreply@example.com" # Where should notifications come from?
screen_name="stoya" # Your Twitter username
# Fill with your own key and token:
# https://apps.twitter.com/app/new
consumer_key="xxxxxxxxxxxxxxxxxxxxxxxxx"
consumer_key_secret="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
token="xxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
token_secret="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


# You can stop editing here :)


method="GET"
basedir=$(dirname $0)
mkdir $basedir/out 2>/dev/null
newids="$basedir/out/newids.txt"
oldids="$basedir/out/oldids.txt"
unfollowerids="$basedir/out/unfollowerids.txt"
unfollowernames="$basedir/out/unfollowernames.txt"
unfollowers="$basedir/out/unfollowers.txt"
mailtmp="$basedir/out/mailtmp.txt"

# Get our follower's ids
followers_url="https://api.twitter.com/1.1/followers/ids.json?screen_name=$screen_name"
followers_oauth_sign=$($basedir/oauth_sign $consumer_key $consumer_key_secret $token $token_secret $method $followers_url)      
curl -s --request $method $followers_url --header "Authorization: $followers_oauth_sign" | $basedir/jq '.ids' | tr -d '[], ' | grep . > $newids

# Check if the query was successful
# A bit hackish, basically checks if there is something which looks like an ID
if ! grep -E -q -i -o "[0-9]{7,999}" $newids ; then
	exit
fi

# If it's the first time, we don't want to spam our inbox
if [[ ! -f $oldids ]]; then
	cp $newids $oldids
	exit
fi

# Get our unfollowers
cat $newids $newids $oldids | sort | uniq -u > $unfollowerids

# Prepare for the next run
rm -f $oldids
cp $newids $oldids

# If we got unfollowers, match their IDs with screen names
if [[ -s $unfollowerids ]] ; then
	# cleanup
	rm -f $unfollowernames
	while read line; do
		# lookup the screen_name of the ids
		lookup_url="https://api.twitter.com/1.1/users/lookup.json?user_id=$line"
		lookup_oauth_sign=$($basedir/oauth_sign $consumer_key $consumer_key_secret $token $token_secret $method $lookup_url)      
		curl -s --request $method $lookup_url --header "Authorization: $lookup_oauth_sign" | $basedir/jq .[]'.screen_name' | tr -d '"' >> $unfollowernames
	done < $unfollowerids
else
	# If we haven't unfollowers, we're done.
	exit
fi

# jq will cry if we pass the json from a deleted user. Remove blank lines too.
grep -v 'jq: error: Cannot index array with string' $unfollowernames | grep . > $unfollowers

# If we matched some ids to screen names, send the mail
if [[ -s $unfollowers ]] ; then
	    echo "Hi $screen_name", > $mailtmp
	    echo >> $mailtmp
	    echo "The following people isn't following you any longer:" >> $mailtmp
	    echo >> $mailtmp
	    cat $unfollowers | sed -e 's#^#https://twitter.com/#' >> $mailtmp
	    mail -a "From: $frommail" -s "Someone has unfollowed you" $mail < $mailtmp
fi
