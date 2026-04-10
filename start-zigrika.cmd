@echo off
setlocal
title Zigging Around

:: Bypasses PowerShell Execution Policy and runs the code below
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((Get-Content '%~f0' | Select-Object -Skip 9 | Out-String))"
pause
exit /b

# --- HACKERY SHIT ---
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
Write-Host "        ZIGGING AROUND"         -ForegroundColor Magenta
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "1) Full Install & Build"
Write-Host "2) Run Zigrika (You must run 1 before you can use this)"
Write-Host "3) Cleanup & Remove Everything"
Write-Host "==============================" -ForegroundColor Cyan
$choice = Read-Host "Select an option (1, 2, or 3)"

function Start-And-Arrange-Services {
    $zigrikaPath = Join-Path $currentDir "zigrika"

    # Check if folder exists
    if (!(Test-Path $zigrikaPath)) {
        Write-Host "`nError: Zigrika folder not found. Please run Option 1 first." -ForegroundColor Red
        return $false
    }

    # Manually re-verify and inject Zig path in case the session lost it
    if (!(Get-Command zig -ErrorAction SilentlyContinue)) {
        $foundZig = Get-ChildItem -Path $installDir -Filter "zig.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($foundZig) {
            $env:Path = "$($foundZig.DirectoryName);$env:Path"
        } else {
            Write-Host "`nError: Zig compiler not found in $installDir. Please run Option 1." -ForegroundColor Red
            return $false
        }
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
    Set-Location $currentDir
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Git..." -ForegroundColor Yellow
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    $zigUrl = "https://ziglang.org/builds/zig-x86_64-windows-0.16.0-dev.3133+5ec8e45f3.zip"
    $zipFile = "$env:TEMP\zig.zip"

    if (!(Test-Path $installDir)) {
        Write-Host "Downloading Zig..." -ForegroundColor Yellow
        $oldPref = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $zigUrl -OutFile $zipFile
        Write-Host "Extracting Zig..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $installDir | Out-Null
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir)
        $ProgressPreference = $oldPref
    }

    $zigBinPath = Get-ChildItem -Path $installDir -Filter "zig.exe" -Recurse | Select-Object -ExpandProperty DirectoryName -First 1
    $env:Path = "$zigBinPath;$env:Path"

    if (!(Test-Path "zigrika")) {
        Write-Host "Cloning Zigrika..." -ForegroundColor Yellow
        git clone https://git.xeondev.com/WavyRooms/zigrika
    }

    $success = Start-And-Arrange-Services

    if ($success) {
        Set-Location $currentDir
        if (!(Test-Path "helios")) {
            Write-Host "Cloning Helios..." -ForegroundColor Yellow
            git clone https://git.xeondev.com/WavyRooms/helios
        }

        Set-Location "$currentDir\helios"
        Write-Host "Cooking Helios..." -ForegroundColor Yellow
        zig build

        $binDir = "$currentDir\helios\zig-out\bin"
        if (!(Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

        Write-Host "fetching rr_fixes_100_p.pak" -ForegroundColor Yellow
        $pakUrl = "https://git.xeondev.com/RabbyDevs/zigrika-pakfile/releases/download/3.2/rr_fixes_100_p.pak"
        $oldPref = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $pakUrl -OutFile (Join-Path $binDir "rr_fixes_100_p.pak")
        $ProgressPreference = $oldPref

        if (Test-Path $binDir) { explorer $binDir } else { explorer . }

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
    $success = Start-And-Arrange-Services
    if ($success) {
        Write-Host "`nZigrika is served." -ForegroundColor Gray
    }
}
elseif ($choice -eq "3") {
    Write-Host "`n--- Cleanup Options ---" -ForegroundColor Yellow
    Write-Host "1) Keep Git"
    Write-Host "2) Total Wipe"
    $cleanChoice = Read-Host "Select cleanup mode (1 or 2)"
    $processes = @("zigrika", "cfgsv", "loginsv", "gamesv", "zig")
    foreach ($proc in $processes) { Get-Process | Where-Object { $_.ProcessName -like "*$proc*" } | Stop-Process -Force -ErrorAction SilentlyContinue }
    Set-Location $currentDir
    $targetDirs = @("$env:USERPROFILE\zig-install", "zigrika", "helios", "$env:TEMP\zig.zip")
    foreach ($item in $targetDirs) { if (Test-Path $item) { Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue } }
    if ($cleanChoice -eq "2") { if (Get-Command git -ErrorAction SilentlyContinue) { winget uninstall --id Git.Git -e --source winget } }
    Write-Host "Cleanup Complete." -ForegroundColor Green
}
