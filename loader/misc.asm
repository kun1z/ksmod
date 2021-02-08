; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    ErrorMsg proto :dword
    TrimComment proto :dword, :dword
    TrailBack proto :dword, :dword

.code
; ##########################################################################
ErrorMsg proc pCount:dword

    local buffer[128]:byte

    invoke GetLastError
    invoke wsprintfA, addr buffer, text("KSMod Loader Error: %u - %u"), pCount, eax

    invoke MessageBoxA, 0, addr buffer, text("KSMod"), 1000h

    invoke ExitProcess, 0

ErrorMsg endp
; ##########################################################################
TrimComment proc pSource:dword, pSize:dword

    mov eax, pSource
    mov ecx, pSize

    .while byte ptr [eax] != ';' && ecx != 0

        inc eax
        dec ecx

    .endw

    .if ecx != 0

        and byte ptr [eax], 0

    .endif

    ret

TrimComment endp
; ##########################################################################
TrailBack proc pBuff:dword, pStart:dword        ; 600

    mov eax, pBuff
    mov ecx, pStart

    .if byte ptr [eax] == '"'

    and byte ptr [eax], 0

    .endif

    .while byte ptr [eax] != '\' && eax != ecx

        dec eax

    .endw

    .if eax == ecx

        xor eax, eax
        error 601

    .endif

    inc eax

    ret

TrailBack endp
; ##########################################################################