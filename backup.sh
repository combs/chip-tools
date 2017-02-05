#!/bin/bash
BASENAME=`hostname`-backup
FILENAME=$BASENAME.`date +%Y%m%d`.tgz
DESTINATIONHOST="batman.local"
DESTINATIONUSER="combs"
DESTINATIONPATH="/Users/combs/Dropbox/Targets/Foton-Backups/"
if [ -e /etc/chip-backup.conf ]
	then . /etc/chip-backup.conf
fi

apt-get clean

tar czf /$FILENAME / --exclude=/\*.tgz --exclude=/proc --exclude=/sys --exclude=/run --exclude=/tmp 2>/dev/null
for arg in /$BASENAME*
	do scp "$arg" "$DESTINATIONUSER@$DESTINATIONHOST:$DESTINATIONPATH" && rm "$arg"
done
