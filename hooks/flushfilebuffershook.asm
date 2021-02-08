; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    FlushFileBuffersHook proto :dword
.data?
    FlushFileBuffersOrig dd ?
.code
; ##########################################################################
FlushFileBuffersHook proc hFile:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

			invoke CheckForSwap, addr hFile

        .endif

        .if VR_DisableCache == ENABLED

            invoke GetFileType, hFile

            .if eax == FILE_TYPE_DISK

                or eax, 1
                ret

            .endif

        .endif

    .endif

    push hFile

    push offset FlushFileBuffersRet
    FlushFileBuffersStub STUB
    jmp FlushFileBuffersOrig
    FlushFileBuffersRet:

    ret

FlushFileBuffersHook endp
; ##########################################################################