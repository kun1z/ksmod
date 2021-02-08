rem Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1

if exist "ksmod.obj" del "ksmod.obj"
if exist "ksmod.exe" del "ksmod.exe"

\masm32\bin\ml /c /coff "ksmod.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS "ksmod.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "ksmod.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS "ksmod.obj"
 if errorlevel 1 goto errlink
dir "ksmod.exe"
goto TheEnd

:errlink
 echo _
echo Link error
goto TheEnd

:errasm
 echo _
echo Assembly Error
goto TheEnd

:TheEnd

pause

del ksmod.obj