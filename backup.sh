#!/bin/bash
BASENAME=`hostname`-backup
FILENAME=$BASENAME.`date +%Y%m%d`.tgz

apt-get clean
tar czf /$FILENAME / --exclude=/\*.tgz --exclude=/proc --exclude=/sys --exclude=/run 2>/dev/null
for arg in /$BASENAME*
	do scp "$arg" combs@batman.local:/Users/combs/Dropbox/Targets/Foton-Backups/ && rm "$arg"
done
