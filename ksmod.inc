; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

; ##########################################################################

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\user32.inc
    include \masm32\include\winmm.inc

    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\winmm.lib

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
            nustr db "ksmod.dll - ", arg, 0
        .code
            exitm <offset nustr>
    endm

    dbg macro arg
        pushad
        push arg
        call OutputDebugStringA
        popad
    endm

    DISABLED equ 0
    ENABLED equ 1
    FALSE equ 0
    TRUE equ 1

    STUBSIZE equ 12
    STUB equ <db STUBSIZE dup(90h)>

; ##########################################################################

    KillSounds proto
    HighResComposite proto
    SearchBP proto :dword, :dword, :dword, :dword, :dword, :dword
    PatchSound proto :dword, :dword, :dword
    PatchTextures proto :dword, :dword, :dword
    GetUniqueDatID proto

; ##########################################################################

.data?

    hInst dd ?
    Kills dd ?
    KillTime dd ?
    VR_DisableCache dd ?
    DidWeCreateTheDAT dd ?
    IsDATLocked dd ?

.data

    lzERROR db "Unable To Enable: '%s'", 13, 10, 13, 10,
        "This happens from time to time and is most likely due to a large GW update.", 13, 10, 13, 10,
        "You can check my website for a new version: http://www.pickupgroup.com/ksmod/", 0

    lzMODULE dw 'k', 's', 'm', 'o', 'd', '.', 'd', 'l', 'l', 0
    lzCRASHMODULE dw 'n', 't', 'd', 'l', 'l', '.', 'd', 'l', 'l', 0

    sndtext1 db "Headshot", 0
    sndtext2 db "DoubleKill", 0
    sndtext3 db "TripleKill", 0
    sndtext4 db "MultiKill", 0
    sndtext5 db "MegaKill", 0
    sndtext6 db "UltraKill", 0
    sndtext7 db "LudicrousKill", 0
    sndtext8 db "MonsterKill", 0
    sndtext9 db "KillingSpree", 0
    sndtext10 db "Rampage", 0
    sndtext11 db "Dominating", 0
    sndtext12 db "Unstoppable", 0
    sndtext13 db "WickedSick", 0
    sndtext14 db "HolyShit", 0
    sndtext15 db "GodLike", 0

    align 4

    sndarray dd 0, offset sndtext1, offset sndtext2, offset sndtext3, offset sndtext4, offset sndtext5,
        offset sndtext6, offset sndtext7, offset sndtext8, offset sndtext9, offset sndtext10,
        offset sndtext11, offset sndtext12, offset sndtext13, offset sndtext14, offset sndtext15

    SearchBytes dd 0DCF3948Bh, 03000006h, 0F39489D7h, 000006DCh
    SearchByte2 dd 0F8830000h, 0BF077401h, 00000001h, 0FF3302EBh

; ##########################################################################

    include breakpoint.asm

    include misc.asm
    include hooks\disasm.asm

    include hooks\createmutexhook.asm
    include hooks\createfilehook.asm
    include hooks\readfilehook.asm
    include hooks\writefilehook.asm
    include hooks\setfilepointerhook.asm
    include hooks\closehandlehook.asm
    include hooks\flushfilebuffershook.asm
    include hooks\setendoffilehook.asm
    include hooks\getfiletimehook.asm
    include hooks\setfiletimehook.asm

; ##########################################################################