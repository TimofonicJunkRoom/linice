;==============================================================================
;                                                                             |
;   File: i386.asm                                                            |
;                                                                             |
;   Date: 09/11/00                                                            |
;                                                                             |
;   Copyright (c) 2000-2005 Goran Devic                                       |
;                                                                             |
;   Author:     Goran Devic                                                   |
;                                                                             |
;   This program is free software; you can redistribute it and/or modify      ;
;   it under the terms of the GNU General Public License as published by      ;
;   the Free Software Foundation; either version 2 of the License, or         ;
;   (at your option) any later version.                                       ;
;                                                                             ;
;   This program is distributed in the hope that it will be useful,           ;
;   but WITHOUT ANY WARRANTY; without even the implied warranty of            ;
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ;
;   GNU General Public License for more details.                              ;
;                                                                             ;
;   You should have received a copy of the GNU General Public License         ;
;   along with this program; if not, write to the Free Software               ;
;   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA   ;
;                                                                             ;
;==============================================================================
;
;   Module description:
;
;       This module contains all assembly code
;
;   NOTE: Dont forget to save/restore all used registers except eax!
;
;==============================================================================
; Define exported data and functions
;==============================================================================

global  IceIntHandlers

global  SyscallExecve

global  ReadCRTC
global  WriteCRTC
global  ReadSR
global  WriteSR
global  ReadMdaCRTC
global  WriteMdaCRTC
global  inp
global  getTR
global  SelLAR
global  GetRdtsc
global  FlushTLB

global  MemAccess_START
global  GetByte
global  GetDWORD
global  SetDWORD
global  SetByte
global  MemAccess_FAULT
global  MemAccess_END

global  strtolower
global  memset_w
global  memset_d
global  GetSysreg
global  SetSysreg
global  SetDebugReg
global  Outpb
global  Outpw
global  Outpd
global  Inpb
global  Inpw
global  Inpd

global  InterruptPoll

global  SpinlockTest
global  SpinUntilReset
global  SpinlockSet
global  SpinlockReset

global  GetKernelDS
global  GetKernelCS
global  sel_ice_ds              ; This needs to be initialized at module load time!

global  Checksum1               ; Protection - two checksum functions
global  Checksum2

;==============================================================================
; External definitions that this module uses
;==============================================================================

extern InterruptHandler

extern fStackLevel              ; Contains 0 for the first Linice entry on the stack
extern StackExtraBuffer         ; Current extra buffer space on the stack
extern MaxStackExtraBuffer      ; Maximum extra buffer space on the stack

;==============================================================================
;
;           I N T E R R U P T   H A N D L E R S
;
;==============================================================================

MAGIC_ERROR     equ     0CAFEBABEh

; Define interrupt handler stubs taking care to abstract error code on the stack

%macro int_handler 2
%if %2 == 0
        push    dword MAGIC_ERROR ; Fake error code if parameter 2 is zero (no EC)
%endif
        sub     esp, 4          ; Space for the chain_address
        pushad                  ; Save all general registers
        mov     ecx, %1         ; Get the interrupt number; parameter 1
        jmp     IntCommon       ; Jump to the common handler
%endmacro

; CPU traps and faults

Intr00:      int_handler 000h, 0
Intr01:      int_handler 001h, 0
Intr02:      int_handler 002h, 0
Intr03:      int_handler 003h, 0
Intr04:      int_handler 004h, 0
Intr05:      int_handler 005h, 0
Intr06:      int_handler 006h, 0
Intr07:      int_handler 007h, 0

Intr08:      int_handler 008h, 1
Intr09:      int_handler 009h, 0
Intr0A:      int_handler 00Ah, 1
Intr0B:      int_handler 00Bh, 1
Intr0C:      int_handler 00Ch, 1
Intr0D:      int_handler 00Dh, 1
Intr0E:      int_handler 00Eh, 1
Intr0F:      int_handler 00Fh, 0

Intr10:      int_handler 010h, 0
Intr11:      int_handler 011h, 0
Intr12:      int_handler 012h, 0
Intr13:      int_handler 013h, 0
Intr14:      int_handler 014h, 0
Intr15:      int_handler 015h, 0
Intr16:      int_handler 016h, 0
Intr17:      int_handler 017h, 0

