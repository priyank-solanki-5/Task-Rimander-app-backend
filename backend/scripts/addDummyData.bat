@echo off
echo ========================================
echo   Adding Dummy Data to Database
echo ========================================
echo.

cd /d "%~dp0.."
node scripts/initializeDatabase.js

echo.
echo ========================================
echo   Process completed!
echo ========================================
pause
