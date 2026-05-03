@echo off
echo Cleaning build artifacts...
if exist build\*.OBJ del build\*.OBJ
if exist bin\*.EXE del bin\*.EXE
if exist build\*.MAP del build\*.MAP
echo Done.
