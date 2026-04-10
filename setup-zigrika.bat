@echo off
setlocal
title Zigging Around

powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((Get-Content '%~f0' | Select-Object -Skip 9 | Out-String))"
pause
exit /b

# Powershell Hackery
$w = $Host.UI.RawUI
$size = $w.WindowSize
$size.Width = 120
$size.Height = 45
$w.BufferSize = $size
$w.WindowSize = $size

$currentDir = Get-Location
$installDir = "$env:USERPROFILE\zig-install"

Clear-Host
Write-Host "Made by Denuwo" -ForegroundColor Cyan
Write-Host @"
===...............................:....::::::::-........-==+=
=-........::::-=+++++=::::::--=+++++=::::::-++++=........:===
=.......::::::-+++***+=:::::-+++=-=+++::::++****+=.........==
.......=======++++***+*==+++=*+++==+++++=*++*++*++=:........-
......-========+*+**++*+++++++**+++++++++*++*+++++==-........
.....-=========++***+++++++++++++++++++++++****+*=====.......
....::::::::::--+*+++++++++++++++++++++++++++*++-::::::......
....::::::::=---+++++++++++++++++++++++++++++++=-::::::::....
...::::::::-+-:=++++*+++++*+++++++++++++*+++++++=-::::::::...
..:::::::::+===-=++++++++*+++++++++++++++*+++++++==::::::-:..
.:::::::::-=----=+=+*++++++++++++++*++++++*++++==--=---:-*=::
:::::::::=-==+++*+++*+++**+++++++++*+++**++*++++++++=++++++-:
::::::::-=+*+++*+++**+++**++++++*++#*+++*****+++++++++*+++--:
:::::::-=+*+++**+++++++=**++++++*++=++++=+++*++++++++++----::
::::::-=+*++++*+++*-++*-**+++++++++==+++-*++**++++++*+*+---::
::::::-=+*++++*++++-+*+-=+++++==++*--+#*=-+*************=----
------=+-*++******+-+*+=+#+==+===+*++--*=**##***********+----
------=+-*+*******#+:#***#+===+====:=####+:************+*----
------+--+*********+.==+=-:::===+===+***+--************-*----
------=--=**********-.............:-+=-.:++==*********+-*----
----------********+........................=*************===-
---------***********:.....................+**********--=+----
-------====-=*******:.......:=..-:......-:=*********=========
++++++++++++++*******-..................+##********++++++++++
+++++++++++++++******##*-...........:=*###*******++++++++++=.
===============++*****######+-==----#####*****#*==========-..
:----------------+*****#####**-----=*-##*#***##*=--------:...
..:--------------+*##**###=-*=-----+**-:+#*###*****=----.....
....---=*****#**#*#*****#:.=+=-----=+-..:*###*#+=-----:......
.....:-*########%########:.==+:-=-:-=-..:*:=#*=------:......:
.......-===*#########=+-:..==*+:::=*=-..-*:.-==+----.......--
-........--+*#######*-=:=-:+=+****++==::=::-=:=-----.....-+++
*+-........:*#######+:::::::::::::::::::::::::::::::::...-***
"@ -ForegroundColor Gray

Write-Host "`n==============================" -ForegroundColor Cyan
Write-Host "         ZIGGING AROUND"         -ForegroundColor Magenta
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "1) Full Install & Build"
Write-Host "2) Run Zigrika (You must run 1 before you can use this)"
Write-Host "3) Cleanup & Remove Everything"
Write-Host "==============================" -ForegroundColor Cyan
$choice = Read-Host "Select an option (1, 2, or 3)"

function Start-And-Arrange-Services {
    $zigrikaPath = Join-Path $currentDir "zigrika"
    if (!(Test-Path $zigrikaPath)) {
        Write-Host "`nError: Zigrika folder not found. Please run Option 1 first." -ForegroundColor Red
        return $false
    }

    if (!(Get-Command zig -ErrorAction SilentlyContinue)) {
        $foundZig = Get-ChildItem -Path $installDir -Filter "zig.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($foundZig) {
            if ($env:Path -notlike "*$($foundZig.DirectoryName)*") { $env:Path = "$($foundZig.DirectoryName);$env:Path" }
        }
        else { Write-Host "`nError: Zig not found. Run Option 1." -ForegroundColor Red; return $false }
    }

    Write-Host "`nCooking Zigrika..." -ForegroundColor Yellow
    Set-Location $zigrikaPath
    $p1 = Start-Process zig -ArgumentList "build run-cfgsv" -PassThru
    $p2 = Start-Process zig -ArgumentList "build run-loginsv" -PassThru
    $p3 = Start-Process zig -ArgumentList "build run-gamesv" -PassThru

    Start-Sleep -Seconds 5
    $signature = '[DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);'
    $type = Add-Type -MemberDefinition $signature -Name "Win32" -Namespace "Zigrika" -PassThru -ErrorAction SilentlyContinue
    if ($p1.MainWindowHandle -ne 0) { [Zigrika.Win32]::MoveWindow($p1.MainWindowHandle, 0, 0, 600, 400, $true) | Out-Null }
    if ($p2.MainWindowHandle -ne 0) { [Zigrika.Win32]::MoveWindow($p2.MainWindowHandle, 605, 0, 600, 400, $true) | Out-Null }
    if ($p3.MainWindowHandle -ne 0) { [Zigrika.Win32]::MoveWindow($p3.MainWindowHandle, 1210, 0, 600, 400, $true) | Out-Null }
    return $true
}

