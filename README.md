## FreeFileSync Cooldown Automator

While FreeFileSync and RealTimeSync are fantastic tools, they lack a native "wait X days" setting. By default, RealTimeSync triggers the moment it detects your watched drive, regardless of how recently you backed up. 

This project pairs RealTimeSync with a simple Windows batch script to act as a gatekeeper. When you plug in your USB, the script checks when the last backup occurred. If it has been more than your set interval (e.g., 6 days), it runs the backup. If not, it quietly closes.

### Prerequisites

* **OS:** Windows or Linux Mint
* **Software:** [FreeFileSync](https://freefilesync.org/) (includes RealTimeSync)
* **Software (Windows Only):** [RemoveDrive](https://www.uwe-sieber.de/drivetools_e.html) (A command-line tool for safely ejecting drives)
* **Hardware:** An external USB drive

---

## Windows Setup Guide

Because the steps rely on each other, it is important to follow them in order.

### 1. Assign a Permanent Drive Letter to Your USB
By default, Windows assigns random letters to USB drives depending on what else is plugged in. We need to lock the letter so the script always finds the right drive.
1. Plug in your external USB drive.
2. Right-click the Windows Start button and select **Disk Management**.
3. Right-click your USB drive in the list and select **Change Drive Letter and Paths...**
4. Click **Change**, assign it to the letter **Z**, and click **OK**.

### 2. Create the FreeFileSync Batch Job
First, tell FreeFileSync exactly what to copy.
1. Open **FreeFileSync**.
2. Set the left folder to your source (e.g., `C:\Users\YourName`).
3. Set the right folder to your destination (e.g., `Z:\backups\YourName\C`).
4. Click the green gear icon to set your sync method (usually **Mirror** or **Update** for backups) and click **OK**.
5. Go to **File > Save as Batch Job...**.
6. Check the boxes for **Run Minimized** and **Auto-Close**.
7. Change the setting from Show error dialog to Ignore.
8. Save this file into this project folder (e.g., `YourName_Sync.ffs_batch`).

### 3. Install RemoveDrive (For Safe Ejection)
The Windows script includes a graphical popup to safely eject your USB drive when the backup finishes. For this to work, it needs a small utility.
1. Download **RemoveDrive** from [Uwe Sieber's website](https://www.uwe-sieber.de/drivetools_e.html) (look for the standard zip file).
2. Extract the downloaded ZIP folder.
3. Find the file named `RemoveDrive.exe` (ensure you grab the 64-bit version if applicable) and copy it.
4. Paste it into your FreeFileSync installation directory: `C:\Program Files\FreeFileSync\`. *(Note: You will need Administrator permissions to paste into this folder).*

### 4. Configure the Cooldown Script
The `RunBackup.bat` script acts as the gatekeeper. 
1. Open `RunBackup.bat` in a text editor.
2. Update the `BACKUP_PATH` variable to match your specific USB backup folder.
3. Update the path to your `.ffs_batch` file in the `:DO_BACKUP` section to point to the file you created in Step 2.

### 5. Configure RealTimeSync
Now, tell the automator to watch for the USB and trigger the script.
1. Open **RealTimeSync**.
2. Under **Folders to watch**, type `Z:\`.
3. Clear whatever text is in the **Command line** box, and replace it with `cmd /c start /wait "" ` followed by the exact path to your script (e.g., `"C:\path\to\your\repo\RunBackup.bat"`).
4. Go to **File > Save As** and save this configuration in your Documents folder as `USB_Watch.ffs_real`.

### 6. Automate in the Background
For this to be truly automatic, RealTimeSync needs to run in your system tray whenever your computer is on.
1. Press `Win + R` on your keyboard to open the Run box.
2. Type `shell:startup` and press **Enter**. This opens the Windows Startup folder.
3. Drag and drop the `USB_Watch.ffs_real` file you just created into this folder.

---

## Linux Mint Setup Guide

Because the steps rely on each other, it is important to follow them in order.

### 1. Set a Permanent Mount Point
Linux Mint dynamically mounts USB drives under `/media`, but setting a static mount point ensures the script never loses track of the drive.
1. Open the **Disks** application from your Mint start menu.
2. Select your USB drive from the left sidebar.
3. Click the gear icon below the "Volumes" graphic and select **Edit Mount Options**.
4. Toggle off **User Session Defaults**.
5. Ensure **Mount at system startup** and **Show in user interface** are checked.
6. In the **Mount Point** field, type a permanent, simple path (e.g., `/mnt/USB_Backup`). Click **OK** and authenticate.

### 2. Create the FreeFileSync Batch Job
First, tell FreeFileSync exactly what to copy.
1. Open **FreeFileSync**.
2. Set the left folder to your source (e.g., `/home/yourname/`).
3. Set the right folder to your destination (e.g., `/mnt/USB_Backup/yourname/home`).
4. Click the green gear icon to set your sync method (usually **Mirror** or **Update** for backups) and click **OK**.
5. Go to **File > Save as Batch Job...**.
6. Check the boxes for **Run Minimized** and **Auto-Close**.
7. Change the setting from Show error dialog to Ignore.
8. Save this file into this project folder (e.g., `YourName_Sync.ffs_batch`).

### 3. Configure the Cooldown Script (Bash)
Linux relies on Bash scripts (`.sh`) instead of batch files.
1. Open `RunBackup.sh` in a text editor (like Xed or Nano).
2. Update the `BACKUP_PATH` variable at the top to match your specific USB backup folder.
3. Update the path to point to the `.ffs_batch` file you created in Step 2.
4. Open a terminal, navigate to the folder containing your script, and make it executable by running: `chmod +x RunBackup.sh`

### 4. Configure RealTimeSync
Now, tell the automator to watch for the USB and trigger the script.
1. Open **RealTimeSync**.
2. Under **Folders to watch**, type your mount point (e.g., `/mnt/USB_Backup/`).
3. Clear whatever text is in the **Command line** box, and replace it with `cmd /c start /wait "" ` followed by the exact path to your script (e.g., `"/home/yourname/path/to/repo/RunBackup.sh"`).
4. Go to **File > Save As** and save this configuration in your Documents folder as `USB_Watch.ffs_real`.

### 5. Automate in the Background
For this to be truly automatic, RealTimeSync needs to run silently whenever you log into Linux Mint.
1. Open **Startup Applications** from the Mint start menu.
2. Click the **+** (Add) button at the bottom and select **Custom command**.
3. In the **Name** field, type `USB Backup Watcher`.
4. In the **Command** field, you must provide the full path to both the RealTimeSync executable and your configuration file. 
   * **If downloaded from the website:** `/opt/FreeFileSync/RealTimeSync /home/yourname/Documents/USB_Watch.ffs_real`
   * **If installed via Flatpak:** `flatpak run --command=RealTimeSync org.freefilesync.FreeFileSync /home/yourname/Documents/USB_Watch.ffs_real`
5. Add a brief description if you like, then click **Add** and ensure the toggle switch is turned on.

---

### How It Works Moving Forward

Whenever you turn on your PC, RealTimeSync will silently launch in the background. When you physically plug in the drive, RealTimeSync instantly detects it and runs the script. 

* If you plugged it in yesterday, the script sees the `last_backup.txt` file is too new and stops immediately. 
* If it has been more than your set interval, the script triggers your FreeFileSync backup, updates the timestamp, and resets the clock.

> **⚠️ Important Note on Checking Progress**
> Because the FreeFileSync job is configured to run minimized, it will appear as an icon in your system tray (hidden apps) while backing up. 
> * If you click this icon, the window will open so you can view the progress. 
> * **Do not click the "X" (Close) button** when you are done viewing! Closing the window will instantly abort the backup process and throw an error. 
> * Instead, click the **Minimize** button (the underscore `_`) to send it back to the background so it can finish the job.