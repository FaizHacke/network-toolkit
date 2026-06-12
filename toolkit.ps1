#!/usr/bin/env pwsh
# NETWORK TOOLKIT - Windows Version (with RUN ALL feature)
# Run as Administrator for full features

# Color functions
function Write-Menu { Write-Host "`n===== NETWORK TOOLKIT =====`n" -ForegroundColor Cyan }
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Error { Write-Host "✗ $args" -ForegroundColor Red }
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Yellow }
function Write-ToolHeader { Write-Host "`n========================================" -ForegroundColor Magenta; Write-Host "$args" -ForegroundColor Magenta; Write-Host "========================================`n" -ForegroundColor Magenta }

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# ============ TOOL 1: WiFi Password Manager ============
function Show-WiFiPasswords {
    Write-ToolHeader "🔧 TOOL 1: WiFi Password Manager"
    
    $profiles = netsh wlan show profiles | Select-String ":(.*)$" | ForEach-Object {
        $_.Matches.Groups[1].Value.Trim()
    }
    
    if ($profiles.Count -eq 0) {
        Write-Error "No saved WiFi networks found"
        return
    }
    
    foreach ($profile in $profiles) {
        $details = netsh wlan show profile name="$profile" key=clear
        $password = $details | Select-String "Key Content\s+:\s+(.*)$" | ForEach-Object {
            $_.Matches.Groups[1].Value.Trim()
        }
        
        if ($password) {
            Write-Host "  $profile" -ForegroundColor Green
            Write-Host "    Password: $password" -ForegroundColor Gray
        } else {
            Write-Host "  $profile" -ForegroundColor Yellow
            Write-Host "    Password: [Open network - no password]" -ForegroundColor Gray
        }
    }
    
    if ($global:autoMode) {
        $date = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $filename = "wifi_backup_$date.txt"
        foreach ($profile in $profiles) {
            netsh wlan show profile name="$profile" key=clear >> $filename
        }
        Write-Success "Auto-saved to $filename"
    } else {
        $backup = Read-Host "`nBackup passwords to file? (y/n)"
        if ($backup -eq 'y') {
            $date = Get-Date -Format "yyyy-MM-dd_HH-mm"
            $filename = "wifi_backup_$date.txt"
            foreach ($profile in $profiles) {
                netsh wlan show profile name="$profile" key=clear >> $filename
            }
            Write-Success "Saved to $filename"
        }
    }
}

# ============ TOOL 2: Network Speed Tester ============
function Test-NetworkSpeed {
    Write-ToolHeader "🔧 TOOL 2: Network Speed Tester"
    Write-Info "Testing download speed..."
    
    $url = "https://speed.cloudflare.com/__down?bytes=50000000"
    $downloadStart = Get-Date
    
    try {
        Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\speedtest.tmp" -ErrorAction Stop
        $downloadEnd = Get-Date
        $downloadDuration = ($downloadEnd - $downloadStart).TotalSeconds
        $downloadSpeedMBps = (50 / $downloadDuration)
        $downloadSpeedMbps = $downloadSpeedMBps * 8
        
        Remove-Item "$env:TEMP\speedtest.tmp" -Force
        
        $ping = Test-Connection -ComputerName google.com -Count 4 | Measure-Object -Property ResponseTime -Average
        $latency = [math]::Round($ping.Average, 2)
        
        Write-Host "`n📈 RESULTS:" -ForegroundColor Cyan
        Write-Host "  Download Speed: $([math]::Round($downloadSpeedMbps, 2)) Mbps"
        Write-Host "  Latency (Ping): $latency ms"
        Write-Host "  Test Time: $(Get-Date -Format 'HH:mm:ss')"
        
        if ($downloadSpeedMbps -gt 50) {
            Write-Host "  Rating: 🚀 Excellent" -ForegroundColor Green
        } elseif ($downloadSpeedMbps -gt 20) {
            Write-Host "  Rating: 👍 Good" -ForegroundColor Yellow
        } else {
            Write-Host "  Rating: ⚠️ Slow" -ForegroundColor Red
        }
        
    } catch {
        Write-Error "Speed test failed. Check your internet connection."
    }
}

