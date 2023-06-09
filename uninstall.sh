#!/bin/bash
set -e

# If our service is launched, we need to remove it
if launchctl print gui/501/com.logan.homesickd &> /dev/null
then
    sudo launchctl bootout gui/501 ~/Library/LaunchAgents/com.logan.homesickd.plist
fi

echo "Successfully uninstalled homesickd"
