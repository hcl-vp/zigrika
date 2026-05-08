@echo off
title Start Zigrika
echo By DynamiByte
echo.
setlocal EnableExtensions EnableDelayedExpansion

set "ZIG_VERSION=0.16.0"
set "ZIG_DIST=zig-x86_64-windows-%ZIG_VERSION%"
set "DIRENV_DIR=%CD%\.direnv"
set "ZIG_DIR=%DIRENV_DIR%\%ZIG_DIST%"
set "ZIG_EXE=%ZIG_DIR%\zig.exe"
set "ZIG_ZIP=%DIRENV_DIR%\%ZIG_DIST%.zip"
set "ZIG_URL=https://ziglang.org/download/%ZIG_VERSION%/%ZIG_DIST%.zip"

for /f "delims=" %%V in ('zig version 2^>nul') do set "PATH_ZIG_VERSION=%%V"
if /i "!PATH_ZIG_VERSION!"=="%ZIG_VERSION%" goto :run_commands

if exist "%ZIG_EXE%" (
    set "LOCAL_ZIG_VERSION="
    for /f "delims=" %%V in ('"%ZIG_EXE%" version 2^>nul') do set "LOCAL_ZIG_VERSION=%%V"
    if /i "!LOCAL_ZIG_VERSION!"=="%ZIG_VERSION%" (
        set "PATH=%ZIG_DIR%;%PATH%"
        goto :run_commands
    )
)

if not exist "%DIRENV_DIR%" mkdir "%DIRENV_DIR%"
if exist "%ZIG_ZIP%" del /f /q "%ZIG_ZIP%"
if exist "%ZIG_DIR%" rmdir /s /q "%ZIG_DIR%"

echo Downloading Zig %ZIG_VERSION%...
curl.exe -L --progress-bar --ssl-no-revoke -o "%ZIG_ZIP%" "%ZIG_URL%"
if errorlevel 1 goto :fail

echo Extracting Zig...
"%SystemRoot%\System32\tar.exe" -xf "%ZIG_ZIP%" -C "%DIRENV_DIR%"
if errorlevel 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$ErrorActionPreference='Stop'; Expand-Archive -LiteralPath '%ZIG_ZIP%' -DestinationPath '%DIRENV_DIR%' -Force"
    if errorlevel 1 goto :fail
)

del /f /q "%ZIG_ZIP%"
if not exist "%ZIG_EXE%" goto :fail

set "PATH=%ZIG_DIR%;%PATH%"

:run_commands
start "" /d "%CD%" powershell -NoExit -Command "Start-Process zig -ArgumentList 'build run-cfgsv -Doptimize=ReleaseSmall' -NoNewWindow; Start-Process zig -ArgumentList 'build run-loginsv -Doptimize=ReleaseSmall' -NoNewWindow; zig build run-gamesv -Doptimize=ReleaseSmall"
endlocal
exit /b

:fail
echo Failed to prepare Zig.
pause
endlocal
exit /b 1