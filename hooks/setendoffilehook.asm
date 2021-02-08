; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    SetEndOfFileHook proto :dword
.data?
    SetEndOfFileOrig dd ?
.code
; ##########################################################################
SetEndOfFileHook proc hFile:dword

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

    push hFile

    push offset SetEndOfFileRet
    SetEndOfFileStub STUB
    jmp SetEndOfFileOrig
    SetEndOfFileRet:

    ret

SetEndOfFileHook endp
; ##########################################################################