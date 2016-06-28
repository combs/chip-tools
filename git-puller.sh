#!/bin/bash
touch ~/.git-puller.log
cd ~/git || exit
for arg in `find . -maxdepth 1 -mindepth 1 -type d`
do pushd $arg >/dev/null
git pull >> ~/.git-puller.log 2>>~/.git-puller.log
popd >/dev/null
done
