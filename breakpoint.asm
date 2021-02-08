; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    setbreakpoint proto :dword, :dword, :dword
    SetJMP proto :dword, :dword
.code
; ##########################################################################
setbreakpoint proc bpaddy:dword, procaddy:dword, len:dword

    local meminfo:MEMORY_BASIC_INFORMATION
    local buff[12]:byte

    invoke VirtualProtect, bpaddy, 12, PAGE_EXECUTE_READWRITE, addr meminfo

    push esi
    push edi
    mov dword ptr [buff], 909090E8h
    mov dword ptr [buff+4], 90909090h
    mov dword ptr [buff+8], 90909090h
    mov ecx, 5
    mov eax, procaddy
    add ecx, bpaddy
    sub eax, ecx
    mov dword ptr [buff+1], eax
    lea esi, buff
    mov edi, bpaddy
    mov ecx, len
    rep movsb
    pop edi
    pop esi
    ret

setbreakpoint endp
; ##########################################################################
SetJMP proc pAddr:dword, pNewProc:dword

    local meminfo:MEMORY_BASIC_INFORMATION

    invoke VirtualProtect, pAddr, 5, PAGE_EXECUTE_READWRITE, addr meminfo

    mov eax, pAddr
    mov ecx, pNewProc
    sub ecx, eax
    sub ecx, 5
    mov byte ptr [eax], 0E9h
    mov dword ptr [eax+1], ecx
    ret

SetJMP endp
; ##########################################################################