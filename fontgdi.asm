; FONTGDI source code
; (C) 1996-2001 Jonathan Campbell
; joncampbell@angelfire.com

VERSION                 EQU             0202h           ; Version 2.21
VERSIONSUB              EQU             01h
CpuNeeded               EQU             0h              ; 8086/8088

; keeps MASM linker happy
stack segment para stack 'stack'
stack ends

code segment para public 'code'
        assume cs:code,ds:code,es:code

                org     0               ; for simplicity's sake we start at 0, we are an EXE

; entry code
main:           mov     ax,cs
                mov     ds,ax

; make sure we're in text mode -- we need to be in order to do our thing
                mov     ax,40h
                mov     es,ax
                mov     al,es:[49h]
                cmp     al,3
                jbe     c0
                mov     ah,0
                mov     al,3
                int     10h
c0:

; HI USER! IT'S ME! FONTGDI! AND I WAS WRITTEN BY JONATHAN CAMPBEL!!!
                mov     si,offset hello
                call    prints

; what's the current CPU (as far as I know how to check)
                call    CPUChk
                mov     CurrentCPU,al

; check if we're installed already
                mov     ah,35h
                mov     al,68h
                int     21h                     ; get INT 68h vector
                mov     ax,es
                cmp     ax,70h                  ; if it's pretty close to being a NULL pointer, don't bother calling it
                jb      s0                      ; skip if suspiciously a NULL pointer
                mov     ah,0                    ; call it (FONTGDI get version)
                int     68h
                cmp     bx,01234h               ; is BX=1234h
                jne     s0                      ; if so, it's us
                mov     si,offset ainst         ; HEY USER! I'M ALREADY INSTALLED!
                call    prints
                jmp     exit                    ; and exit to DOS....

s0:             or      VidFlag,00000001b       ; put in which routines are implemented and assume CGA compatible
                call    ChkVGA                  ; are we talking to a VGA compatible?
                jnc     s1
                or      VidFlag,00000111b       ; if it is VGA, it can do EGA and CGA
                or      Vid2Flag,00000111b
                jmp     s2

; not a VGA.... then we don't support you?
s1:             mov     si,offset noVID         ; sorry user, I don't recognise your video adaptor
                call    prints
                jmp     exit                    ; exit to DOS

; video adaptor checks out... let's analyze the CRTC
s2:             mov     ax,40h
                mov     es,ax
                mov     ax,WORD PTR es:[63h]    ; check BIOS area for CRT
                mov     cs:CRTPort,ax
                cmp     ax,3BAh                 ; 3BA?
                jne     s3
                or      Vid3Flag,00000000b      ; set bit 0 to 0
                jmp     s5
s3:             cmp     ax,3DAh                 ; 3DA?
                jne     s4
                or      Vid3Flag,00000001b      ; if so, set bit 0 to 1
                jmp     s5
s4:             or      Vid3Flag,00000011b      ; not 3BA or 3DA, so mark it lost

; store original font height
s5:             mov     ax,40h
                mov     es,ax
                mov     ax,es:[85h]             ; get it from BIOS
                mov     cs:CFontPt,ax

; sanity check -- can we get the font data?
                test    cs:Vid2Flag,4
                jz      s6
; get the font data
                cli
; set graphics controller in a mode where we can access font data
                mov     dx,3C4h
                mov     ax,0100h
                out     dx,ax
                mov     ax,0402h
                out     dx,ax
                mov     ax,0704h
                out     dx,ax
                mov     ax,0300h
                out     dx,ax
                mov     dx,3CEh
                mov     ax,0204h
                out     dx,ax
                mov     ax,0005h
                out     dx,ax
                mov     ax,0006h
                out     dx,ax

; get font data
                mov     cx,32*256
                mov     di,offset CFont
                mov     si,0
                mov     ax,cs
                mov     es,ax
                mov     ax,0A000h
                mov     ds,ax
                rep     movsb

; restore graphics controller normality
                mov     dx,3C4h
                mov     ax,0100h
                out     dx,ax
                mov     ax,0302h
                out     dx,ax
                mov     ax,0304h
                out     dx,ax
                mov     ax,0300h
                out     dx,ax
                mov     dx,3CEh
                mov     ax,0004h
                out     dx,ax
                mov     ax,1005h
                out     dx,ax
                mov     ax,0E06h
                out     dx,ax
                sti

