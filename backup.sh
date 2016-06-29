#!/bin/bash
BASENAME=`hostname`-backup
FILENAME=$BASENAME.`date +%Y%m%d`.tgz
tar czf /$FILENAME / --exclude=/\*.tgz --exclude=/proc --exclude=/sys --exclude=/run 2>/dev/null
for arg in /$BASENAME*
	do scp "$arg" combs@batman.local:/Volumes/Foton/Backups/ && rm "$arg"
done
