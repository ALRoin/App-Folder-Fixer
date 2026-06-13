#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/folder-fixer"
CONFIG_FILE="$MODDIR/folder_fixer.txt"

echo "folder-fixer: live hot-install hook triggered" >> /dev/kmsg

if [ ! -f "$CONFIG_FILE" ]; then
    echo "folder-fixer: Creating config file at $CONFIG_FILE" >> /dev/kmsg
    echo "# App Folder Fixer User Configuration" > "$CONFIG_FILE"
    echo "# Add package names below (one per line) that need folder fixes." >> "$CONFIG_FILE"
    echo "# Example:" >> "$CONFIG_FILE"
    echo "# com.epicgames.portal" >> "$CONFIG_FILE"
    echo "# com.activision.callofduty.shooter" >> "$CONFIG_FILE"
    echo "# Remove '#' to enable an entry. Lines starting with '#' are treated as comments." >> "$CONFIG_FILE"
    chmod 666 "$CONFIG_FILE"
fi

echo "folder-fixer: hot-install completed successfully" >> /dev/kmsg