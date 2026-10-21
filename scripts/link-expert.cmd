@echo off
setlocal

for /f "tokens=2 delims=:" %%c in ('chcp') do set "OLDCP=%%c"
chcp 65001 >nul

if "%~1"=="" (
  echo Usage: link-expert.cmd ^<expert-dir-name^>
  echo Example: link-expert.cmd campus-service
  exit /b 1
)

set "EXPERT=%~1"
for %%i in ("%~dp0..") do set "REPO=%%~fi"
set "DEST=%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins"

if not exist "%REPO%\%EXPERT%\" (
  echo [ERROR] Expert directory not found in repo:
  echo         %REPO%\%EXPERT%
  exit /b 1
)

if not exist "%DEST%" mkdir "%DEST%" 2>nul

if exist "%DEST%\%EXPERT%" (
  echo [SKIP] Target already exists:
  echo        %DEST%\%EXPERT%
  echo        Run unlink-expert.cmd %EXPERT% first to relink.
  exit /b 1
)

mklink /J "%DEST%\%EXPERT%" "%REPO%\%EXPERT%"
if errorlevel 1 (
  echo [ERROR] mklink failed.
  exit /b 1
)

echo.
echo [OK] Junction created:
echo      %DEST%\%EXPERT%
echo      -^> %REPO%\%EXPERT%
echo.
echo Restart WorkBuddy or reopen Expert Center to pick it up.
chcp %OLDCP% >nul
exit /b 0
