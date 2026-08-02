@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "GODOT=%LOCALAPPDATA%\GodotPortable\Godot_v4.7.1-stable_win64.exe"
if exist "Godot_Path.txt" (
    for /f "usebackq delims=" %%G in ("Godot_Path.txt") do (
        if exist "%%~G" set "GODOT=%%~G"
        goto GODOT_READY
    )
)
:GODOT_READY
if not exist "%GODOT%" goto GODOT_NOT_FOUND
echo Running Demo6 headless diagnostics...
"%GODOT%" --headless --path "%CD%" -- --self-test > "Demo6_Diagnostic.log" 2>&1
type "Demo6_Diagnostic.log"
findstr /c:"DEMO6_SELF_TEST_OK" "Demo6_Diagnostic.log" >nul
if errorlevel 1 (
    echo.
    echo DIAGNOSTIC FAILED. Send Demo6_Diagnostic.log for review.
    pause
    exit /b 1
)
echo.
echo DIAGNOSTIC PASSED.
pause
exit /b 0
:GODOT_NOT_FOUND
echo Godot executable not found.
pause
exit /b 1
