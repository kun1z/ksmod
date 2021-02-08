; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    SetFilePointerHook proto :dword, :dword, :dword, :dword
.data?
    SetFilePointerOrig dd ?
    LZMODDELETED dd ?
.code
; ##########################################################################
SetFilePointerHook proc hFile:dword, lDistanceToMove:dword, lpDistanceToMoveHigh:dword, dwMoveMethod:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

            invoke CheckForSwap, addr hFile

        .endif

    .endif

    push dwMoveMethod
    push lpDistanceToMoveHigh
    push lDistanceToMove
    push hFile

    push offset SetFilePointerRet
    SetFilePointerStub STUB
    jmp SetFilePointerOrig
    SetFilePointerRet:

    ;.if (eax != INVALID_SET_FILE_POINTER || edi != 0 || esi == 0080FF00h) && LZMODDELETED == 0

    ;    push eax

    ;    or LZMODDELETED, 0080FF00h

    ;    invoke DeleteModuleFromPEB, addr lzMODULE

    ;    dbg ttext("KSMOD.DLL DELETED")

    ;    pop eax

    ;.endif

    ret

SetFilePointerHook endp
; ##########################################################################