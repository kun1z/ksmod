; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

; ##########################################################################

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\user32.inc
    include \masm32\include\psapi.inc

    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\psapi.lib

; ##########################################################################

    text macro arg
        local nustr
        .data
            nustr db arg, 0
        .code
            exitm <offset nustr>
    endm

    ttext macro arg
        local nustr
        .data
            nustr db "ksmod.exe - ", arg, 0
        .code
            exitm <offset nustr>
    endm

    error macro arg
        local ovskip
        test eax, eax
        jnz ovskip
        push arg
        call ErrorMsg
        ovskip:
    endm

    dbg macro arg
        pushad
        push arg
        call OutputDebugStringA
        popad
    endm

    ENUM_SUCCEED equ <20001234h>

; ##########################################################################

    Main proto
    FindFirstUnpatchedWindow proto
    EnumWindowsProc proto :dword, :dword
    PatchExistingWindow proto :dword
    OpenAndPatch proto
    CheckForDirectory proto

; ##########################################################################

    include misc.asm

; ##########################################################################