Intr18:      int_handler 018h, 0
Intr19:      int_handler 019h, 0
Intr1A:      int_handler 01Ah, 0
Intr1B:      int_handler 01Bh, 0
Intr1C:      int_handler 01Ch, 0
Intr1D:      int_handler 01Dh, 0
Intr1E:      int_handler 01Eh, 0
Intr1F:      int_handler 01Fh, 0

; Interrupts from PIC

Intr20:      int_handler 020h, 0
Intr21:      int_handler 021h, 0
Intr22:      int_handler 022h, 0
Intr23:      int_handler 023h, 0
Intr24:      int_handler 024h, 0
Intr25:      int_handler 025h, 0
Intr26:      int_handler 026h, 0
Intr27:      int_handler 027h, 0

Intr28:      int_handler 028h, 0
Intr29:      int_handler 029h, 0
Intr2A:      int_handler 02Ah, 0
Intr2B:      int_handler 02Bh, 0
Intr2C:      int_handler 02Ch, 0
Intr2D:      int_handler 02Dh, 0
Intr2E:      int_handler 02Eh, 0
Intr2F:      int_handler 02Fh, 0

; SYSCALL ineterrupt

Intr80:      int_handler 080h, 0

; Table containing the addresses of our interrupt handlers

IceIntHandlers:
    dd  Intr00, Intr01, Intr02, Intr03, Intr04, Intr05, Intr06, Intr07
    dd  Intr08, Intr09, Intr0A, Intr0B, Intr0C, Intr0D, Intr0E, Intr0F

    dd  Intr10, Intr11, Intr12, Intr13, Intr14, Intr15, Intr16, Intr17
    dd  Intr18, Intr19, Intr1A, Intr1B, Intr1C, Intr1D, Intr1E, Intr1F

    dd  Intr20, Intr21, Intr22, Intr23, Intr24, Intr25, Intr26, Intr27
    dd  Intr28, Intr29, Intr2A, Intr2B, Intr2C, Intr2D, Intr2E, Intr2F

    times 080h-030h  dd Intr03
    dd Intr80
    times 100h-081h dd Intr03


; On the ring-0 stack:
;
;    (I) Running V86 code:             (II) Running PM code RING3:      (III) Running PM code RING0:
;   ___________________________        ______________________________   ______________________________
;   esp from tss * -|-
;              ---- | VM gs
;              ---- | VM fs
;              ---- | VM ds
;              ---- | VM es             esp from tss * -|-              esp is from interrupted kernel (*)
;              ---- | VM ss                        ---- | PM ss
;              VM esp                              PM esp
;              VM eflags                           PM eflags                        PM eflags
;              ---- | VM cs                        ---- | PM cs                     ---- | PM cs
;    ________  VM eip  __________________________  PM eip  _______________________  PM eip
;              error_code or 0                     error_code or 0                  error_code or 0
;              chain_address                       chain_address                    chain_address
;              eax                                 eax                              eax
;   p          ecx                                 ecx                              ecx
;   u          edx                                 edx                              edx
;   s          ebx                                 ebx                              ebx
;   h          ---                                 ---                              ---
;   a          ebp                                 ebp                              ebp
;   d          esi                                 esi                              esi
;    ________  edi  _____________________________  edi  __________________________  edi
;              0       *                           ---- | PM gs                     ---- | PM gs
;              0       *                           ---- | PM fs                     ---- | PM fs
;              0       *                           ---- | PM ds                     ---- | PM ds
;              0       *                           ---- | PM es                     ---- | PM es
;              ---- | VM ss                        ---- | PM ss                     ---- | PM ss
; frame ->     VM esp                              PM esp                           PM esp (*)

        struc   frame
_esp:           resd    1
_ss:            resd    1
_es:            resd    1
_ds:            resd    1
_fs:            resd    1
_gs:            resd    1
_genreg:        resd    8
chain_address:  resd    1
error_code:     resd    1
_eip:           resd    1
_cs:            resd    1
_eflags:        resd    1
_esp_orig:      resd    1
_ss_orig:       resd    1
_es_orig:       resd    1
_ds_orig:       resd    1
_fs_orig:       resd    1
_gs_orig:       resd    1
        endstruc

