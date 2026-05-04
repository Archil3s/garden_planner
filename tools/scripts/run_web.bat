@echo off
setlocal
cd /d "%~dp0..\.."
echo Starting Garden Planner web app...
echo.
flutter pub get
if errorlevel 1 goto error
flutter run -d chrome
goto end
:error
echo.
echo Failed to start Flutter web app.
pause
:end
endlocal
