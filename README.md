## FreeFileSync Cooldown Automator

While FreeFileSync and RealTimeSync are fantastic tools, they lack a native "wait X days" setting. By default, RealTimeSync triggers the moment it detects your watched drive, regardless of how recently you backed up. 

This project pairs RealTimeSync with a simple Windows batch script to act as a gatekeeper. When you plug in your USB, the script checks when the last backup occurred. If it has been more than your set interval (e.g., 6 days), it runs the backup. If not, it quietly closes.

### Prerequisites

* **OS:** Windows
* **Software:** [FreeFileSync](https://freefilesync.org/) (includes RealTimeSync)
* **Hardware:** An external USB drive

---

### Setup Guide

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
5. Go to **File > Save as Batch Job...**
6. Check the boxes for **Run Minimized** and **Auto-Close**.
7. Save this file into this project folder (e.g., `Antoine_Sync.ffs_batch`).

### 3. Configure the Cooldown Script
The `RunBackup.bat` script acts as the gatekeeper. 
1. Open `RunBackup.bat` in a text editor.
2. Update the `BACKUP_PATH` variable to match your specific USB backup folder.
3. Update the path to your `.ffs_batch` file in the `:DO_BACKUP` section to point to the file you created in Step 2.
* *Note: A `config.ini.example` file is included if you prefer to modify the batch script to read external variables instead of hardcoding them.*

### 4. Configure RealTimeSync
Now, tell the automator to watch for the USB and trigger the script.
1. Open **RealTimeSync**.
2. Under **Folders to watch**, type `Z:\`.
3. Clear whatever text is in the **Command line** box, and replace it with the exact path to your script (e.g., `"C:\path\to\your\repo\RunBackup.bat"`).
4. Go to **File > Save As** and save this configuration in your Documents folder as `USB_Watch.ffs_real`.

### 5. Automate in the Background
For this to be truly automatic, RealTimeSync needs to run in your system tray whenever your computer is on.
1. Press `Win + R` on your keyboard to open the Run box.
2. Type `shell:startup` and press **Enter**. This opens the Windows Startup folder.
3. Drag and drop the `USB_Watch.ffs_real` file you just created into this folder.

---

### How It Works Moving Forward

Whenever you turn on your PC, RealTimeSync will silently launch in the background. When you physically plug in the `Z:` drive, RealTimeSync instantly detects it and runs the `.bat` file. 

* If you plugged it in yesterday, the script sees the `last_backup.txt` file is too new and stops immediately. 
* If it has been 6 days or more, the script triggers your FreeFileSync backup, updates the timestamp, and resets the 6-day clock.