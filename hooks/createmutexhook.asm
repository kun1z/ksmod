; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    CreateMutexAHook proto :dword, :dword, :dword
.data?
    CreateMutexAOrig dd ?
.code
; ##########################################################################
CreateMutexAHook proc lpMutexAttributes:dword, bInitialOwner:dword, lpName:dword

    local lzNewMutexName[32]:byte

    .if lpName != 0

        invoke Sleep, 10
        invoke GetTickCount

        invoke wsprintfA, addr lzNewMutexName, text("KSMod Mutex - %08X"), eax
        lea eax, lzNewMutexName
        mov lpName, eax

    .endif

    push lpName
    push bInitialOwner
    push lpMutexAttributes

    push offset CreateMutexARet
    CreateMutexAStub STUB
    jmp CreateMutexAOrig
    CreateMutexARet:

    ret

CreateMutexAHook endp
; ##########################################################################