IntCommon:
        xor     eax, eax        ; Push the rest of segment/selector registers
        mov     ax, gs
        push    eax
        mov     ax, fs
        push    eax
        mov     ax, ds
        push    eax
        mov     ax, es
        push    eax

        ; Since we dont know what is the running kernel data selector at the compile time,
        ; we leave the space and fill in this word at the module init time.
        ;
        ; The next instruction decodes this way:
        ; 66 B8 xx yy      mov ax, SEL_ICE_DS
        db      066h, 0B8h
sel_ice_ds:
        dw      0               ; Load all selectors with kernel data selector

; We can not reload fs and gs with the default data selector. If we try, we randomly fault (under SuSE).
;       mov     gs, ax          ; Leave FS and GS as-is
;       mov     fs, ax
        mov     ds, ax
        mov     es, ax

; Depending on the mode of execution of the interrupted code, we need to do some entry adjustments
        sub     esp, 2 * 4                     ; Start of the frame, make room for esp/ss
        mov     ebp, esp
        test    dword [ebp+_eflags], 1 << 17   ; VM mode ?
        jz      not_VM

        ; --- VM86 ---
        mov     eax, [ebp+_gs_orig]
        mov     [ebp+_gs], eax
        mov     eax, [ebp+_fs_orig]
        mov     [ebp+_fs], eax
        mov     eax, [ebp+_ds_orig]
        mov     [ebp+_ds], eax
        mov     eax, [ebp+_es_orig]
        mov     [ebp+_es], eax
ring_3: ; --- VM86 + RING 3 ---
        mov     eax, [ebp+_ss_orig]
        mov     [ebp+_ss], eax
        mov     eax, [ebp+_esp_orig]
        mov     [ebp+_esp], eax
        jmp     entry
not_VM:
        test    dword [ebp+_cs], 1              ; Code selector is ring 3 ?
        jnz     ring_3

        ; --- RING 0 ---
        mov     ax, ss
        mov     dword [ebp+_ss], eax
        lea     eax, [ebp+_esp_orig]
        mov     dword [ebp+_esp], eax
entry:
; This semaphore is needed to let interrupts that happen during the Linice run
; simply stack up (down?) onto where we currently are, instead of reserving more extra stack space
        bts     dword [fStackLevel], 0          ; First level of Linice interrupt handler?
        jc      skip_set_stack                  ; If it is not (1), we dont need to allocate extra space

        mov     eax, dword [MaxStackExtraBuffer]; Get the constant max value
        mov     dword [StackExtraBuffer], eax   ; Store it in the current running buffer size
        sub     esp, eax                        ; And give it that much on the actual stack
skip_set_stack:
; Push the address of the register structure that we just set up.
        push    ebp                             ; This is the parameter PTREGS pRegs

; Push interrupt number on the stack and call our C handler
        push    ecx                             ; This is the parameter DWORD nInt
        cld                                     ; Set the direction bit
        call    InterruptHandler                ; on return, eax is the chain address (or NULL)
        add     esp, 8                          ; Restore esp to what was before the call

        cmp     esp, ebp                        ; Did we gave it any extra buffer?
        setz    [fStackLevel]                   ; Reset the semaphore if we did (first level)
        jz      skip_reset_stack
        add     esp, dword [StackExtraBuffer]   ; Move esp to skip the buffer and position to the pRegs
        mov     ebp, esp                        ; Make ebp and esp the same at this point
skip_reset_stack:

        mov     dword [ebp+chain_address], eax  ; Store the chain address
        mov     ecx, eax                        ; Keep the value in ecx register as well

; Depending on the mode of execution of the interrupted code, we need to do some exit adjustments
        test    dword [ebp+_eflags], 1 << 17    ; VM mode ?
        jz      exit_not_VM

        ; --- VM86 ---
        mov     eax, [ebp+_es]
        mov     [ebp+_es_orig], eax
        mov     eax, [ebp+_ds]
        mov     [ebp+_ds_orig], eax
        mov     eax, [ebp+_fs]
        mov     [ebp+_fs_orig], eax
        mov     eax, [ebp+_gs]
        mov     [ebp+_gs_orig], eax
exit_ring_3:
        mov     eax, [ebp+_ss]
        mov     [ebp+_ss_orig], eax
        mov     eax, [ebp+_esp]
        mov     [ebp+_esp_orig], eax
        jmp     exit
exit_not_VM:
        test    dword [ebp+_cs], 1              ; Code is ring 3 ?
        jnz     exit_ring_3
