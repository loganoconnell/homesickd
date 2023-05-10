#!/bin/bash
set -e

clang homesickd.m -o homesickd -framework Foundation -l curl

set +e
sudo -nv &> /dev/null
if [ $? != 0 ]
then
    echo "Moving homesickd to /usr/local/bin; may prompt for sudo"
fi

set -e

sudo mv homesickd /usr/local/bin/homesickd
cp com.logan.homesickd.plist ~/Library/LaunchAgents/com.logan.homesickd.plist

# If our service is already launched, we need to remove it before re-launching
if launchctl print gui/501/com.logan.homesickd &> /dev/null
then
    sudo launchctl bootout gui/501 ~/Library/LaunchAgents/com.logan.homesickd.plist
fi

sudo launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.logan.homesickd.plist

echo "Successfully installed homesickd"