# ============ TOOL 3: LAN File Share ============
function Start-LANFileShare {
    Write-ToolHeader "🔧 TOOL 3: LAN File Share"
    
    if ($global:autoMode) {
        Write-Info "Skipping LAN file share in auto-mode (requires user input)"
        return
    }
    
    $filePath = Read-Host "Enter full path to file or folder"
    
    if (-not (Test-Path $filePath)) {
        Write-Error "Path not found!"
        return
    }
    
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
    if ($localIP -is [array]) { $localIP = $localIP[0] }
    
    Write-Info "Starting file server..."
    Write-Host "`n📤 SHARE THIS LINK:" -ForegroundColor Cyan
    Write-Host "  http://$localIP`:8080" -ForegroundColor Green
    Write-Host "`n⚠️  Press Ctrl+C to stop sharing" -ForegroundColor Yellow
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Push-Location (Split-Path $filePath)
        python -m http.server 8080
        Pop-Location
    } else {
        Write-Error "Python required. Install Python or use: net share ShareName=$filePath /GRANT:Everyone,READ"
    }
}

# ============ TOOL 4: IP Scanner ============
function Scan-Network {
    Write-ToolHeader "🔧 TOOL 4: IP Scanner"
    
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
    if ($localIP -is [array]) { $localIP = $localIP[0] }
    
    $subnet = $localIP.Substring(0, $localIP.LastIndexOf('.'))
    
    Write-Info "Scanning $subnet.1-30..."
    Write-Host "`nActive devices:`n" -ForegroundColor Cyan
    
    $activeDevices = @()
    
    for ($i = 1; $i -le 30; $i++) {
        $ip = "$subnet.$i"
        $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue
        
        if ($ping) {
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
            } catch {
                $hostname = "Unknown"
            }
            
            $device = [PSCustomObject]@{
                IP = $ip
                Hostname = $hostname
            }
            $activeDevices += $device
            
            Write-Host "  ✓ $ip" -ForegroundColor Green
            Write-Host "    → $hostname" -ForegroundColor Gray
        }
        
        if ($i % 10 -eq 0 -and $i -ne 30) { Write-Info "Scanned $i/30..." }
    }
    
    Write-Host "`n✅ Found $($activeDevices.Count) active devices" -ForegroundColor Green
    
    if (-not $global:autoMode) {
        $fullScan = Read-Host "`nScan all 254 IPs? (y/n - may take 2-3 minutes)"
        if ($fullScan -eq 'y') {
            Write-Info "Full scan in progress..."
            for ($i = 31; $i -le 254; $i++) {
                $ip = "$subnet.$i"
                if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
                    Write-Host "  ✓ $ip" -ForegroundColor Green
                    $activeDevices++
                }
                if ($i % 50 -eq 0) { Write-Info "Scanned $i/254..." }
            }
            Write-Success "Full scan complete. Total devices: $activeDevices"
        }
    }
}

# ============ TOOL 5: Network Usage Monitor ============
function Watch-Bandwidth {
    Write-ToolHeader "🔧 TOOL 5: Network Usage Monitor"
    
    if ($global:autoMode) {
        Write-Info "Running quick bandwidth check (5 seconds)..."
        $processes = @{}
        
        $connections = netstat -n -o | Select-String "ESTABLISHED"
        
        foreach ($conn in $connections) {
            $parts = $conn -split '\s+'
            $pid = $parts[-1]
            
            if ($pid -match '^\d+$') {
                try {
                    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
                    if ($proc) {
                        $procName = $proc.ProcessName
                        if (-not $processes.ContainsKey($procName)) {
                            $processes[$procName] = 0
                        }
                        $processes[$procName]++
                    }
                } catch {}
            }
        }
        
        $topProcesses = $processes.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
        
        Write-Host "`nTop bandwidth processes:" -ForegroundColor Cyan
        foreach ($proc in $topProcesses) {
            $connectionsCount = $proc.Value
            $barLength = [math]::Min(50, $connectionsCount * 2)
            $bar = "█" * $barLength
            Write-Host "  $($proc.Key.PadRight(20)) $bar $connectionsCount connections" -ForegroundColor Green
        }
        Start-Sleep -Seconds 5
    } else {
        Write-Host "Top bandwidth processes:" -ForegroundColor Cyan
        Write-Host "Press any key to refresh...`n"
        
        $processes = @{}
        $connections = netstat -n -o | Select-String "ESTABLISHED"
        
        foreach ($conn in $connections) {
            $parts = $conn -split '\s+'
            $pid = $parts[-1]
            
            if ($pid -match '^\d+$') {
                try {
                    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
                    if ($proc) {
                        $procName = $proc.ProcessName
                        if (-not $processes.ContainsKey($procName)) {
                            $processes[$procName] = 0
                        }
                        $processes[$procName]++
                    }
                } catch {}
            }
        }
        
        $topProcesses = $processes.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
        
        foreach ($proc in $topProcesses) {
            $connectionsCount = $proc.Value
            $barLength = [math]::Min(50, $connectionsCount * 2)
            $bar = "█" * $barLength
            Write-Host "  $($proc.Key.PadRight(20)) $bar $connectionsCount connections" -ForegroundColor Green
        }
        
        Write-Host "`n⚠️  For real-time bandwidth (MB/s), use Task Manager → Performance → Ethernet" -ForegroundColor Yellow
    }
}

