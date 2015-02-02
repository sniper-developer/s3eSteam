@echo off
set curdir=%~dp0
set curdir=%curdir:~0,-1%
set curdir=%curdir:\=/%

type nul > quickuser_tolua.pkg
FOR %%i IN (quick/QSteamworks.h) DO (
    echo Adding package %%i
    echo $cfile "%curdir%/%%i" >> quickuser_tolua.pkg
)

echo Rebuilding quickuser tolua interface
%S3E_DIR%\..\quick\tools\tolua++ -o "%S3E_DIR%\..\quick\quickuser_tolua.cpp" "quickuser_tolua.pkg"
if errorlevel 1 echo An error occured while processing.

copy /Y quick\quickuser_template.mkf "%S3E_DIR%\..\quick\quickuser.mkf

powershell -Command "(gc %S3E_DIR%\..\quick\quickuser.mkf) -replace '__ext_path__', '%curdir%' | Out-File -encoding ASCII %S3E_DIR%\..\quick\quickuser.mkf"

pause
