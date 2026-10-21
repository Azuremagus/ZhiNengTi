@echo off
setlocal

for /f "tokens=2 delims=:" %%c in ('chcp') do set "OLDCP=%%c"
chcp 65001 >nul

if "%~1"=="" (
  echo Usage: sync-expert.cmd ^<expert-dir-name^>
  echo Example: sync-expert.cmd cs-research-studio
  echo.
  echo Mirrors ^<repo^>\^<expert^> to the WorkBuddy expert plugins directory.
  chcp %OLDCP% >nul
  exit /b 1
)

set "EXPERT=%~1"
for %%i in ("%~dp0..") do set "REPO=%%~fi"
set "DEST=%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins"

if not exist "%REPO%\%EXPERT%\" (
  echo [ERROR] Expert directory not found in repo:
  echo         %REPO%\%EXPERT%
  chcp %OLDCP% >nul
  exit /b 1
)

if not exist "%DEST%" mkdir "%DEST%" 2>nul

robocopy "%REPO%\%EXPERT%" "%DEST%\%EXPERT%" /MIR /XD .git /NFL /NDL /NJH /NP
set "RC=%ERRORLEVEL%"

rem robocopy exit codes: 0 = nothing to copy, 1-7 = copied / extra / mismatched, 8+ = failure
if %RC% GEQ 8 (
  echo [ERROR] robocopy failed with code %RC%
  chcp %OLDCP% >nul
  exit /b 1
)

rem settings.json is required for Team-type experts. Without it the Expert
rem Center will not display the package. robocopy /MIR occasionally drops it,
rem so copy it unconditionally as a safety net.
if exist "%REPO%\%EXPERT%\settings.json" (
  copy /Y "%REPO%\%EXPERT%\settings.json" "%DEST%\%EXPERT%\" >nul
  if errorlevel 1 (
    echo [ERROR] Failed to copy settings.json
    chcp %OLDCP% >nul
    exit /b 1
  )
)

echo.
echo [OK] Synced repo -^> %DEST%\%EXPERT%
echo      Restart WorkBuddy or reopen Expert Center if files were updated.
chcp %OLDCP% >nul
exit /b 0
