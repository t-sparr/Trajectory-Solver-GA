@echo off
setlocal enabledelayedexpansion
echo [*] Killing old server if running...

if exist server.pid (
    set /p OLD_PID=<server.pid
    echo [*] Found PID: !OLD_PID!
    
    tasklist /FI "PID eq !OLD_PID!" | find /I "python.exe" >nul
    if !errorlevel! == 0 (
        echo [*] Killing PID !OLD_PID!
        taskkill /PID !OLD_PID! /F >nul 2>&1
    ) else (
        echo [!] PID !OLD_PID! not found or not Python. Skipping kill.
    )
    del server.pid
)

call "C:\Users\Marco\Documents\Godot Projects\Trajectory Solver\Python\.venv\Scripts\activate.bat"
python "C:\Users\Marco\Documents\Godot Projects\Trajectory Solver\Python\tcp_server.py"
exit 