if ($choice -eq "1") {
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Git..." -ForegroundColor Yellow
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    if (!(Test-Path "zigrika")) { git clone https://git.xeondev.com/WavyRooms/zigrika | Out-Null }

    $tempJson = "$env:TEMP\zig_index.json"
    curl.exe -L -s "https://ziglang.org/download/index.json" -o $tempJson
    $index = Get-Content $tempJson | ConvertFrom-Json

    $zonPath = Join-Path $currentDir "zigrika\build.zig.zon"
    if (Test-Path $zonPath) {
        $zonContent = Get-Content $zonPath | Out-String
        if ($zonContent -match '\.minimum_zig_version\s*=\s*"([^"]+)"') {
            $minVersion = $Matches[1]
            $zigUrl = if ($index.$minVersion) { $index.$minVersion."x86_64-windows".tarball } else { $index.master."x86_64-windows".tarball }
        }
    }

    if (!(Test-Path $installDir)) {
        Write-Host "Downloading Zig..." -ForegroundColor Yellow
        curl.exe -L $zigUrl -o "$env:TEMP\zig.zip"
        if ((Get-Item "$env:TEMP\zig.zip").Length -gt 0) {
            Write-Host "Extracting Zig..." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
            tar.exe -xf "$env:TEMP\zig.zip" -C $installDir
        }
    }

    $zigBinPath = (Get-ChildItem -Path $installDir -Filter "zig.exe" -Recurse | Select-Object -First 1).DirectoryName
    if ($env:Path -notlike "*$zigBinPath*") { $env:Path = "$zigBinPath;$env:Path" }

    if (Start-And-Arrange-Services) {
        Set-Location $currentDir
        if (!(Test-Path "helios")) { git clone https://git.xeondev.com/WavyRooms/helios | Out-Null }
        Set-Location "helios"
        Write-Host "Cooking Helios..." -ForegroundColor Yellow
        zig build
        $binDir = "$currentDir\helios\zig-out\bin"
        if (!(Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }

        Write-Host "Fetching rr_fixes_100_p.pak...(patch)" -ForegroundColor Yellow
        curl.exe -L "https://git.xeondev.com/RabbyDevs/zigrika-pakfile/releases/download/3.2/rr_fixes_100_p.pak" -o "$binDir\rr_fixes_100_p.pak"

        explorer $binDir
        (New-Object -ComObject WScript.Shell).AppActivate($PID)

        Write-Host "`n********************************************************************************" -ForegroundColor Cyan
        Write-Host "COPY ALL HELIOS FILES INTO [Game Directory]/Client/Binaries/Win64" -ForegroundColor White -BackGroundColor Black
        Write-Host "COPY rr_fixes_100_p.pak INTO [Game Directory]/Client/Content/Paks" -ForegroundColor White -BackGroundColor Black
        Write-Host "WAIT FOR ALL 3 WINDOWS TO SAY LISTENING" -ForegroundColor White -BackGroundColor Black
        Write-Host "THEN LAUNCH helios_launcher.exe AS ADMINISTRATOR" -ForegroundColor White -BackGroundColor Black
        Write-Host "********************************************************************************" -ForegroundColor Cyan
    }
}
elseif ($choice -eq "2") {
    Start-And-Arrange-Services
}
elseif ($choice -eq "3") {
    Write-Host "`n--- Cleanup Options ---" -ForegroundColor Yellow
    Write-Host "1) Keep Git"
    Write-Host "2) Total Wipe (Uninstall Git)"
    $cleanChoice = Read-Host "Select cleanup mode (1 or 2)"

    Write-Host "Stopping processes..." -ForegroundColor Gray
    Get-Process | Where-Object { $_.ProcessName -match "zig|cfgsv|loginsv|gamesv" } | Stop-Process -Force -ErrorAction SilentlyContinue

    Set-Location $currentDir
    $targetDirs = @("$env:USERPROFILE\zig-install", "zigrika", "helios", "$env:TEMP\zig.zip", "$env:TEMP\zig_index.json")
    foreach ($item in $targetDirs) { if (Test-Path $item) { Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue } }

    if ($cleanChoice -eq "2") {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "Uninstalling Git..." -ForegroundColor Yellow
            winget uninstall --id Git.Git -e --source winget
        }
    }
    Write-Host "Cleanup Complete." -ForegroundColor Green
}
