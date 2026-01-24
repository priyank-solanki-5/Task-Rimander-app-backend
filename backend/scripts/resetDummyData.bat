@echo off
echo ========================================
echo   Reset Database with Fresh Dummy Data
echo ========================================
echo.
echo WARNING: This will DELETE ALL existing data!
echo.
set /p confirm="Are you sure you want to continue? (y/n): "

if /i not "%confirm%"=="y" (
    echo.
    echo Operation cancelled.
    echo ========================================
    pause
    exit /b
)

echo.
echo Step 1: Clearing database...
echo ========================================

cd /d "%~dp0.."
node scripts/clearDatabase.js

echo.
echo Step 2: Adding fresh dummy data...
echo ========================================

node scripts/initializeDatabase.js

echo.
echo ========================================
echo   Process completed!
echo ========================================
pause
