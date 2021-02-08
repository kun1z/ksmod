; Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.

    CloseHandleHook proto :dword
.data?
    CloseHandleOrig dd ?
.code
; ##########################################################################
CloseHandleHook proc hObject:dword

    .if hObject != 0

        .if DidWeCreateTheDAT == FALSE

            invoke CheckForSwap, addr hObject

        .endif

    .endif

    push hObject

    push offset CloseHandleRet
    CloseHandleStub STUB
    jmp CloseHandleOrig
    CloseHandleRet:

    ret

CloseHandleHook endp
; ##########################################################################