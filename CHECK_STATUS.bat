@echo off
title Check Backend Status
color 0E

echo.
echo ========================================================
echo    Checking Backend Services Status
echo ========================================================
echo.

echo [Checking Main Backend API - Port 3000]
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/health' -TimeoutSec 3 -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '✅ Main Backend API is RUNNING' -ForegroundColor Green } } catch { Write-Host '❌ Main Backend API is NOT RUNNING' -ForegroundColor Red; Write-Host '   Solution: Run START_ALL_SERVERS.bat or manually start backend Mongo' -ForegroundColor Yellow }"

echo.
echo [Checking Admin Backend API - Port 5000]
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5000/api/admin/auth/check' -TimeoutSec 3 -UseBasicParsing -ErrorAction SilentlyContinue; Write-Host '✅ Admin Backend API is RUNNING' -ForegroundColor Green } catch { if ($_.Exception.Response.StatusCode.value__ -eq 401) { Write-Host '✅ Admin Backend API is RUNNING (Auth required)' -ForegroundColor Green } else { Write-Host '❌ Admin Backend API is NOT RUNNING' -ForegroundColor Red; Write-Host '   Solution: Run START_ALL_SERVERS.bat or cd admin/backend && npm start' -ForegroundColor Yellow } }"

echo.
echo [Checking Admin Frontend - Port 3001]
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3001' -TimeoutSec 3 -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '✅ Admin Frontend is RUNNING' -ForegroundColor Green } } catch { Write-Host '❌ Admin Frontend is NOT RUNNING' -ForegroundColor Red; Write-Host '   Solution: Run START_ALL_SERVERS.bat or cd admin/frontend && npm run dev' -ForegroundColor Yellow }"

echo.
echo ========================================================
echo.
echo If any service shows ❌, run: START_ALL_SERVERS.bat
echo.
echo ========================================================
pause
