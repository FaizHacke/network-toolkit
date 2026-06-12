#!/usr/bin/env pwsh
# NETWORK TOOLKIT - Windows Version
# Run as Administrator for full features
# Create Windows Version (PowerShell)

# Color functions
function Write-Menu { Write-Host "`n===== NETWORK TOOLKIT =====`n" -ForegroundColor Cyan }
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Error { Write-Host "✗ $args" -ForegroundColor Red }
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Yellow }

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# ============ TOOL 1: WiFi Password Manager ============
function Show-WiFiPasswords {
    Write-Host "`n📶 SAVED WIFI NETWORKS:`n" -ForegroundColor Magenta
    
    $profiles = netsh wlan show profiles | Select-String ":(.*)$" | ForEach-Object {
        $_.Matches.Groups[1].Value.Trim()
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
    
    # Backup option
    Write-Host "`n" -NoNewline
    $backup = Read-Host "Backup passwords to file? (y/n)"
    if ($backup -eq 'y') {
        $date = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $filename = "wifi_backup_$date.txt"
        
        foreach ($profile in $profiles) {
            netsh wlan show profile name="$profile" key=clear >> $filename
        }
        Write-Success "Saved to $filename"
    }
}

# ============ TOOL 2: Network Speed Tester ============
function Test-NetworkSpeed {
    Write-Host "`n📊 TESTING NETWORK SPEED...`n" -ForegroundColor Magenta
    
    # Test download speed using PowerShell
    Write-Info "Download test..."
    $url = "https://speed.cloudflare.com/__down?bytes=50000000"  # 50MB test file
    $downloadStart = Get-Date
    
    try {
        Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\speedtest.tmp" -ErrorAction Stop
        $downloadEnd = Get-Date
        $downloadDuration = ($downloadEnd - $downloadStart).TotalSeconds
        $downloadSpeedMBps = (50 / $downloadDuration)  # 50MB / seconds
        $downloadSpeedMbps = $downloadSpeedMBps * 8
        
        Remove-Item "$env:TEMP\speedtest.tmp" -Force
        
        # Ping test (latency)
        $ping = Test-Connection -ComputerName google.com -Count 4 | Measure-Object -Property ResponseTime -Average
        $latency = [math]::Round($ping.Average, 2)
        
        # Display results
        Write-Host "`n📈 RESULTS:" -ForegroundColor Cyan
        Write-Host "  Download Speed: $([math]::Round($downloadSpeedMbps, 2)) Mbps"
        Write-Host "  Latency (Ping): $latency ms"
        Write-Host "  Test Time: $(Get-Date -Format 'HH:mm:ss')"
        
        # Speed rating
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
    Write-Host "`n📁 LAN FILE SHARE`n" -ForegroundColor Magenta
    
    $filePath = Read-Host "Enter full path to file or folder"
    
    if (-not (Test-Path $filePath)) {
        Write-Error "Path not found!"
        return
    }
    
    # Get local IP
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
    
    if ($localIP -is [array]) { $localIP = $localIP[0] }
    
    # Start simple HTTP server
    Write-Info "Starting file server..."
    Write-Host "`n📤 SHARE THIS LINK:" -ForegroundColor Cyan
    Write-Host "  http://$localIP`:8080" -ForegroundColor Green
    
    Write-Host "`n⚠️  Press Ctrl+C to stop sharing" -ForegroundColor Yellow
    
    # Python HTTP server (if available)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Push-Location (Split-Path $filePath)
        python -m http.server 8080
        Pop-Location
    } 
    # PowerShell alternative
    else {
        Write-Error "Python required for file sharing. Install Python or use: net share"
        Write-Info "Alternative Windows command: net share ShareName=$filePath /GRANT:Everyone,READ"
    }
}

# ============ TOOL 4: IP Scanner ============
function Scan-Network {
    Write-Host "`n🌐 SCANNING NETWORK FOR DEVICES...`n" -ForegroundColor Magenta
    
    # Get local subnet
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
    if ($localIP -is [array]) { $localIP = $localIP[0] }
    
    $subnet = $localIP.Substring(0, $localIP.LastIndexOf('.'))
    
    Write-Info "Scanning $subnet.1-254..."
    Write-Host "`nActive devices:`n" -ForegroundColor Cyan
    
    $activeDevices = @()
    
    # Scan common IPs (1-30 for speed, full scan optional)
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
        
        # Show progress
        if ($i % 10 -eq 0) { Write-Info "Scanned $i/30..." }
    }
    
    Write-Host "`n✅ Found $($activeDevices.Count) active devices" -ForegroundColor Green
    
    # Option for full scan
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

# ============ TOOL 5: Network Usage Monitor ============
function Watch-Bandwidth {
    Write-Host "`n📈 NETWORK USAGE MONITOR (Press Ctrl+C to stop)`n" -ForegroundColor Magenta
    
    Write-Host "Top bandwidth processes:" -ForegroundColor Cyan
    Write-Host "Press any key to refresh...`n"
    
    # Get network processes using netstat
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
    
    # Display top processes
    $topProcesses = $processes.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
    
    foreach ($proc in $topProcesses) {
        $connectionsCount = $proc.Value
        $barLength = [math]::Min(50, $connectionsCount * 2)
        $bar = "█" * $barLength
        
        Write-Host "  $($proc.Key.PadRight(20)) $bar $connectionsCount connections" -ForegroundColor Green
    }
    
    Write-Host "`n⚠️  For real-time bandwidth (MB/s), use Task Manager → Performance → Ethernet" -ForegroundColor Yellow
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
    Write-Host " 6. 🚪 Exit" -ForegroundColor Red
    Write-Host "`n" -NoNewline
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Choose option (1-6)"
    
    switch ($choice) {
        '1' { 
            if ($isAdmin) { Show-WiFiPasswords }
            else { Write-Error "Run as Administrator to view WiFi passwords" }
            Read-Host "`nPress Enter to continue"
        }
        '2' { Test-NetworkSpeed; Read-Host "`nPress Enter to continue" }
        '3' { Start-LANFileShare; Read-Host "`nPress Enter to continue" }
        '4' { Scan-Network; Read-Host "`nPress Enter to continue" }
        '5' { Watch-Bandwidth; Read-Host "`nPress Enter to continue" }
        '6' { Write-Host "`n👋 Goodbye!" -ForegroundColor Cyan; exit }
        default { Write-Error "Invalid option"; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne '6')
