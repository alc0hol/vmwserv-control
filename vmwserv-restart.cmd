@echo off

rem # known vmware service names.
set servnames="VMAuthdService" "VMnetDHCP" "VMware NAT Service" "VMUSBArbService"

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
fsutil dirty query %SYSTEMDRIVE% 1>nul 2>nul
if "%ERRORLEVEL%" == "0" ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "ELEV " >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
if "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (
    "%SYSTEMROOT%\SysWOW64\wscript.exe" "%vbsGetPrivileges%" %*
) else (
    "%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
)
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

rem # restart services.
for %%a in (%servnames%) do (
    for /F "tokens=3 delims=: " %%H in ('sc query %%a ^| findstr "STATE"') do (
      if /I "%%H" NEQ "STOPPED" (
          echo Restarting %%a...
          sc stop %%a 1>nul 2>nul
          if "%ERRORLEVEL%" neq "0" (
              echo An error occurred trying to stop service %%a. Error Code: %ERRORLEVEL%.
          )
          timeout 1 /nobreak >nul
          sc start %%a 1>nul 2>nul
          if "%ERRORLEVEL%" neq "0" (
              echo An error occurred trying to start service %%a. Error Code: %ERRORLEVEL%.
          )
      ) else (
          echo Service %%a was not running, attempting to start it...
          sc start %%a 1>nul 2>nul
          if "%ERRORLEVEL%" neq "0" (
              echo An error occurred trying to start service %%a. Error Code: %ERRORLEVEL%.
          )
      )
    )
)
echo done.
pause