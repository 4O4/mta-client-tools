@echo off

:: Configuration
set MAX_RETRIES=100
set CONNECTION_URI=mtasa://127.0.0.1:22010
set LOG_PATH=server\mods\deathmatch\logs\editor_server.log
set WATCH_PHRASE=Server started and is ready to accept connections
set SERVER_CONFIG_FILE=editor.conf
:: End of configuration

set INITIAL_PHRASE_COUNT=0
set CURRENT_PHRASE_COUNT=0
set COUNTER=0

:: Lang codes: https://www.microsoft.com/resources/msdn/goglobal/default.mspx?OS=Windows+Vista
for /F "tokens=3 delims= " %%G in ('reg query "hklm\system\controlset001\control\nls\language" /v Installlanguage') DO (
	if [%%G] equ [0415] (
	  set LANG=PL
	) else (
	  set LANG=%%G
	)
)

if not exist "server/MTA Server.exe" goto WRONG_SCRIPT_LOCATION
if not exist "Multi Theft Auto.exe" goto WRONG_SCRIPT_LOCATION

for /f %%a in ('type "%LOG_PATH%" ^| find "%WATCH_PHRASE%" /c') do set INITIAL_PHRASE_COUNT=%%a
start "" "server/MTA Server.exe" --config %SERVER_CONFIG_FILE%
start "" "Multi Theft Auto.exe"

:PHRASE_WATCHER
set /a COUNTER=%COUNTER% + 1
timeout /t 1 > nul
for /f %%a in ('type "%LOG_PATH%" ^| find "%WATCH_PHRASE%" /c') do set CURRENT_PHRASE_COUNT=%%a
if %COUNTER% geq %MAX_RETRIES% goto MAX_RETRIES_EXCEEDED
if %CURRENT_PHRASE_COUNT% GTR %INITIAL_PHRASE_COUNT% goto CONNECT
goto PHRASE_WATCHER

:CONNECT
start %CONNECTION_URI%
goto EXIT

:MAX_RETRIES_EXCEEDED
if [%LANG%] equ [PL] (
  set ERROR_MESSAGE=Serwer Map Editor wciąż nie jest gotowy. Nie zostaniesz połączony automatycznie.
) else (
  set ERROR_MESSAGE=Map Editor server does not seem to be ready yet. You will not be connected automatically.
)
goto ERROR

:WRONG_SCRIPT_LOCATION
if [%LANG%] equ [PL] (
  set ERROR_MESSAGE=Ten skrypt musi znajdować się w głównym katalogu MTA: San Andreas
) else (
  set ERROR_MESSAGE=This script must be placed in the main directory of MTA: San Andreas
)
goto ERROR

:ERROR
echo MSGBOX "%ERROR_MESSAGE%", 16, "Error" > %temp%\melnchrmsg.vbs
echo %ERROR_MESSAGE%
call %temp%\melnchrmsg.vbs
del %temp%\melnchrmsg.vbs /f /q
exit /b 1


:EXIT