@echo off
echo ==========================================
echo    Admin User Setup Script
echo ==========================================
echo.

cd /d "%~dp0"
cd ..

echo Setting up admin user...
node scripts/setupAdmin.js

echo.
pause
