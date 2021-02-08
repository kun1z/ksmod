; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    ReadFileHook proto :dword, :dword, :dword, :dword, :dword
.data?
    ReadFileOrig dd ?
    LZCRASHDELETED dd ?
.code
; ##########################################################################
ReadFileHook proc hFile:dword, lpBuffer:dword, nNumberOfBytesToRead:dword, lpNumberOfBytesRead:dword, lpOverlapped:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

            invoke CheckForSwap, addr hFile

        .endif

    .endif

    push lpOverlapped
    push lpNumberOfBytesRead
    push nNumberOfBytesToRead
    push lpBuffer
    push hFile

    push offset ReadFileRet
    ReadFileStub STUB
    jmp ReadFileOrig
    ReadFileRet:

    ;.if eax != 0 && LZCRASHDELETED == 0

    ;    invoke DebugCheck

    ;    .if eax != 0

    ;        or LZCRASHDELETED, 00440002h

    ;        invoke DeleteModuleFromPEB, addr lzCRASHMODULE

    ;        dbg ttext("NTDLL.DLL DELETED")

    ;    .endif

    ;.endif

    ret

ReadFileHook endp
; ##########################################################################