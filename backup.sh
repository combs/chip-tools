#!/bin/bash
FILENAME=`hostname`-backup.`date +%Y%m%d`.tgz
tar czf /$FILENAME / --exclude=/\*.tgz --exclude=/proc --exclude=/sys --exclude=/run 2>/dev/null
scp /$FILENAME combs@batman.local:/Volumes/Foton/Backups/ && rm /$FILENAME
