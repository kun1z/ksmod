; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    SetFileTimeHook proto :dword, :dword, :dword, :dword
.data?
    SetFileTimeOrig dd ?
.code
; ##########################################################################
SetFileTimeHook proc hFile:dword, lpCreationTime:dword, lpLastAccessTime:dword, lpLastWriteTime:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

			invoke CheckForSwap, addr hFile

        .endif

        invoke IsHandleTheDAT, hFile

        .if eax != 0

            ret

        .endif

    .endif

    push lpLastWriteTime
    push lpLastAccessTime
    push lpCreationTime
    push hFile

    push offset SetFileTimeRet
    SetFileTimeStub STUB
    jmp SetFileTimeOrig
    SetFileTimeRet:

    ret

SetFileTimeHook endp
; ##########################################################################