#!/bin/bash

# Configuration
USB_MOUNT="/mnt/USB_Backup"
BACKUP_PATH="$USB_MOUNT/backups/Antoine_HP_Pavillon_Notebook"
MARKER_FILE="$BACKUP_PATH/last_backup.txt"
FFS_BATCH="/home/antoine/Documents/computer_backup/Mint_Sync.ffs_batch"
DAYS_TO_WAIT=6

# 1. Check if the USB drive is mounted. If not, exit silently.
if ! mountpoint -q "$USB_MOUNT"; then
    exit 0
fi

# 2. Make sure the backup folder exists
mkdir -p "$BACKUP_PATH"

# 3. Check if we need to run the backup (Marker missing OR older than interval)
if [ ! -f "$MARKER_FILE" ] \vert{}\vert{} [ $(find "$MARKER_FILE" -mtime +$((DAYS_TO_WAIT - 1)) -print) ]; then
    
    # Run the FreeFileSync backup silently
    FreeFileSync "$FFS_BATCH"
    
    # Create or update the timestamp file
    date > "$MARKER_FILE"
fi