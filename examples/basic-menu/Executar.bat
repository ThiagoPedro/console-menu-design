@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "SCRIPT=%~dp0BasicMenu.ps1"
if not exist "%SCRIPT%" (
  echo [ERRO] BasicMenu.ps1 nao encontrado.
  exit /b 1
)
where pwsh.exe >nul 2>&1
if not errorlevel 1 (
  pwsh.exe -NoLogo -NoProfile -File "%SCRIPT%"
) else (
  powershell.exe -NoLogo -NoProfile -File "%SCRIPT%"
)
exit /b %ERRORLEVEL%
