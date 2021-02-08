; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    .686p
    .model flat, stdcall
    option casemap :none
    include ksmod.inc

.code
; ##########################################################################
LibMain proc hint:dword, reason:dword, param:dword

    local meminfo:MEMORY_BASIC_INFORMATION
    local cmd_line[512]:byte
    local Base:dword

    pushad

    .if reason == DLL_PROCESS_ATTACH

        dbg ttext("Entering.")

        mov eax, hint
        mov hInst, eax

        invoke GetModuleHandle, text("gw.exe")
        add eax, 1000h
        mov Base, eax
        invoke VirtualQuery, Base, addr meminfo, sizeof MEMORY_BASIC_INFORMATION

        invoke GetFullPathNameA, text("Settings.ini"), sizeof cmd_line, addr cmd_line, 0

        invoke PatchSound, meminfo.RegionSize, Base, addr cmd_line
        invoke PatchTextures, meminfo.RegionSize, Base, addr cmd_line

        invoke GetPrivateProfileInt, text("KSMod"), text("Virtualization"), 0, addr cmd_line
        .if eax == 1

            dbg ttext("Virtualization has been enabled.")

            invoke GetPrivateProfileInt, text("KSMod"), text("VR_DisableCache"), 0, addr cmd_line
            mov VR_DisableCache, eax

            invoke GetUniqueDatID

            mov IsDATLocked, TRUE

            invoke Hook,  text("Kernel32"),  text("CreateMutexA"),          addr CreateMutexAHook,      addr CreateMutexAStub,      addr CreateMutexAOrig
            invoke Hook,  text("Kernel32"),  text("CreateFileW"),            addr CreateFileWHook,       addr CreateFileWStub,       addr CreateFileWOrig
            invoke Hook,  text("Kernel32"),  text("CloseHandle"),            addr CloseHandleHook,       addr CloseHandleStub,       addr CloseHandleOrig
            invoke Hook,  text("Kernel32"),  text("ReadFile"),                  addr ReadFileHook,          addr ReadFileStub,          addr ReadFileOrig
            invoke Hook,  text("Kernel32"),  text("WriteFile"),                addr WriteFileHook,         addr WriteFileStub,         addr WriteFileOrig
            invoke Hook,  text("Kernel32"),  text("SetFilePointer"),      addr SetFilePointerHook,    addr SetFilePointerStub,    addr SetFilePointerOrig
            invoke Hook,  text("Kernel32"),  text("FlushFileBuffers"),  addr FlushFileBuffersHook,  addr FlushFileBuffersStub,  addr FlushFileBuffersOrig
            invoke Hook,  text("Kernel32"),  text("SetEndOfFile"),          addr SetEndOfFileHook,      addr SetEndOfFileStub,      addr SetEndOfFileOrig
            invoke Hook,  text("Kernel32"),  text("GetFileTime"),            addr GetFileTimeHook,       addr GetFileTimeStub,       addr GetFileTimeOrig
            invoke Hook,  text("Kernel32"),  text("SetFileTime"),            addr SetFileTimeHook,       addr SetFileTimeStub,       addr SetFileTimeOrig

        .endif

        dbg ttext("Exiting.")

    .endif

    popad
    or eax, 1
    ret

LibMain Endp
; ##########################################################################
SearchBP proc pMemory:dword, pMemSize:dword, pSearchBytes:dword, pOffset:dword, pProc:dword, pCodeLen:dword

    push ebx
    push edi
    push esi

    mov ebx, pSearchBytes
    mov eax, pMemSize
    sub eax, 4
    mov ecx, dword ptr [ebx]
    mov edx, dword ptr [ebx+4]
    mov edi, dword ptr [ebx+8]
    mov esi, dword ptr [ebx+12]
    mov ebx, pMemory
    jmp @F
    align 16

@@: inc ebx
    dec eax
    jz @F
    cmp ecx, dword ptr [ebx]
    jne @B
    cmp edx, dword ptr [ebx+4]
    jne @B
    cmp edi, dword ptr [ebx+8]
    jne @B
    cmp esi, dword ptr [ebx+12]
    jne @B

    add ebx, pOffset
    invoke setbreakpoint, ebx, pProc, pCodeLen
    or eax, -1

@@: pop esi
    pop edi
    pop ebx
    ret

SearchBP endp
; ##########################################################################
KillSounds proc

    test esi, esi
    jnz @F
    cmp edi, 100
    jz @F
    cmp edi, 250
    jae @F
    push eax
    push ecx
    push edx
    invoke GetTickCount
    mov ecx, eax
    sub eax, KillTime
    mov KillTime, ecx
    .if eax > 10000
        mov eax, 1
        mov Kills, eax
    .else
        inc Kills
        mov eax, Kills
        .if eax > 15
            mov eax, 15
        .endif
    .endif
    mov ecx, dword ptr [4*eax+sndarray]
    invoke PlaySound, ecx, hInst, SND_ASYNC or SND_RESOURCE or SND_NODEFAULT
    .if eax == 0
    .endif
    pop edx
    pop ecx
    pop eax

@@: mov [ebx+esi*8+6DCh], edx ; ORIGINAL 7B9C71
    ret

KillSounds endp
; ##########################################################################
HighResComposite proc

    xor edi, edi
    ret

HighResComposite endp
; ##########################################################################
PatchSound proc memsize:dword, base:dword, cmd_line:dword

    local buffer[512]:byte

    invoke GetPrivateProfileInt, text("KSMod"), text("UT99_Sound_FX"), 0, cmd_line
    .if eax == 1
        invoke SearchBP, base, memsize, addr SearchBytes, 9, addr KillSounds, 7
        .if eax == 0
            dbg ttext("UT99_Sound_FX not found.")
            invoke wsprintf, addr buffer, addr lzERROR, text("UT99_Sound_FX")
            invoke MessageBox, 0, addr buffer, text("KSMod"), 1000h
        .else
            dbg ttext("UT99_Sound_FX patched.")
        .endif
    .endif
    ret

PatchSound endp
; ##########################################################################
PatchTextures proc memsize:dword, base:dword, cmd_line:dword

    local buffer[512]:byte

    invoke GetPrivateProfileInt, text("KSMod"), text("High_Def_Composite"), 0, cmd_line
    .if eax == 1
        invoke SearchBP, base, memsize, addr SearchByte2, 7, addr HighResComposite, 5
        .if eax == 0
            dbg ttext("High_Def_Composite not found.")
            invoke wsprintf, addr buffer, addr lzERROR, text("High_Def_Composite")
            invoke MessageBox, 0, addr buffer, text("KSMod"), 1000h
        .else
            dbg ttext("High_Def_Composite patched.")
        .endif
    .endif
    ret

PatchTextures endp
; ##########################################################################
GetUniqueDatID proc

    local Handle:dword
    local lpFileInformation:BY_HANDLE_FILE_INFORMATION

    invoke CreateFileA, text("gw.dat"), 0, 0, 0, OPEN_EXISTING, 0, 0
    mov Handle, eax

    .if eax != INVALID_HANDLE_VALUE

        invoke GetFileInformationByHandle, Handle, addr lpFileInformation

        .if eax != 0

            mov eax, lpFileInformation.dwVolumeSerialNumber
            mov ecx, lpFileInformation.nFileIndexHigh
            mov edx, lpFileInformation.nFileIndexLow
            mov UniqueFileID, eax
            mov UniqueFileID+4, ecx
            mov UniqueFileID+8, edx

        .endif

        invoke CloseHandle, Handle

    .endif

    ret

GetUniqueDatID endp
; ##########################################################################
End LibMain