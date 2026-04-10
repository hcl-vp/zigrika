@echo off
echo By DynamiByte
echo.
setlocal EnableExtensions EnableDelayedExpansion

set "MIN_BUILD=3133"
set "MAX_BUILD=3133"

set "ZIG_VERSION=0.16.0-dev.3133+5ec8e45f3"
set "ZIG_PLATFORM=x86_64-windows"
set "ZIG_DIST=zig-%ZIG_PLATFORM%-%ZIG_VERSION%"

set "BASE_DIR=%CD%"
set "DIRENV_DIR=%BASE_DIR%\.direnv"
set "ZIG_DIR=%DIRENV_DIR%\%ZIG_DIST%"
set "ZIG_EXE=%ZIG_DIR%\zig.exe"
set "ZIG_ZIP=%DIRENV_DIR%\%ZIG_DIST%.zip"
set "ZIG_URL=https://ziglang.org/builds/%ZIG_DIST%.zip"

set "FOUND_ZIG="
for /f "delims=" %%I in ('where zig 2^>nul') do (
    set "FOUND_ZIG=%%I"
    goto :got_path_zig
)

:got_path_zig
if defined FOUND_ZIG (
    for /f "delims=" %%V in ('zig version 2^>nul') do set "PATH_ZIG_VERSION=%%V"
    call :is_supported_version "!PATH_ZIG_VERSION!"
    if not errorlevel 1 goto :run_commands
)

if exist "%ZIG_EXE%" (
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
goto :end

:fail
echo Failed to prepare Zig.
pause

:end
endlocal
exit /b


:is_supported_version
setlocal EnableDelayedExpansion
set "VER=%~1"
if /i not "!VER:~0,11!"=="0.16.0-dev." exit /b 1
set "REST=!VER:~11!"
for /f "tokens=1 delims=+" %%A in ("!REST!") do set "BUILD=%%A"
for /f "delims=0123456789" %%A in ("!BUILD!") do exit /b 1
if !BUILD! LSS %MIN_BUILD% exit /b 1
if !BUILD! GTR %MAX_BUILD% exit /b 1
exit /b 0
