; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    CreateFileWHook proto :dword, :dword, :dword, :dword, :dword, :dword, :dword
.data?
    CreateFileWOrig dd ?
.data
    GWDATUNICODE dw 'G', 'W', '.', 'D', 'A', 'T', 0
.code
; ##########################################################################
CreateFileWHook proc lpFileName:dword, dwDesiredAccess:dword, dwShareMode:dword, lpSecurityAttributes:dword, dwCreationDisposition:dword, dwFlagsAndAttributes:dword, hTemplateFile:dword

    .if lpFileName != 0

        invoke lstrlenW, lpFileName
        shl eax, 1

        .if eax >= 12

            mov ecx, lpFileName
            lea ecx, [ecx+eax-12]
            invoke lstrcmpiW, ecx, addr GWDATUNICODE

            .if eax == 0

                dbg ttext("GW.DAT has been created with sharing")

                mov dwShareMode, FILE_SHARE_READ
                mov dwDesiredAccess, GENERIC_READ

                mov DidWeCreateTheDAT, TRUE
                mov IsDATLocked, FALSE

            .endif

        .endif

    .endif

    push hTemplateFile
    push dwFlagsAndAttributes
    push dwCreationDisposition
    push lpSecurityAttributes
    push dwShareMode
    push dwDesiredAccess
    push lpFileName

    push offset CreateFileWRet
    CreateFileWStub STUB
    jmp CreateFileWOrig
    CreateFileWRet:

    ret

CreateFileWHook endp
; ##########################################################################