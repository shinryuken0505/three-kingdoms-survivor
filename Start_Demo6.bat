@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Always switch to the project folder first.
cd /d "%~dp0"

rem Preferred Godot location for this PC.
set "GODOT=%LOCALAPPDATA%\GodotPortable\Godot_v4.7.1-stable_win64.exe"

rem Optional override file. The first line must be the full EXE path.
if exist "Godot_Path.txt" (
    for /f "usebackq delims=" %%G in ("Godot_Path.txt") do (
        if exist "%%~G" set "GODOT=%%~G"
        goto GODOT_READY
    )
)

:GODOT_READY
if not exist "%GODOT%" goto GODOT_NOT_FOUND

echo Godot executable:
echo %GODOT%
echo.
echo Project folder:
echo %CD%
echo.
echo Starting Demo6 v1.4.0...
echo.

rem %CD% never ends with a backslash here, avoiding the escaped-quote bug.
"%GODOT%" --path "%CD%"
set "EXITCODE=%ERRORLEVEL%"

if not "%EXITCODE%"=="0" (
    echo.
    echo Godot exited with error code %EXITCODE%.
    echo Copy the complete error text for diagnosis.
    pause
)
exit /b %EXITCODE%

:GODOT_NOT_FOUND
echo Godot was not found at:
echo %LOCALAPPDATA%\GodotPortable\Godot_v4.7.1-stable_win64.exe
echo.
echo Create Godot_Path.txt in this folder if Godot is elsewhere.
echo Put the full Godot EXE path on the first line.
echo.
pause
exit /b 1
