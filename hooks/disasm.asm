; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    DisAsm proto :dword, :dword
    RubTheStub proto :dword, :dword, :dword
    InvalidInst proto :dword
    ExistingHook proto
    Hook proto :dword, :dword, :dword, :dword, :dword
.code
; ##########################################################################
Hook proc szModule:dword, szProcedure:dword, pHook:dword, pStub:dword, pRet:dword

    local Stub[STUBSIZE]:byte
    local StubSize:dword
    local LocalOrig:dword

    invoke GetModuleHandle, szModule

    invoke GetProcAddress, eax, szProcedure
    mov LocalOrig, eax

    invoke DisAsm, LocalOrig, addr Stub
    mov StubSize, eax

    invoke RubTheStub, pStub, addr Stub, StubSize

    invoke SetJMP, LocalOrig, pHook

    mov eax, StubSize
    add eax, LocalOrig
    mov ecx, pRet
    mov dword ptr [ecx], eax

    ret

Hook endp
; ##########################################################################
RubTheStub proc pOffset:dword, pStub:dword, pStubSize:dword

    local meminfo:MEMORY_BASIC_INFORMATION

    invoke VirtualProtect, pOffset, STUBSIZE, PAGE_EXECUTE_READWRITE, addr meminfo

    mov eax, pOffset
    mov ecx, pStubSize
    mov edx, pStub

    push ebx

    .while ecx != 0

        dec ecx
        mov bl, byte ptr [edx+ecx]
        mov byte ptr [eax+ecx], bl

    .endw

    pop ebx

    ret

RubTheStub endp
; ##########################################################################
DisAsm proc pOffset:dword, pStub:dword

    push ebx

    mov edx, pOffset
    mov ecx, edx

@@: mov al, byte ptr [edx]

    mov ebx, edx        ; Later we check to see if we didn't disasm anything...

    .if al == 0E8h || al == 0E9h
        invoke ExistingHook
    .endif

    .if al == 8Bh
        mov ah, byte ptr [edx+1]
        and ah, 11000000b
        .if ah == 11000000b
            ; MOV REG, REG
            add edx, 2
        .endif
    .endif

    mov ah, al
    and ah, 11111000b
    .if ah == 01010000b
        ; PUSH REG
        inc edx
    .elseif ah == 10111000b
        ; MOV REG, DWORD
        add edx, 5
    .elseif ah == 10110000b
        ; MOV REG, BYTE
        add edx, 2
    .endif

    .if al == 01101000b
        ; PUSH DWORD
        add edx, 5
    .elseif al == 01101010b
        ; PUSH BYTE
        add edx, 2
    .endif

    .if ebx == edx          ; We didn't find any instructions in our mini-disasm
        invoke InvalidInst, ebx
    .endif

    mov eax, ecx
    sub eax, edx
    cmp eax, -5     ; We need at least 5 bytes of room for a patch
    jg @B

    neg eax
    push eax

    ; Self-modifying code (copies stub into our dll procedures)

    mov ecx, pStub
    mov edx, pOffset

@@: mov ah, byte ptr [edx]
    mov byte ptr [ecx], ah
    inc edx
    inc ecx
    dec al
    jnz @B

    pop eax
    pop ebx

    ret

DisAsm endp
; ##########################################################################
InvalidInst proc pOffset:dword

    local buffer[64]:byte

    mov edx, pOffset

    mov eax, dword ptr [edx]
    bswap eax
    mov ebx, dword ptr [edx+4]
    bswap ebx
    mov ecx, dword ptr [edx+8]
    bswap ecx

    invoke wsprintfA, addr buffer, text("Invalid Instruction: %08X-%08X-%08X"), eax, ebx, ecx
    invoke MessageBoxA, 0, addr buffer, text("KSMod"), 1000h

    invoke ExitProcess, 0

InvalidInst endp
; ##########################################################################
ExistingHook proc

    invoke MessageBoxA, 0, text("A security program or a piece of malware (for example, a rootkit) is blocking KSMod's ability to function properly. Please switch security applications off and/or scan your system for malware."), text("KSMod"), 1000h

    invoke ExitProcess, 0

ExistingHook endp
; ##########################################################################