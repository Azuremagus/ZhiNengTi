@echo off
setlocal

for /f "tokens=2 delims=:" %%c in ('chcp') do set "OLDCP=%%c"
chcp 65001 >nul

if "%~1"=="" (
  echo Usage: unlink-expert.cmd ^<expert-dir-name^>
  exit /b 1
)

set "EXPERT=%~1"
set "DEST=%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins\%EXPERT%"

if not exist "%DEST%" (
  echo [SKIP] Not found: %DEST%
  exit /b 1
)

fsutil reparsepoint query "%DEST%" >nul 2>&1
if errorlevel 1 (
  echo [REFUSE] This path is a real directory, not a junction:
  echo          %DEST%
  echo.
  echo This script only removes junctions. Deleting a real directory would
  echo destroy source files. Back it up and remove it manually if intended.
  exit /b 1
)

rmdir "%DEST%"
if errorlevel 1 (
  echo [ERROR] Failed to remove junction.
  exit /b 1
)

echo [OK] Junction removed: %DEST%
echo      Source files in the repo are untouched.
chcp %OLDCP% >nul
exit /b 0