exit_ring0:
        ; --- RING 0 ---
exit:
        add     esp, 2 * 4                      ; Skip esp/ss as we can't modify them here
        pop     eax
        mov     es, ax
        pop     eax
        mov     ds, ax
        pop     eax
;       mov     fs, ax                          ; We should not reload FS and GS
        pop     eax                             ; They should be left with their default values
;       mov     gs, ax                          ; If we reload them, we fault under SuSE (?)

; Depending on the chain address and the error code, we need to return the right way
        or      ecx, ecx
        jz      no_chain_return
chain_return:
        mov     eax, [ebp+error_code]
        cmp     eax, MAGIC_ERROR
        je      chain_no_ec
        popad                   ; Restore all general purpose registers
        ret                     ; Return to the chain address and keep the error code

chain_no_ec:
        popad                   ; Restore all general purpose registers
        ret     4               ; Return to the chain address and pop the error code

no_chain_return:
        popad                   ; Restore all general purpose registers
        add     esp, 8          ; Skip the chain_address and the error code value
        iretd                   ; Return to the interrupted task

;==============================================================================
;
;           M I S C E L L A N E O U S    R O U T I N E S
;
;==============================================================================

MISC_INPUT              equ     03CCh
CRTC_INDEX_MONO         equ     03B4h
CRTC_INDEX_COLOR        equ     03D4h

MDA_INDEX               equ     03B4h
MDA_DATA                equ     03B5h

;==============================================================================
;
;   GetCRTCAddr
;
;   Returns the CRTC base register
;
;==============================================================================
GetCRTCAddr:
        push    ax
        mov     dx, MISC_INPUT
        in      al, (dx)
        mov     dx, CRTC_INDEX_MONO
        test    al, 1
        jz      @mono
        mov     dx, CRTC_INDEX_COLOR
@mono:  pop     ax
        ret

;==============================================================================
;
;   BYTE ReadCRTC(BYTE index)
;
;   This VGA helper function reads a CRTC value from a specified CRTC index
;   register.
;
;   Where:
;       [ebp + 8]   byte index of a CRTC register
;
;==============================================================================
ReadCRTC:
        push    ebp
        mov     ebp, esp
        push    edx
        call    GetCRTCAddr
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        in      al, (dx)
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   void WriteCRTC(int index, int value)
;
;   This VGA helper function writes a CRTC value into a specified CRTC index
;   register
;
;   Where:
;       [ebp + 8]   byte index of a CRTC register
;       [ebp +12]   new value
;
;==============================================================================
WriteCRTC:
        push    ebp
        mov     ebp, esp
        push    edx
        call    GetCRTCAddr
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        mov     eax, [ebp+12]
        out     (dx), al
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   BYTE ReadMdaCRTC(BYTE index)
;
;   This MDA helper function reads a CRTC value from a specified CRTC index
;   register.
;
;   Where:
;       [ebp + 8]   byte index of a CRTC register
;
;==============================================================================
ReadMdaCRTC:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     dx, MDA_INDEX
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        in      al, (dx)
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   void WriteMdaCRTC(int index, int value)
;
;   This MDA helper function writes a CRTC value into a specified CRTC index
;   register
;
;   Where:
;       [ebp + 8]   byte index of a CRTC register
;       [ebp +12]   new value
;
;==============================================================================
WriteMdaCRTC:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     dx, MDA_INDEX
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        mov     eax, [ebp+12]
        out     (dx), al
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   BYTE ReadSR(BYTE index)
;
;   This helper function reads a Sequencer register.
;
;   Where:
;       [ebp + 8]   byte index of a SR register
;
;==============================================================================
ReadSR:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     dx, 03C4h
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        in      al, (dx)
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   void WriteSR(int index, int value)
;
;   This helper function writes a sequencer register
;
;   Where:
;       [ebp + 8]   byte index of a SR register
;       [ebp +12]   new value
;
;==============================================================================
WriteSR:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     dx, 03C4h
        mov     eax, [ebp+8]
        out     (dx), al
        inc     dx
        mov     eax, [ebp+12]
        out     (dx), al
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   BYTE inp( WORD port )
;
;   Where:
;       [ebp + 8]   port index
;   Returns:
;       al - in(port)
;
;==============================================================================
inp:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     dx, [ebp+8]
        xor     eax, eax
        in      al, (dx)
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   DWORD getTR(void)
;
;   Returns:
;       ax - Task Register value
;
;==============================================================================
getTR:
        str     ax
        ret

