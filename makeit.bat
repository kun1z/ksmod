rem Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

@echo off

if exist ksmod.obj del ksmod.obj
if exist ksmod.dll del ksmod.dll

\masm32\bin\rc /v ksmod.rc
\masm32\bin\cvtres /machine:ix86 ksmod.res
cls
\masm32\bin\ml /c /coff ksmod.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL ksmod.obj ksmod.res

dir ksmod.dll

pause

del *.obj
del ksmod.res