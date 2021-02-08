; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    .686p
    .model flat, stdcall
    option casemap :none
    include ksmod.inc

.code
start:invoke Main
; ##########################################################################
Main proc       ; 400

    local proc_handle:dword

    invoke CheckForDirectory

    dbg ttext("Searching for unpatched games...")

    invoke FindFirstUnpatchedWindow
    mov proc_handle, eax

    .if eax == 0

        dbg ttext("No unpatched games were found.")

        invoke OpenAndPatch

    .else

        dbg ttext("An unpatched game was found. Patching...")

        invoke PatchExistingWindow, proc_handle

        dbg ttext("An existing game has been patched.")

    .endif

    dbg ttext("Exiting.")

    invoke ExitProcess, 0

Main endp
; ##########################################################################
OpenAndPatch proc       ;300

    local Ssi:STARTUPINFO
    local Spi:PROCESS_INFORMATION
    local cmd_line[512]:byte
    local commands[128]:byte

    invoke RtlZeroMemory, addr Ssi, sizeof STARTUPINFO
    mov Ssi.cb, sizeof STARTUPINFO

    dbg ttext("Opening a new game...")

    invoke GetFullPathNameA, text("Settings.ini"), sizeof cmd_line, addr cmd_line, 0
    error 301

    invoke GetPrivateProfileStringA, text("KSMod"), text("Command_Line"), 0, addr commands, sizeof commands, addr cmd_line
    error 302

    invoke TrimComment, addr commands, sizeof commands

    invoke wsprintfA, addr cmd_line, text("%s %s"), text("gw.exe"), addr commands

    invoke CreateProcessA, 0, addr cmd_line, 0, 0, 0, CREATE_SUSPENDED, 0, 0, addr Ssi, addr Spi
    error 303

    dbg ttext("Opened. Patching a new game...")

    invoke PatchExistingWindow, Spi.hProcess

    invoke ResumeThread, Spi.hThread
    inc eax
    error 304

    invoke CloseHandle, Spi.hThread
    error 305

    dbg ttext("A new game has been opened and patched.")

    ret

OpenAndPatch endp
; ##########################################################################
PatchExistingWindow proc proc_handle:dword      ;100

    local hpid:dword
    local dllloc[512]:byte
    local memptr:dword
    local hndl:dword

    invoke GetFullPathNameA, text("ksmod.dll"), 512, addr dllloc, 0
    error 101

    invoke VirtualAllocEx, proc_handle, 0, sizeof dllloc, MEM_COMMIT, PAGE_READWRITE
    error 102
    mov memptr, eax

    invoke WriteProcessMemory, proc_handle, memptr, addr dllloc, sizeof dllloc, 0
    error 103

    invoke GetModuleHandleA, text("Kernel32")
    error 104

    invoke GetProcAddress, eax, text("LoadLibraryA")
    error 105

    invoke CreateRemoteThread, proc_handle, 0, 0, eax, memptr, 0, 0
    error 106
    mov hndl, eax

    invoke WaitForSingleObject, hndl, 10000
    inc eax
    error 107

    invoke VirtualFreeEx, proc_handle, memptr, 0, MEM_RELEASE
    error 108

    invoke CloseHandle, hndl
    error 109

    invoke CloseHandle, proc_handle
    error 110

    dbg ttext("Game patched.")

    ret

PatchExistingWindow endp
; ##########################################################################
FindFirstUnpatchedWindow proc       ; 200

    local hwnd:dword
    local hpid:dword

    invoke EnumWindows, addr EnumWindowsProc, addr hwnd

    .if eax == 0

        invoke GetLastError

        .if eax == ENUM_SUCCEED

            invoke GetWindowThreadProcessId, hwnd, addr hpid
            error 201

            invoke OpenProcess, PROCESS_ALL_ACCESS, 0, hpid
            error 202

            ret     ; Returns PID to caller

        .else

            xor eax, eax
            error 203

        .endif

    .endif

    xor eax, eax
    ret

FindFirstUnpatchedWindow endp
; ##########################################################################
EnumWindowsProc proc hwnd:dword, lParam:dword       ; 500

    local buffer[512]:byte
    local hpid:dword
    local hMods[200]:dword
    local needed:dword

    push ebx

    invoke GetWindowTextA, hwnd, addr buffer, sizeof buffer

    .if eax == 10

        invoke lstrcmpA, addr buffer, text("Guild Wars")

        .if eax == 0

            invoke GetWindowThreadProcessId, hwnd, addr hpid
            error 501

            invoke OpenProcess, PROCESS_ALL_ACCESS, 0, hpid
            error 502
            mov hpid, eax

            invoke GetProcessImageFileNameA, hpid, addr buffer, sizeof buffer
            error 503

            .if eax != 0

                lea ecx, buffer
                add eax, ecx
                invoke TrailBack, eax, ecx
                invoke lstrcmpiA, eax, text("gw.exe")

                .if eax == 0

                    invoke EnumProcessModules, hpid, addr hMods, sizeof hMods, addr needed
                    error 504

                    .if eax != 0

                        xor ebx, ebx

                        .while ebx != needed

                            invoke GetModuleFileNameExA, hpid, dword ptr [hMods+ebx], addr buffer, sizeof buffer
                            error 505

                            lea ecx, buffer
                            add eax, ecx
                            invoke TrailBack, eax, ecx
                            invoke lstrcmpiA, eax, text("ksmod.dll")

                            .if eax != 0

                                add ebx, 4

                            .else

                                pop ebx
                                or eax, 1
                                ret

                            .endif

                        .endw

                        mov ecx, lParam
                        mov eax, hwnd
                        mov dword ptr [ecx], eax
                        invoke SetLastError, ENUM_SUCCEED

                        pop ebx
                        xor eax, eax
                        ret

                    .endif

                .endif

            .endif

        .endif

    .endif

    pop ebx
    or eax, 1
    ret

EnumWindowsProc endp
; ##########################################################################
CheckForDirectory proc

    invoke CreateFileA, text("gw.exe"), 0, 0, 0, OPEN_EXISTING, 0, 0

    push eax
    invoke CloseHandle, eax
    pop eax

    .if eax == INVALID_HANDLE_VALUE

        invoke MessageBoxA, 0, text("KSMod must run from the Guild Wars folder."), text("KSMod"), 1000h
        invoke ExitProcess, 0

    .endif

    ret

CheckForDirectory endp
; ##########################################################################
end start