;==============================================================================
;
;   DWORD SelLAR(WORD sel)
;
;   Where:
;       [ebp + 8 ]      selector
;
;   Returns:
;       eax - Access rights
;           0 if the selector was invalid
;
;==============================================================================
SelLAR:
        push    ebp
        mov     ebp, esp
        lar     eax, [ebp + 8]          ; Load access rights of a selector
        jz      @sel_ok                 ; Jump forth if the selector was ok
        xor     eax, eax                ; Reset to zero for invalid selector
@sel_ok:
        pop     ebp
        ret

;==============================================================================
;
;   DWORD GetRdtsc(DWORD *[2])
;
;   Where:
;       [ebp + 8 ]      address of the 8-byte buffer to store the value
;
;   Returns:
;       eax - Rdtsc counter - Lower DWORD
;
;==============================================================================
GetRdtsc:
        push    ebp
        mov     ebp, esp
        push    edx
        push    ebx

        mov     ebx, [ebp + 8]          ; Load the buffer address
        rdtsc                           ; Get the time-stamp value is EDX:EAX
        mov     [ebx], eax              ; Store the low dword
        mov     [ebx+4], edx            ; Store the high dword

        pop     ebx                     ; Return with eax - low dword
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   void FlushTLB(void)
;
;   Reloads CR3 thus flushing the TLB.
;
;==============================================================================
FlushTLB:
        push    eax
        mov     eax, cr3
        mov     cr3, eax
        pop     eax
        ret


;==============================================================================
;
;   DWORD Checksum1( DWORD start, DWORD len )
;
;   Calculates the sum of the code region.
;
;   Where:
;       [ebp + 8 ]      start
;       [ebp + 12 ]     len
;
;   Returns:
;       eax - SUM value
;
;==============================================================================
Checksum1:
        push    ebp
        mov     ebp, esp
        push    ebx
        push    ecx
        mov     ebx, [ebp + 8]          ; Load the starting address
        mov     ecx, [ebp + 12]         ; Load the len in bytes
        xor     eax, eax                ; Starting checksum value
@next_sum1:
        add     eax, [cs:ebx]
        inc     ebx                     ; Next byte
        loop    @next_sum1              ; Do it for the whole buffer
        pop     ecx
        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   int GetByte( WORD sel, DWORD offset )
;
;   Reads a byte from a memory location sel:offset
;   Returns a BYTE if the address is present, or value greater than 0xFF
;   if the address is not present
;
;   Where:
;       [ebp + 8 ]      selector
;       [ebp + 12 ]     offset
;
;==============================================================================
;
;   We do some checks here, and leave others to PF handler and GPF handler
;

MEMACCESS_PF        equ 0F0FFFFFFh      ; Memory access caused a page fault
MEMACCESS_GPF       equ 0F1FFFFFFh      ; Memory access caused a GP fault
MEMACCESS_LIM       equ 0F2FFFFFFh      ; Memory access invalid limit

MemAccess_START:

GetByte:
        push    ebp
        mov     ebp, esp
        push    ebx
        push    gs

        ; Perform a sanity check of the selector value
        mov     eax, MEMACCESS_GPF      ; Assume failure with the access right
        lar     bx, [ebp + 8]           ; Load access rights of a selector
        jnz     @bad_selector_rb        ; Exit if the selector is invisible or invalid

        mov     eax, MEMACCESS_LIM      ; Assume failure with the segment limit
        lsl     ebx, [ebp + 8]          ; Load segment limit into ebx register
        cmp     ebx, [ebp + 12]         ; Compare to what we requested
        jb      @bad_selector_rb        ; Exit if the limit is exceeded

        mov     ax, [ebp + 8]           ; Get the selector
        mov     gs, ax                  ; Store it in the GS
        mov     ebx, [ebp + 12]         ; Get the offset off that selector

        ; Access the memory using the GS selector, possibly causing PF or GPF
        ; since we installed handlers, they will return the correct error code

        xor     eax, eax
        mov     al, [gs:ebx]
@bad_selector_rb:
        pop     gs
        pop     ebx
        pop     ebp
        ret