; can VGA card do "bit planar" 320x200x256
s6:             test    cs:VidFlag,4            ; Do this next test if you are VGA compatible
                jz      s7
                or      cs:Vid2Flag,8           ; most VGA cards can, it's a given

; install INT 10h hook
s7:             mov     ah,35h
                mov     al,10h
                int     21h
                mov     WORD PTR cs:OldInt10,bx
                mov     WORD PTR cs:OldInt10+2,es
                mov     ax,cs
                mov     ds,ax
                mov     dx,offset Int10
                mov     ah,25h
                mov     al,10h
                int     21h

; install INT 2Fh hook
                mov     ah,35h
                mov     al,2Fh
                int     21h
                mov     WORD PTR cs:OldInt2F,bx
                mov     WORD PTR cs:OldInt2F+2,es
                mov     ax,cs
                mov     ds,ax
                mov     dx,offset Int2F
                mov     ah,25h
                mov     al,2Fh
                int     21h

; install INT 68h handler
                mov     ax,cs
                mov     ds,ax
                mov     dx,offset Int68
                mov     ah,25h
                mov     al,68h
                int     21h

                mov     ax,cs
                mov     ds,ax
                mov     si,offset succs
                call    prints

; Terminate and stay resident to DOS
texit:          mov     ah,31h
                mov     al,0
                mov     dx,3000h SHR 4
                int     21h

; normal exit to DOS
exit:           mov     ah,4Ch
                mov     al,0
                int     21h

; strings and variables
hello   db      'FONTGDI 2.21 by Jonathan Campbell (joncampbell@angelfire.com)',13,10,0
succs   db      'FONTGDI services availible.',13,10,0
ainst   db      'FONTGDI services are already installed.',13,10,0
winbeg  db      'FONTGDI: Standard Windows is starting',13,10,0
winbeg386 db    'FONTGDI: 386 enhanced Windows is starting',13,10,0
winbeg95 db     'FONTGDI: Windows 95 is starting',13,10,0
winbeg98 db     'FONTGDI: Windows 98 is starting',13,10,0
winend  db      'FONTGDI: Windows is exiting',13,10,0
winend386 db    'FONTGDI: 386 enhanced Windows is exiting',13,10,0
winend95 db     'FONTGDI: Windows 95 is exiting',13,10,0
winend98 db     'FONTGDI: Windows 98 is exiting',13,10,0
noVID   db      'Unable to detect VGA compatible video adaptor',13,10,0
; old INT 10h vector (before we took it over)
OldInt10        dd      ?
OldInt2F        dd      ?
CFontPt         dw      ?                       ; current font height
CFont           db      32*256 dup(?)           ; current font data
CurrentCPU      db      ?
CRTPort         dw      ?
CHARSeg         dw      ?
MiscB           db      ?
VidFlag         db      ?                       ; Video card compatible ID
; bit 0 of VidFlag              Can do CGA graphics with this video card
; bit 1 of VidFlag              Can do EGA graphics with this video card
; bit 2 of VidFlag              Can do VGA graphics with this video card
; bit 3 of VidFlag              Can do SVGA graphics with this video card
; bit 4 of VidFlag              CGA routines implemented
; bit 5 of VidFlag              EGA routines implemented
; bit 6 of VidFlag              VGA routines implemented
; bit 7 of VidFlag              SVGA routines implemented
Vid2Flag        db      ?                       ; Video can-do flags
; bit 0 of Vid2Flag             Can use color pallete
; bit 1 of Vid2Flag             Video card supports color pallete
; bit 2 of Vid2Flag             Video card can change text-mode font
; bit 3 of Vid2Flag             VGA/SVGA is capable of turning on bit planes in the 320x200 256-color mode
Vid3Flag        db      ?                       ; Video data
; bit 0 of Vid3Flag             1=CRT is on port 3DA.   0=CRT is on port 3BA.
; bit 1 of Vid3Flag             1=CRT is either on port 3DA or 3BA.   0=CRT is not there.
Vid4Flag        db      ?                       ; Program flags
; bit 0 of Vid4Flag             Master disable switch (1=Disabled)
; bit 1 of Vid4Flag             Disable automatic font set when INT 10 invoked (1=Disabled)
; bit 2 of Vid4Flag             Disable INT 10 AH = 11H (character generator interface) functions
; bit 4 of Vid4Flag             1=Invert underline.     0=Draw underline.
; bit 5 of Vid4Flag             1=Make font bold.       0=Display font as is.
; bit 7 of Vid4Flag             1=Make font underlined. 0=Display font as is.

