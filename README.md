# network-toolkit
5-in-1 network toolkit: WiFi passwords, speed test, LAN file share, IP scanner, bandwidth monitor
# 🔧 Network Toolkit

**5 essential network tools in ONE command-line application**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows)](toolkit.ps1)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux)](toolkit.sh)

## 🚀 Features

| # | Tool | What it does |
|---|------|---------------|
| 1 | 📶 WiFi Password Manager | View & backup all saved WiFi passwords |
| 2 | 📊 Network Speed Tester | Test download speed & ping latency |
| 3 | 📁 LAN File Share | Share files instantly on local network |
| 4 | 🌐 IP Scanner | Find all devices connected to your WiFi |
| 5 | 📈 Network Usage Monitor | See which apps use bandwidth |
| 6 | 📈 Allin1 | Run all at once |

🪟 Complete Windows Setup 
Step 1: Open PowerShell as Administrator
Press Windows + X on your keyboard

Click "Windows PowerShell (Admin)" or "Terminal (Admin)"

Click "Yes" on the popup

Step 2: Copy & Paste This ONE Command
powershell
irm https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.ps1 | iex
That's it! Press Enter and the toolkit will start!

What Happens Next:
You'll see this menu:

text
===== NETWORK TOOLKIT =====

 1. 📶 WiFi Password Manager (view & backup)
 2. 📊 Network Speed Tester
 3. 📁 LAN File Share (P2P transfer)
 4. 🌐 IP Scanner (find devices on network)
 5. 📈 Network Usage Monitor
 6. 🚀 RUN ALL TOOLS (1-5 automatically)
 7. 🚪 Exit

Choose option (1-7):
Step 3: Choose What to Do
Press This Key	What Happens
1	Shows all saved WiFi passwords
2	Tests your internet speed
3	Shares a file on your network
4	Finds all devices on your WiFi
5	Shows which apps use bandwidth
6	Runs ALL tools automatically!
7	Exits the toolkit
Quick Test - Run Everything (Option 6)
Press 6 on your keyboard

Press Enter

Watch as ALL 5 tools run automatically

A report will be saved to your computer

If You Get Any Error:
Error: "Running scripts is disabled"
Run this FIRST, then try again:

powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Error: "Cannot connect to GitHub"
Make sure you have internet connection and repository is public

Error: "Access Denied"
You MUST run PowerShell as Administrator

Complete Example - What You Type:
powershell
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\WINDOWS\system32> irm https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.ps1 | iex

===== NETWORK TOOLKIT =====

 1. 📶 WiFi Password Manager
 2. 📊 Network Speed Tester
 3. 📁 LAN File Share
 4. 🌐 IP Scanner
 5. 📈 Network Usage Monitor
 6. 🚀 RUN ALL TOOLS
 7. 🚪 Exit

Choose option (1-7): 6

[Toolkit runs automatically...]
Files Created on Your Computer
After running Option 6, you'll find:

wifi_backup_2026-06-13_14-30.txt - Your saved WiFi passwords

network_report_2026-06-13_14-30.txt - Complete diagnostic report

These save to the folder where you ran PowerShell (usually C:\WINDOWS\system32)

Need to Run Again Later?
Just open PowerShell as Administrator and paste:

powershell
irm https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.ps1 | iex
Video-Style Summary:
✅ Press Windows + X

✅ Click "Windows PowerShell (Admin)"

✅ Click "Yes"

✅ Copy this: irm https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.ps1 | iex

✅ Paste into PowerShell (right-click to paste)

✅ Press Enter

✅ Press 6 to run everything

✅ Done!


🐧 Complete Linux Setup
Step 1: Open Terminal
Press Ctrl + Alt + T on your keyboard

Step 2: Copy & Paste This ONE Command
bash
curl -sSL https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh | bash
That's it! Press Enter and the toolkit will start!

What Happens Next:
You'll see this menu:

text
===== NETWORK TOOLKIT =====

 1. 📶 WiFi Password Manager (view & backup)
 2. 📊 Network Speed Tester
 3. 📁 LAN File Share (P2P transfer)
 4. 🌐 IP Scanner (find devices on network)
 5. 📈 Network Usage Monitor
 6. 🚀 RUN ALL TOOLS (1-5 automatically)
 7. 🚪 Exit

Choose option (1-7):
Step 3: Choose What to Do
Press This Key	What Happens
1	Shows all saved WiFi passwords
2	Tests your internet speed
3	Shares a file on your network
4	Finds all devices on your WiFi
5	Shows which apps use bandwidth
6	Runs ALL tools automatically!
7	Exits the toolkit
Quick Test - Run Everything (Option 6)
Press 6 on your keyboard

Press Enter

Watch as ALL 5 tools run automatically

A report will be saved to your computer

If You Get Any Error:
Error: "curl: command not found"
Install curl first:

bash
# Ubuntu/Debian
sudo apt install curl -y

# Fedora
sudo dnf install curl -y

# Arch
sudo pacman -S curl
Error: "Permission denied"
The script will ask for your sudo password when needed. Type it (it won't show on screen).

Error: "bash: command not found"
Install bash:

bash
# Ubuntu/Debian
sudo apt install bash -y

# Fedora
sudo dnf install bash -y
Complete Example - What You Type:
bash
user@linux:~$ curl -sSL https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh | bash

===== NETWORK TOOLKIT =====

 1. 📶 WiFi Password Manager
 2. 📊 Network Speed Tester
 3. 📁 LAN File Share
 4. 🌐 IP Scanner
 5. 📈 Network Usage Monitor
 6. 🚀 RUN ALL TOOLS
 7. 🚪 Exit

Choose option (1-7): 6

[sudo] password for user: 
[Toolkit runs automatically...]
Files Created on Your Computer
After running Option 6, you'll find:

wifi_backup_2026-06-13_14-30.txt - Your saved WiFi passwords

network_report_2026-06-13_14-30.txt - Complete diagnostic report

These save to the folder where you ran the command (usually your home folder: ~/)

Need to Run Again Later?
Just open Terminal and paste:

bash
curl -sSL https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh | bash
Optional: Download and Save Permanently
If you want to keep the script on your computer:

bash
# Download the script
curl -O https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh

# Make it executable
chmod +x toolkit.sh

# Run it anytime with:
./toolkit.sh
Distribution-Specific Notes
Linux Distribution	Works?	Notes
Ubuntu 18.04+	✅ Yes	Full support
Debian 10+	✅ Yes	Full support
Fedora 35+	✅ Yes	Full support
Linux Mint 20+	✅ Yes	Full support
Arch Linux	✅ Yes	Full support
Pop!_OS	✅ Yes	Full support
Raspberry Pi OS	✅ Yes	Full support
Video-Style Summary:
✅ Press Ctrl + Alt + T

✅ Copy this: curl -sSL https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh | bash

✅ Paste into terminal (right-click or Ctrl+Shift+V)

✅ Press Enter

✅ Type your sudo password if asked

✅ Press 6 to run everything

✅ Done!

Both Windows & Linux Summary
Operating System	Command
Windows	irm https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.ps1 | iex
Linux	curl -sSL https://raw.githubusercontent.com/FaizHacke/network-toolkit/main/toolkit.sh | bash
That's it! Your network toolkit now works on BOTH Windows and Linux! 🚀🐧🪟