;==============================================================================
;
;   unsigned int GetDWORD( WORD sel, DWORD offset )
;
;   Reads a DWORD from a memory location sel:offset
;
;   Where:
;       [ebp + 8 ]      selector
;       [ebp + 12 ]     offset
;
;==============================================================================
GetDWORD:
        push    ebp
        mov     ebp, esp
        push    ebx
        push    gs

        ; Perform a sanity check of the selector value
        mov     eax, MEMACCESS_GPF      ; Assume failure with the access right
        lar     bx, [ebp + 8]           ; Load access rights of a selector
        jnz     @bad_selector_rd        ; Exit if the selector is invisible or invalid

        mov     eax, MEMACCESS_LIM      ; Assume failure with the segment limit
        lsl     ebx, [ebp + 8]          ; Load segment limit into ebx register
        cmp     ebx, [ebp + 12]         ; Compare to what we requested
        jb      @bad_selector_rd        ; Exit if the limit is exceeded

        mov     ax, [ebp + 8]           ; Get the selector
        mov     gs, ax                  ; Store it in the GS
        mov     ebx, [ebp + 12]         ; Get the offset off that selector

        ; Access the memory using the GS selector, possibly causing PF or GPF
        ; since we installed handlers, they will return the correct error code

        mov     eax, [gs:ebx]
@bad_selector_rd:
        pop     gs
        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   void SetDWORD( WORD sel, DWORD offset, DWORD dwValue )
;
;   Sets a DWORD to a memory location at sel:offset
;
;   Where:
;       [ebp + 8 ]      selector
;       [ebp + 12 ]     offset
;       [ebp + 16 ]     value
;
;==============================================================================
SetDWORD:
        push    ebp
        mov     ebp, esp
        push    ebx
        push    gs

        ; Perform a sanity check of the selector value
        mov     eax, MEMACCESS_GPF      ; Assume failure with the access right
        lar     bx, [ebp + 8]           ; Load access rights of a selector
        jnz     @bad_selector_wd        ; Exit if the selector is invisible or invalid

        mov     eax, MEMACCESS_LIM      ; Assume failure with the segment limit
        lsl     ebx, [ebp + 8]          ; Load segment limit into ebx register
        cmp     ebx, [ebp + 12]         ; Compare to what we requested
        jb      @bad_selector_wd        ; Exit if the limit is exceeded

        mov     ax, [ebp + 8]           ; Get the selector
        mov     gs, ax                  ; Store it in the GS
        mov     ebx, [ebp + 12]         ; Get the offset off that selector
        mov     eax, [ebp + 16]         ; Get the value to write

        ; Access the memory using the GS selector, possibly causing PF or GPF
        ; since we installed handlers, they will return the correct error code

        mov     [gs:ebx], eax
@bad_selector_wd:
        pop     gs
        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   int SetByte( WORD sel, DWORD offset, BYTE byte )
;
;   Writes a byte to a memory location at sel:offset
;
;   Where:
;       [ebp + 8 ]      selector
;       [ebp + 12 ]     offset
;       [ebp + 16 ]     byte value
;
;==============================================================================
SetByte:
        push    ebp
        mov     ebp, esp
        push    ebx
        push    gs

        ; Perform a sanity check of the selector value
        mov     eax, MEMACCESS_GPF      ; Assume failure with the access right
        lar     bx, [ebp + 8]           ; Load access rights of a selector
        jnz     @bad_selector_wb        ; Exit if the selector is invisible or invalid

        mov     eax, MEMACCESS_LIM      ; Assume failure with the segment limit
        lsl     ebx, [ebp + 8]          ; Load segment limit into ebx register
        cmp     ebx, [ebp + 12]         ; Compare to what we requested
        jb      @bad_selector_wb        ; Exit if the limit is exceeded

        mov     ax, [ebp + 8]           ; Get the selector
        mov     gs, ax                  ; Store it in the GS
        mov     ebx, [ebp + 12]         ; Get the offset off that selector

        mov     eax, [ebp + 16]         ; Get the byte value

        ; Access the memory using the GS selector, possibly causing PF or GPF
        ; since we installed handlers, they will return the correct error code

        mov     [gs:ebx], al            ; Store the byte

@bad_selector_wb:
MemAccess_FAULT:
        pop     gs
        pop     ebx
        pop     ebp
        ret

MemAccess_END:
        nop


