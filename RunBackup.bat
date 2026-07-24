@echo off
title Backup to Z: Drive

:: 0. Prevent overlapping instances: If FreeFileSync is already running, exit immediately.
tasklist /FI "IMAGENAME eq FreeFileSync.exe" 2>NUL | find /I /N "FreeFileSync.exe">NUL
if "%ERRORLEVEL%"=="0" exit

set BACKUP_PATH=Z:\backups\Antoine_ASUS_VIVOBOOK\C
set MARKER_FILE=%BACKUP_PATH%\last_backup.txt

:: 1. Check if the USB drive is actually plugged in. If not, exit silently.
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
echo ==================================================
echo         STARTING BACKUP TO Z: DRIVE
echo ==================================================
echo.
echo FreeFileSync is running. Please wait...
echo.

:: Run the FreeFileSync backup
"C:\Program Files\FreeFileSync\FreeFileSync.exe" "C:\Users\antoi\Documents\Home\computer\backup\Antoine_Sync.ffs_batch"

:: Capture FreeFileSync exit code (0 = Success, 1 = Warning, 2 = Error, 3 = Aborted)
set FFS_ERROR=%errorlevel%

if %FFS_ERROR% neq 0 goto HANDLE_ERROR
goto HANDLE_SUCCESS


:HANDLE_ERROR
echo [ERROR] Backup stopped! FreeFileSync exited with code: %FFS_ERROR%
echo Please check the FreeFileSync logs or interface for details.
echo.

:: Send a visual popup notification so the user realizes it failed
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Backup stopped with an error (Code %FFS_ERROR%). Check the terminal window.', 'Backup Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)}"

:: Wait for the user to press Enter before closing the terminal
set /p dummy="Press Enter to close this window..."
exit /b %FFS_ERROR%


:HANDLE_SUCCESS
echo Backup completed successfully!
echo Last backed up on %date% at %time% > "%MARKER_FILE%"

:: Generate a temporary PowerShell script to create the Eject GUI
set PS_SCRIPT=%TEMP%\EjectBackupDrive.ps1

echo Add-Type -AssemblyName System.Windows.Forms > "%PS_SCRIPT%"
echo Add-Type -AssemblyName System.Drawing >> "%PS_SCRIPT%"
echo $form = New-Object System.Windows.Forms.Form >> "%PS_SCRIPT%"
echo $form.Text = "Backup Complete" >> "%PS_SCRIPT%"
echo $form.Size = New-Object System.Drawing.Size(300,140) >> "%PS_SCRIPT%"
echo $form.StartPosition = 'CenterScreen' >> "%PS_SCRIPT%"
echo $form.TopMost = $true >> "%PS_SCRIPT%"
echo $form.MaximizeBox = $false >> "%PS_SCRIPT%"
echo $form.MinimizeBox = $false >> "%PS_SCRIPT%"
echo $form.Icon = [System.Drawing.SystemIcons]::Information >> "%PS_SCRIPT%"
echo $label = New-Object System.Windows.Forms.Label >> "%PS_SCRIPT%"
echo $label.Text = "Backup to Z: finished successfully." >> "%PS_SCRIPT%"
echo $label.AutoSize = $true >> "%PS_SCRIPT%"
echo $label.Location = New-Object System.Drawing.Point(45, 20) >> "%PS_SCRIPT%"
echo $form.Controls.Add($label) >> "%PS_SCRIPT%"
echo $btn = New-Object System.Windows.Forms.Button >> "%PS_SCRIPT%"
echo $btn.Text = "Eject Z: Drive" >> "%PS_SCRIPT%"
echo $btn.Location = New-Object System.Drawing.Point(85, 55) >> "%PS_SCRIPT%"
echo $btn.Size = New-Object System.Drawing.Size(110, 30) >> "%PS_SCRIPT%"
echo $btn.Add_Click({ >> "%PS_SCRIPT%"
echo     $shell = New-Object -ComObject Shell.Application >> "%PS_SCRIPT%"
echo     $shell.Namespace(17).ParseName("Z:").InvokeVerb("Eject") >> "%PS_SCRIPT%"
echo     [System.Windows.Forms.MessageBox]::Show("Drive Z: has been requested to eject.", "Ejecting", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) >> "%PS_SCRIPT%"
echo     $form.Close() >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"
echo $form.Controls.Add($btn) >> "%PS_SCRIPT%"
echo [void]$form.ShowDialog() >> "%PS_SCRIPT%"

:: Launch the new Eject GUI completely detached from this terminal
start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

:: Close the terminal instantly
exit