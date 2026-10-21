@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims=:" %%c in ('chcp') do set "OLDCP=%%c"
chcp 65001 >nul

set "DEST=%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins"
for %%i in ("%~dp0..") do set "REPO=%%~fi"

echo === WorkBuddy team environment check ===
echo.

echo [1] git
where git >nul 2>&1
if errorlevel 1 (
  echo     MISSING - install Git for Windows
) else (
  for /f "delims=" %%v in ('git --version') do echo     %%v
)

echo.
echo [2] python
set "PYFOUND="
where python >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%v in ('python --version 2^>^&1') do echo     python  %%v
  set "PYFOUND=1"
)
where python3 >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%v in ('python3 --version 2^>^&1') do echo     python3 %%v
  set "PYFOUND=1"
)
if not defined PYFOUND echo     MISSING - expert-manager scripts need Python 3

echo.
echo [3] expert plugins directory
if exist "%DEST%" (
  echo     OK      %DEST%
) else (
  echo     MISSING %DEST%
  echo             Run scripts\link-expert.cmd after creating the expert package
)

echo.
echo [4] experts in plugins directory
if exist "%DEST%" (
  set "ANY="
  for /d %%d in ("%DEST%\*") do (
    fsutil reparsepoint query "%%d" >nul 2>&1
    if errorlevel 1 (
      echo     [REAL] %%~nxd   - not linked to repo, edits will not sync
    ) else (
      echo     [LINK] %%~nxd   - synced with repo
    )
    set "ANY=1"
  )
  if not defined ANY echo     none yet
) else (
  echo     skipped
)

echo.
echo [5] repo root
echo     %REPO%

echo.
echo [6] git remote
git -C "%REPO%" remote -v 2>nul
if errorlevel 1 (
  echo     none - set one with: git remote add origin ^<url^>
) else (
  git -C "%REPO%" remote -v 2>nul | findstr /r "." >nul
  if errorlevel 1 echo     none - set one with: git remote add origin ^<url^>
)

echo.
echo === Done ===
chcp %OLDCP% >nul
exit /b 0