;==============================================================================
;
;   memset_w( BYTE *target, WORD filler, DWORD len )
;
;   Fills a buffer with words.
;
;   Where:
;       [ebp+8]         target address
;       [ebp+12]        word filler
;       [ebp+16]        length IN WORDS !!
;
;==============================================================================
memset_w:
        push    ebp
        mov     ebp, esp
        push    ecx
        push    edi

        mov     edi, [ebp+8]
        mov     eax, [ebp+12]
        mov     ecx, [ebp+16]
        or      ecx, ecx
        jz      @zero_w
        cld
        rep     stosw
@zero_w:
        pop     edi
        pop     ecx
        pop     ebp
        ret


;==============================================================================
;
;   memset_d( BYTE *target, DWORD filler, DWORD len )
;
;   Fills a buffer with dwords.
;
;   Where:
;       [ebp+8]         target address
;       [ebp+12]        dword filler
;       [ebp+16]        length IN DWORDS !!
;
;==============================================================================
memset_d:
        push    ebp
        mov     ebp, esp
        push    ecx
        push    edi

        mov     edi, [ebp+8]
        mov     eax, [ebp+12]
        mov     ecx, [ebp+16]
        or      ecx, ecx
        jz      @zero_d
        cld
        rep     stosd
@zero_d:
        pop     edi
        pop     ecx
        pop     ebp
        ret


;==============================================================================
;
;   strtolower(char *str)
;
;   Where:
;       [ebp+8]         string
;
;==============================================================================
strtolower:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     ebx, [ebp+8]
@loop:
        mov     al, [ebx]
        or      al, al
        jz      @exit
        cmp     al, 'A'
        jl      @next
        cmp     al, 'Z'
        jg      @next
        add     al, 'a'-'A'
        mov     [ebx], al
@next:
        inc     ebx
        jmp     @loop
@exit:
        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   void GetSysreg( TSysreg * pSys )
;
;   Reads in the rest of system registers
;
;   Where:
;       [ebp + 8 ]        pointer to the SysReg storage
;
;==============================================================================
GetSysreg:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     ebx, [ebp + 8]
        mov     eax, cr0
        mov     [ebx+0], eax
        mov     eax, cr2
        mov     [ebx+4], eax
        mov     eax, cr3
        mov     [ebx+8], eax
        mov     eax, cr4
        mov     [ebx+12], eax

        mov     eax, dr0
        mov     [ebx+16], eax
        mov     eax, dr1
        mov     [ebx+20], eax
        mov     eax, dr2
        mov     [ebx+24], eax
        mov     eax, dr3
        mov     [ebx+28], eax
        mov     eax, dr6
        mov     [ebx+32], eax
        mov     eax, dr7
        mov     [ebx+36], eax

        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   void SetSysreg( TSysreg * pSys )
;
;   Writes system registers back. Only registers that matter are written.
;
;   Where:
;       [ebp + 8 ]        pointer to the SysReg storage
;
;==============================================================================
SetSysreg:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     ebx, [ebp + 8]
        mov     eax, [ebx+0 ]
        mov     cr0, eax
;       mov     eax, [ebx+4 ]   ; No need to change Page Fault Linear Address
;       mov     cr2, eax
;       mov     eax, [ebx+8 ]   ; No need to change PDBR
;       mov     cr3, eax
        mov     eax, [ebx+12]
        mov     cr4, eax

        mov     eax, [ebx+16]
        mov     dr0, eax
        mov     eax, [ebx+20]
        mov     dr1, eax
        mov     eax, [ebx+24]
        mov     dr2, eax
        mov     eax, [ebx+28]
        mov     dr3, eax
        mov     eax, [ebx+32]
        mov     dr6, eax
        mov     eax, [ebx+36]
        mov     dr7, eax

        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   void SetDebugReg( TSysreg * pSys )
;
;   Writes debug registers back.
;
;   Where:
;       [ebp + 8 ]        pointer to the SysReg storage
;
;==============================================================================
SetDebugReg:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     ebx, [ebp + 8]

        mov     eax, [ebx+16]
        mov     dr0, eax
        mov     eax, [ebx+20]
        mov     dr1, eax
        mov     eax, [ebx+24]
        mov     dr2, eax
        mov     eax, [ebx+28]
        mov     dr3, eax
        mov     eax, [ebx+32]
        mov     dr6, eax
        mov     eax, [ebx+36]
        mov     dr7, eax

        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   void Outpb( DWORD port, DWORD value)
