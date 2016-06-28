#!/bin/bash
FILENAME=`hostname`-backup.`date +%Y%m%d`.tgz
tar czf /$FILENAME / --exclude=/$FILENAME --exclude=/proc --exclude=/sys
scp /$FILENAME combs@batman.local:/Volumes/Foton/Backups/ && rm /$FILENAME
