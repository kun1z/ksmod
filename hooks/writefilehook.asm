; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    WriteFileHook proto :dword, :dword, :dword, :dword, :dword
.data?
    WriteFileOrig dd ?
.code
; ##########################################################################
WriteFileHook proc hFile:dword, lpBuffer:dword, nNumberOfBytesToWrite:dword, lpNumberOfBytesWritten:dword, lpOverlapped:dword

    .if hFile != 0

        .if DidWeCreateTheDAT == FALSE

            .if IsDATLocked == TRUE

                invoke CheckAndUnlockTheDAT, hFile

            .endif

            invoke CheckForSwap, addr hFile

        .endif

        invoke IsHandleTheDAT, hFile

        .if eax != 0

            .if lpNumberOfBytesWritten != 0

                mov eax, lpNumberOfBytesWritten
                mov ecx, nNumberOfBytesToWrite
                mov dword ptr [eax], ecx

            .endif

            or eax, 1
            ret

        .endif

    .endif

    push lpOverlapped
    push lpNumberOfBytesWritten
    push nNumberOfBytesToWrite
    push lpBuffer
    push hFile

    push offset WriteFileRet
    WriteFileStub STUB
    jmp WriteFileOrig
    WriteFileRet:

    ret

WriteFileHook endp
; ##########################################################################