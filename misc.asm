; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    IsHandleTheDAT proto :dword
    CheckAndUnlockTheDAT proto :dword
    CheckForSwap proto :dword

.data?
    UniqueFileID dd 3 dup(?)
    OldGlobalHandle dd ?
    NewGlobalHandle dd ?
.code
; ##########################################################################
CheckForSwap proc hFile:dword

    mov eax, hFile
    mov ecx, [eax]

    .if ecx == OldGlobalHandle

        mov ecx, NewGlobalHandle
        mov [eax], ecx

    .endif

    ret

CheckForSwap endp
; ##########################################################################
CheckAndUnlockTheDAT proc hFile:dword

    invoke IsHandleTheDAT, hFile

    .if eax != 0

        dbg ttext("GW.DAT has been Unlocked.")

        invoke CloseHandle, hFile

        invoke CreateFileA, text("gw.dat"), GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0

        mov NewGlobalHandle, eax
        mov eax, hFile
        mov OldGlobalHandle, eax

        mov IsDATLocked, FALSE

        invoke MessageBoxA, 0, text("An already-running game has been successfully patched!"), text("KSMod"), 1000h

    .endif

    ret

CheckAndUnlockTheDAT endp
; ##########################################################################
IsHandleTheDAT proc hFile:dword

    local lpFileInformation:BY_HANDLE_FILE_INFORMATION

    .if hFile != 0

        invoke GetFileInformationByHandle, hFile, addr lpFileInformation

        .if eax != 0

            mov eax, lpFileInformation.dwVolumeSerialNumber
            mov ecx, lpFileInformation.nFileIndexHigh
            mov edx, lpFileInformation.nFileIndexLow

            .if eax == UniqueFileID && ecx == UniqueFileID+4 && edx == UniqueFileID+8

                or eax, 1
                ret

            .endif

        .endif

    .endif

    xor eax, eax
    ret

IsHandleTheDAT endp
; ##########################################################################