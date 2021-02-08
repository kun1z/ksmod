; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    GetFileTimeHook proto :dword, :dword, :dword, :dword
.data?
    GetFileTimeOrig dd ?
.code
; ##########################################################################
GetFileTimeHook proc hFile:dword, lpCreationTime:dword, lpLastAccessTime:dword, lpLastWriteTime:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

			invoke CheckForSwap, addr hFile

        .endif

    .endif

    push lpLastWriteTime
    push lpLastAccessTime
    push lpCreationTime
    push hFile

    push offset GetFileTimeRet
    GetFileTimeStub STUB
    jmp GetFileTimeOrig
    GetFileTimeRet:

    ret

GetFileTimeHook endp
; ##########################################################################