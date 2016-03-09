:: W razie problemów spróbuj "Uruchomić jako administrator" / Try to "Run as administrator" in case of problems
:: Skrypt został sprawdzony na: / Script was tested on:
:: - Win 10 64-bit
:: - Win 7 32-bit (by Nycer)

@echo off

set CACHE_PATH=
set FINAL_PATH=
set ERROR_MESSAGE=
set CACHE_PATH_VALUE_NAME=File Cache Path
if exist "%PROGRAMFILES(X86)%" (
	set MTA_COMMON_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Multi Theft Auto: San Andreas All\Common
) else (
	set MTA_COMMON_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Multi Theft Auto: San Andreas All\Common
)

:: Lang codes: https://www.microsoft.com/resources/msdn/goglobal/default.mspx?OS=Windows+Vista
for /F "tokens=3 delims= " %%G in ('reg query "hklm\system\controlset001\control\nls\language" /v Installlanguage') DO (
	if [%%G] equ [0415] (
	  set LANG=PL
	) else (
	  set LANG=%%G
	)
)

reg query "%MTA_COMMON_KEY%" /v "%CACHE_PATH_VALUE_NAME%" 2>nul || goto NOT_FOUND_REG
for /f "tokens=4,*" %%a in ('reg query "%MTA_COMMON_KEY%" /v "%CACHE_PATH_VALUE_NAME%" ^| findstr "%CACHE_PATH_VALUE_NAME%"') do (
    set CACHE_PATH=%%b
)

if not defined CACHE_PATH goto NOT_FOUND_REG
set FINAL_PATH=%CACHE_PATH%\priv
if not exist "%FINAL_PATH%" goto NOT_FOUND_DIR

start explorer "%FINAL_PATH%"
goto EXIT

:NOT_FOUND_DIR
set CACHE_PATH=%CACHE_PATH:(=^^(%
set CACHE_PATH=%CACHE_PATH:)=^^)%
set FINAL_PATH=%FINAL_PATH:)=^)%
set FINAL_PATH=%FINAL_PATH:)=^^)%

if [%LANG%] equ [PL] (
  set ERROR_MESSAGE=Znaleziono wartość ^(%CACHE_PATH%^) w rejestrze, ale folder ^(%FINAL_PATH%^) nie istnieje na dysku
) else (
  set ERROR_MESSAGE=Found value ^(%CACHE_PATH%^) in registry, but folder ^(%FINAL_PATH%^) does not exist
)
goto ERROR

:NOT_FOUND_REG
if [%LANG%] equ [PL] (
  set ERROR_MESSAGE=Brak wartości w rejestrze
) else (
  set ERROR_MESSAGE=Missing value in registry
)
goto ERROR

:ERROR
echo MSGBOX "%ERROR_MESSAGE%", 16, "Error" > %temp%\fpdmsg.vbs
echo %ERROR_MESSAGE%
call %temp%\fpdmsg.vbs
del %temp%\fpdmsg.vbs /f /q
exit /b 1

:EXIT