@echo off
title 4Sale App Launcher
cls
echo ============================================
echo      4Sale App - Quick Launcher
echo ============================================
echo.
echo  [1] Start Backend (Django)
echo  [2] Start App (Flutter)
echo  [3] Start BOTH (Recommended)
echo.
set /p choice="Enter your choice (1, 2, or 3): "

if "%choice%"=="1" (
    start cmd /k "start_backend.bat"
    exit
)
if "%choice%"=="2" (
    cd flutter_app
    flutter run
    pause
    exit
)
if "%choice%"=="3" (
    echo Starting Backend in a new window...
    start cmd /k "start_backend.bat"
    echo.
    echo Starting Flutter App...
    cd flutter_app
    flutter run
    pause
    exit
)

echo Invalid choice. Press any key to exit.
pause