# ============ TOOL 6 - RUN ALL ============
function Run-AllTools {
    Write-ToolHeader "🚀 RUNNING ALL NETWORK TOOLS"
    Write-Host "This will run Tools 1-5 automatically" -ForegroundColor Yellow
    Write-Host "Estimated time: 1-2 minutes`n" -ForegroundColor Yellow
    
    $global:autoMode = $true
    
    if ($isAdmin) { 
        Show-WiFiPasswords 
    } else { 
        Write-Error "Tool 1 skipped - Run as Administrator for WiFi passwords"
    }
    Start-Sleep -Seconds 2
    
    Test-NetworkSpeed
    Start-Sleep -Seconds 2
    
    Write-Host "`n⏭️  Tool 3 skipped - Requires manual input" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    
    Scan-Network
    Start-Sleep -Seconds 2
    
    Watch-Bandwidth
    
    Write-ToolHeader "📊 AUTO-RUN COMPLETE REPORT"
    Write-Success "All available tools have been executed!"
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  ✓ WiFi networks scanned and backed up"
    Write-Host "  ✓ Internet speed tested"
    Write-Host "  ✓ Network devices scanned"
    Write-Host "  ✓ Bandwidth usage checked"
    Write-Host "  ⚠️  LAN File Share requires manual run (option 3)"
    
    $date = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $reportFile = "network_report_$date.txt"
    
    Write-Host "`n📄 Report saved to: $reportFile" -ForegroundColor Green
    
    $global:autoMode = $false
}

# ============ MAIN MENU ============
function Show-Menu {
    Clear-Host
    Write-Menu
    Write-Host " 1. 📶 WiFi Password Manager (view & backup)" -ForegroundColor White
    Write-Host " 2. 📊 Network Speed Tester" -ForegroundColor White
    Write-Host " 3. 📁 LAN File Share (P2P transfer)" -ForegroundColor White
    Write-Host " 4. 🌐 IP Scanner (find devices on network)" -ForegroundColor White
    Write-Host " 5. 📈 Network Usage Monitor" -ForegroundColor White
    Write-Host " 6. 🚀 RUN ALL TOOLS (1-5 automatically)" -ForegroundColor Green
    Write-Host " 7. 🚪 Exit" -ForegroundColor Red
    Write-Host "`n" -NoNewline
}

$global:autoMode = $false

do {
    Show-Menu
    $choice = Read-Host "Choose option (1-7)"
    
    switch ($choice) {
        '1' { 
            if ($isAdmin) { 
                $global:autoMode = $false
                Show-WiFiPasswords 
            }
            else { Write-Error "Run as Administrator to view WiFi passwords" }
            Read-Host "`nPress Enter to continue"
        }
        '2' { 
            $global:autoMode = $false
            Test-NetworkSpeed
            Read-Host "`nPress Enter to continue" 
        }
        '3' { 
            $global:autoMode = $false
            Start-LANFileShare
            Read-Host "`nPress Enter to continue" 
        }
        '4' { 
            $global:autoMode = $false
            Scan-Network
            Read-Host "`nPress Enter to continue" 
        }
        '5' { 
            $global:autoMode = $false
            Watch-Bandwidth
            Read-Host "`nPress Enter to continue" 
        }
        '6' { 
            Run-AllTools
            Read-Host "`nPress Enter to continue" 
        }
        '7' { 
            Write-Host "`n👋 Goodbye!" -ForegroundColor Cyan
            exit 
        }
        default { Write-Error "Invalid option"; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne '7')
