@echo off
setlocal
title Garden Planner Web
cd /d "%~dp0"
echo Garden Planner Web Runner
echo Project: %cd%
echo.
where flutter >nul 2>nul
if errorlevel 1 goto no_flutter
echo Getting packages...
call flutter pub get
if errorlevel 1 goto failed
echo.
echo Starting Flutter web app...
call flutter run -d chrome
if errorlevel 1 goto try_web_server
goto end
:try_web_server
echo Chrome failed. Trying web-server on http://localhost:5000
start "" "http://localhost:5000"
call flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5000
if errorlevel 1 goto failed
goto end
:no_flutter
echo ERROR: Flutter was not found in PATH.
pause
exit /b 1
:failed
echo.
echo ERROR: Flutter web failed.
pause
exit /b 1
:end
echo.
echo Runner stopped.
pause
endlocal
