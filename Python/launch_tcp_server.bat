@echo off
setlocal enabledelayedexpansion

echo [*] Killing old server if running...

if exist server.pid (
    set /p OLD_PID=<server.pid
    if not "!OLD_PID!"=="" (
        echo [*] Found PID: !OLD_PID!
        tasklist /FI "PID eq !OLD_PID!" | find /I "python.exe" >nul
        if !errorlevel! == 0 (
            echo [*] Killing PID !OLD_PID!
            taskkill /PID !OLD_PID! /F >nul 2>&1
        ) else (
            echo [!] PID !OLD_PID! not found or not Python. Skipping kill.
        )
    ) else (
        echo [!] server.pid is empty. Skipping kill.
    )
    del server.pid
)

echo [*] Launching TCP server...
call "C:\Users\Marco\Documents\Godot_Projects\Trajectory_Solver\.venv\Scripts\activate.bat"
python "C:\Users\Marco\Documents\Godot_Projects\Trajectory_Solver\Python/ml_logic\main.py"
exit