;   void Outpw( DWORD port, DWORD value)
;   void Outpd( DWORD port, DWORD value)
;
;   Where:
;       [ebp + 8 ]        port
;       [ebp + 12 ]       value
;
;==============================================================================
Outpb:
        push    ebp
        mov     ebp, esp
        push    edx
        push    eax
        mov     edx, [ebp+8]
        mov     eax, [ebp+12]
        out     dx, al
        pop     eax
        pop     edx
        pop     ebp
        ret

Outpw:
        push    ebp
        mov     ebp, esp
        push    edx
        push    eax
        mov     edx, [ebp+8]
        mov     eax, [ebp+12]
        out     dx, ax
        pop     eax
        pop     edx
        pop     ebp
        ret

Outpd:
        push    ebp
        mov     ebp, esp
        push    edx
        push    eax
        mov     edx, [ebp+8]
        mov     eax, [ebp+12]
        out     dx, eax
        pop     eax
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   DWORD Inpb( DWORD port )
;   DWORD Inpw( DWORD port )
;   DWORD Inpd( DWORD port )
;
;   Where:
;       [ebp + 8 ]      port
;   Returns:
;       eax             value
;
;==============================================================================
Inpb:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        xor     eax, eax
        in      al, (dx)
        pop     edx
        pop     ebp
        ret

Inpw:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        xor     eax, eax
        in      ax, (dx)
        pop     edx
        pop     ebp
        ret

Inpd:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        xor     eax, eax
        in      eax, (dx)
        pop     edx
        pop     ebp
        ret


;==============================================================================
;
;   void InterruptPoll(void)
;
;==============================================================================
InterruptPoll:
        hlt
        ret

;==============================================================================
;
;   Kernel code and data information functions
;
;==============================================================================
GetKernelDS:
        mov     ax, ds
        ret

GetKernelCS:
        mov     ax, cs
        ret

;==============================================================================
;
;   Spinlock functions:
;
;   DWORD SpinlockTest(DWORD *pSpinlock);
;   DWORD SpinUntilReset(DWORD *pSpinlock);
;   void  SpinlockSet(DWORD *pSpinlock);
;   void  SpinlockReset(DWORD *pSpinlock);
;
;==============================================================================

SpinUntilReset:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
@spin1: cmp     [edx], dword 0
        jnz     @spin1
        pop     edx
        pop     ebp
        ret

SpinlockSet:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        mov     [edx], dword 1
        pop     edx
        pop     ebp
        ret

SpinlockReset:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        mov     [edx], dword 0
        pop     edx
        pop     ebp
        ret

SpinlockTest:
        push    ebp
        mov     ebp, esp
        push    edx
        mov     edx, [ebp+8]
        mov     eax, [edx]
        pop     edx
        pop     ebp
        ret

;==============================================================================
;
;   DWORD Checksum2( DWORD start, DWORD end )
;
;   Calculates the sum of the code region. This function is intentionally
;   written differently from Checksum1 and resides somewhat away from it.
;
;   Where:
;       [ebp + 8 ]      start
;       [ebp + 12 ]     end
;
;   Returns:
;       eax - SUM value
;
;==============================================================================
Checksum2:
        push    ebp
        mov     ebp, esp
        xor     eax, eax                ; Starting checksum value
        push    ebx
        push    edx
        mov     ebx, [ebp + 8]          ; Load the starting address
        mov     edx, [ebp + 12]         ; Load the ending address
@next_sum2:
        add     eax, [cs:ebx]
        add     ebx, 1                  ; Next byte
        cmp     ebx, edx                ; Did we reach the end?
        jnz     @next_sum2              ; Jump back if we did not
        pop     edx
        pop     ebx
        pop     ebp
        ret

;==============================================================================
;
;   Handler for the execve system call hook.
;
;   We do it this way since we need to preserve the registers on the stack
;   within the original call and our hook.
;
;   Look in process.h:
;       asmlinkage int sys_execve(struct pt_regs regs)
;
;==============================================================================
extern sys_execve
extern SyscallExecveHook

; Calling our handler _before_ the original execve

SyscallExecve:
        call    SyscallExecveHook
        jmp     [sys_execve]

