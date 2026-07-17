@echo off
set BACKUP_PATH=Z:\backups\Antoine_ASUS_VIVOBOOK\C
set MARKER_FILE=%BACKUP_PATH%\last_backup.txt

:: 1. Check if the USB drive is actually plugged in. If not, exit.
if not exist "Z:\" exit

:: 2. Make sure the backup folder exists on the USB.
if not exist "%BACKUP_PATH%" mkdir "%BACKUP_PATH%"

:: 3. If the timestamp file doesn't exist, this must be the first run.
if not exist "%MARKER_FILE%" goto DO_BACKUP

:: 4. Check if the timestamp file is 6 days old or older.
forfiles /P "%BACKUP_PATH%" /M "last_backup.txt" /D -6 >nul 2>&1
if %errorlevel% equ 0 goto DO_BACKUP

:: If it has been less than 6 days, close immediately without syncing.
exit

:DO_BACKUP
:: Run the FreeFileSync backup silently
"C:\Program Files\FreeFileSync\FreeFileSync.exe" "C:\Users\antoi\Documents\Home\computer\backup\Antoine_Sync.ffs_batch"

:: Create or update the timestamp file with today's date
echo Last backed up on %date% at %time% > "%MARKER_FILE%"