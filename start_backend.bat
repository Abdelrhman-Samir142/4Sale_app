@echo off
echo ============================================
echo    4Sale Mobile - Backend Server Startup
echo ============================================

cd /d "%~dp0backend"

echo.
echo [1/2] Running database migrations...
python manage.py migrate

echo.
echo [2/2] Starting Django server on 0.0.0.0:8000...
echo.
echo Server URLs:
echo   - Emulator:  http://10.0.2.2:8000/api
echo   - Browser:   http://localhost:8000/api
echo   - Admin:     http://localhost:8000/admin
echo.
echo   Admin login: admin / admin123
echo.
echo Press Ctrl+C to stop the server
echo ============================================

python manage.py runserver 0.0.0.0:8000
