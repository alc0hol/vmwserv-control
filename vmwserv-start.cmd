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

echo.
rem # start service if it's stopped.
for %%a in (%servnames%) do (
    for /F "tokens=3 delims=: " %%H in ('sc query %%a ^| findstr "STATE"') do (
      if /I "%%H" NEQ "RUNNING" (
          echo Starting %%a...
          sc start %%a 1>nul 2>nul
          if "%ERRORLEVEL%" neq "0" (
              echo An error occurred trying to start service %%a. Error Code: %ERRORLEVEL%.
          )
      ) else (
          echo Service %%a is already running.
      )
    )
)
echo done.