; int 2Fh handler
Int2F           proc
                pushf
                cmp     ax,1605h                ; windows initializing?
                je      Int2F_wininit
                cmp     ax,1606h                ; windows closing?
                je      Int2F_winclose
Int2F_pass:     popf
                jmp     DWORD PTR cs:OldInt2F   ; just pass it on

Int2F_cont:     pushf
                call    DWORD PTR cs:OldInt2F   ; keep the chain going
                ret

Int2F_wininit:  push    ds
                push    si
                mov     si,cs
                mov     ds,si
                mov     si,offset winbeg
                test    dx,1                    ; 386 enhanced windows?
                jnz     Int2F_wininit2
                mov     si,offset winbeg386
                cmp     di,0400h                ; Windows 95?
                jb      Int2F_wininit2
                mov     si,offset winbeg95
                cmp     di,040Ah                ; Windows 98?
                jb      Int2F_wininit2
                mov     si,offset winbeg98
Int2F_wininit2: call    prints
                pop     si
                pop     ds
; then call back down the chain
                call    Int2F_cont              ; let next handler function and get it's structure
                popf
                iret

Int2F_winclose: push    ds
                push    si
                mov     si,cs
                mov     ds,si
                mov     si,offset winend
                test    dx,1                    ; 386 enhanced windows?
                jnz     Int2F_winclose2
                mov     si,offset winend386
                cmp     di,0400h                ; Windows 95?
                jb      Int2F_winclose2
                mov     si,offset winend95
                cmp     di,040Ah                ; Windows 98?
                jb      Int2F_winclose2
                mov     si,offset winend98
Int2F_winclose2:call    prints
                pop     si
                pop     ds
; then call back down the chain
                call    Int2F_cont              ; let next handler function and get it's structure
                popf
Int2F           endp

; our INT 10h handler
Int10           proc
                cmp     ah,11h                  ; BIOS CHARACTER GEN FUNCS?
                je      Int10_11
                cmp     ah,0                    ; BIOS SET VIDEO MODE?
                jne     Int10pass               ; if not, let it pass
                pushf                           ; create IRET stack frame
                call    DWORD PTR cs:OldInt10   ; let BIOS work it out
                test    cs:Vid4Flag,1           ; now, do we change font?
                jnz     Int10end                ; if not, skip setting the font
                call    SetVid
Int10end:       iret
Int10pass:      jmp     DWORD PTR cs:OldInt10
Int10_11:       cmp     al,30h                  ; get font pointers and stuff?
                jne     Int10_11_dump
                mov     bh,0
                push    es
                mov     ax,40h
                mov     es,ax
                mov     dl,es:[84h]
                pop     es
                mov     cl,BYTE PTR cs:CFontPt
                xor     ch,ch
                mov     bp,cs
                mov     es,bp
                mov     bp,offset CFont
                jmp     Int10end
Int10_11_dump:  call    SetVid
                clc
                jmp     Int10end
Int10           endp

; changes the font
SetVidTmp       db      ?
SetVid          proc
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    es
                push    ds

                mov     al,6
                mov     dx,3CEh
                out     dx,al
                jmp     short $+2
                inc     dx
                in      al,dx
                mov     cs:SetVidTmp,al

; sanity check -- can we (as we determined earlier) set the font?
                test    cs:Vid4Flag,2
                jnz     SetVidc2
                test    cs:Vid2Flag,4           ; Are we able to change the text?
                jnz     SetVidc
SetVidc2:       jmp     SetVidi
SetVidc:        mov     ax,40h
                mov     es,ax
                mov     al,es:[49h]             ; get BIOS video mode
                cmp     al,3
                jbe     SetVide
                cmp     al,7
                je      SetVide
SetVidi:        jmp     SetViden

; sanity check says go -- do it
; update the CRTC with new font pitch
SetVide:        mov     dx,cs:CRTPort
                mov     ah,BYTE PTR cs:CFontPt
                dec     ah
                mov     al,9
                out     dx,ax
; update BIOS variables
                mov     bx,40h
                mov     es,bx
                mov     dx,es:[85h]             ; save old value
                mov     bx,cs:CFontPt
                mov     es:[85h],bx             ; make sure we update BIOS
                mov     al,es:[84h]             ; AL=rows of text on screen
                xor     ah,ah
                inc     ax
                mov     cx,dx
                mul     cx                      ; rows*points
                mov     cx,cs:CFontPt
                div     cx                      ; (rows*points)/CFontPt
                dec     al
                mov     es:[84h],al             ; new rows

