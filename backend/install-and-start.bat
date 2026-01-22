@echo off
echo =====================================
echo Installing Dependencies...
echo =====================================
call npm install

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to install dependencies
    pause
    exit /b %errorlevel%
)

echo.
echo =====================================
echo Dependencies installed successfully!
echo Starting Main Backend API on port 3000...
echo =====================================
echo.
node server.js
