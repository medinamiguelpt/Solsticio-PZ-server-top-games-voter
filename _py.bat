@echo off
REM Sets PYCMD to a working Python launcher. Prefers the "py" launcher because
REM it works even if the user forgot to tick "Add Python to PATH", and it does
REM not trigger the Microsoft Store stub. Falls back to "python". Leaves PYCMD
REM empty if no real Python is found.
set "PYCMD="
py -3 --version >nul 2>&1
if not errorlevel 1 set "PYCMD=py -3"
if defined PYCMD goto :eof
python --version >nul 2>&1
if not errorlevel 1 set "PYCMD=python"
goto :eof