; get the graphics controller in a mode so we can get at the character RAM
                mov     dx,3C4h
                mov     ax,0100h
                out     dx,ax
                mov     ax,0402h
                out     dx,ax
                mov     ax,0704h
                out     dx,ax
                mov     ax,0300h
                out     dx,ax
                mov     dx,3CEh
                mov     ax,0204h
                out     dx,ax
                mov     ax,0005h
                out     dx,ax
                mov     ax,0006h
                out     dx,ax

; copy our buffer into character RAM
                cld
                mov     cx,32*256
                xor     di,di
                mov     si,offset CFont
                mov     ax,cs
                mov     ds,ax
                mov     ax,0A000h
                mov     es,ax
                rep     movsb

; add bold text (if selected)
                test    cs:Vid4Flag,020h
                jz      SetVid30
                mov     ax,0A000h
                mov     ds,ax
                mov     cx,32*256
                xor     si,si
                xor     di,di
SetVid25:       lodsb
                mov     ah,al
                shl     ah,1
                or      al,ah
                stosb
                loop    SetVid25

; restore graphics controller state to normal
SetVid30:       mov     dx,3C4h
                mov     ax,0100h
                out     dx,ax
                mov     ax,0302h
                out     dx,ax
                mov     ax,0304h
                out     dx,ax
                mov     ax,0300h
                out     dx,ax
                mov     dx,3CEh
                mov     ax,0004h
                out     dx,ax
                mov     ax,1005h
                out     dx,ax
                mov     al,06h
                mov     ah,cs:SetVidTmp
                out     dx,ax

; finish and return
SetViden:       pop     ds
                pop     es
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
SetVid          endp

FuncTabl        dw      offset  FontSetT        ; AH = 01: Set Text Font
                dw      offset  FontGetT        ; AH = 02: Get Text Font
                dw      offset  NeededCPU       ; AH = 03: Get required cpu
                dw      offset  GotCPU          ; AH = 04: Get current CPU
                dw      offset  NotHere         ; AH = 05:
                dw      offset  NotHere         ; AH = 06:
                dw      offset  NotHere         ; AH = 07:
                dw      offset  NotHere         ; AH = 08:
                dw      offset  NotHere         ; AH = 09:
                dw      offset  NotHere         ; AH = 0A:
                dw      offset  NotHere         ; AH = 0B:
                dw      offset  NotHere         ; AH = 0C:
                dw      offset  NotHere         ; AH = 0D:
                dw      offset  NotHere         ; AH = 0E:
                dw      offset  NotHere         ; AH = 0F:
                dw      offset  GetVideoFlagSet1; AH = 10: Get Video Flag Set 1
                dw      offset  GetVideoFlagSet2; AH = 11: Get Video Flag Set 2
                dw      offset  GetVideoFlagSet3; AH = 12: Get Video Flag Set 3
                dw      offset  GetVideoFlagSet4; AH = 13: Get/Set Video Flag Set 4
                dw      offset  UpdateCharRAM   ; AH = 14: Update character RAM

; INT 68h routines
NotHere         proc
                ret
NotHere         endp

GetVideoFlagSet1 proc
                mov     al,cs:VidFlag
                ret
GetVideoFlagSet1 endp

GetVideoFlagSet2 proc
                mov     al,cs:Vid2Flag
                ret
GetVideoFlagSet2 endp

GetVideoFlagSet3 proc
                mov     al,cs:Vid3Flag
                ret
GetVideoFlagSet3 endp

GetVideoFlagSet4 proc
                test    al,128                  ; Is program requesting a set operation?
                jz      GetVideoFlagSet4e
                mov     cs:Vid4Flag,cl          ; If set, flags are in CL
GetVideoFlagSet4e: mov  al,cs:Vid4Flag          ; And return result to program
                ret
GetVideoFlagSet4 endp

GotCPU          proc
                mov     al,cs:CurrentCPU
                xor     ah,ah
                ret
GotCPU          endp

FontSetT        proc                    ; AL = font height DS:SI = ptr to buffer
                test    cs:VidFlag,4
                jnz     FontSetOK
                mov     al,10h
                ret
FontSetOK:      cmp     al,32
                jb      FontSetOK2
                ret
FontSetOK2:     push    ax
                xor     ah,ah
                mov     cs:CFontPt,ax
                inc     ax
                push    es
                mov     bx,40h
                mov     es,bx
;               mov     es:[85h],ax
                pop     es
                push    si
                push    di
                push    cx
                push    dx
                push    ds
                push    es
                mov     di,offset CFont
                mov     cx,32*256
                mov     ax,cs
                mov     es,ax
                rep     movsb
                mov     dx,cs:CRTPort
;               mov     ax,cs:CFontPt
                call    SetVid
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     di
                pop     si
                pop     ax
                mov     al,00h
                ret
FontSetT        endp

FontGetT        proc                    ; DS:SI = ptr to buffer
                test    cs:VidFlag,4
                jnz     FontGetOK
                mov     al,10h
                ret
FontGetOK:      push    ax
                push    si
                push    di
                push    cx
                push    dx
                push    ds
                push    es
                mov     ax,ds
                mov     cx,es
                mov     es,ax
                mov     ds,cx
                xchg    si,di
                mov     si,offset CFont
                mov     cx,32*256
                mov     ax,cs
                mov     ds,ax
                rep     movsb                   ; move it into buffer program requested
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     di
                pop     si
                pop     ax
                mov     al,00h
                ret
FontGetT        endp

NeededCPU       proc
                mov     al,CpuNeeded
                ret
NeededCPU       endp

UpdateCharRAM   proc
                call    SetVid
                ret
UpdateCharRAM   endp

; our INT 68h handler
Int68           proc
                cmp     ah,0            ; get version? (AH = 0
                ja      Int68e          ; if not, look at function table
                mov     ax,VERSION
                mov     bx,01234h
                mov     cl,VERSIONSUB
                jmp     Int68end        ; done
Int68e:         cmp     ah,14h
                ja      Int68end
                push    bx
                mov     bl,ah
                dec     bl
                xor     bh,bh
                shl     bx,1
                add     bx,offset FuncTabl
                call    WORD PTR cs:[bx]
                pop     bx
Int68end:       iret
Int68           endp

; utilites

CPUChk          proc
                pushf                   ; Save flag registers, we use them here
                xor     ax,ax           ; Clear AX and...
                push ax                 ; ...push it onto the stack
                popf                    ; Pop 0 into flag registers (all bits to 0),
                pushf                   ; attempting to set bits 12-15 of flags to 0's
                pop     ax                      ; Recover the save flags
                and     ax,08000h       ; If bits 12-15 of flags are set to
                cmp     ax,08000h       ; zero then it's 8088/86 or 80188/186
                jz      CPUChk1
                mov     ax,07000h       ; Try to set flag bits 12-14 to 1's
                push ax                 ; Push the test value onto the stack
                popf                    ; Pop it into the flag register
                pushf                   ; Push it back onto the stack
                pop     ax                      ; Pop it into AX for check
                and     ax,07000h       ; if bits 12-14 are cleared then
                jz      CPUChk2         ; the chip is an 80286
                mov     ax,3            ; We now assume it's a 80386 or better
                popf
                ret
CPUChk1:        mov     ax,0
                popf
                ret
CPUChk2:        mov     ax,2
                popf
                ret
CPUChk          endp

prints          proc
                push    si
                push    ax
                push    bx
PS1:            mov     ah,0Eh
                mov     bl,0
                mov     bh,07h
                mov     al,[si]
                cmp     al,0
                je      PS2
                inc     si
                int     10h
                jmp     PS1
PS2:            pop     bx
                pop     ax
                pop     si
                ret
prints          endp

ChkVGA          proc                    ; this routine looks for the VGA's pallete registers and determines if it is there
                push    dx
                push    ax
                mov     dx,3C8h
                mov     al,4
                out     dx,al           ; The pallete index register will return the color it is pointing to
                in      al,dx
                cmp     al,4
                jne     NoVGA
                mov     al,255
                out     dx,al
                in      al,dx
                cmp     al,255
                jne     NoVGA
                mov     al,0
                out     dx,al
                in      al,dx
                jne     NoVGA
                stc                     ; Set carry flag to indicate it's there
                jmp     EnVGA
NoVGA:          clc
EnVGA:          pop     ax
                pop     dx
                ret
ChkVGA          endp

code            ends

                end     main

