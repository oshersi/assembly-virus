
;----------------------------------------------------------------------------
; Printf
;----------------------------------------------------------------------------
; Description: Displays a string, and goes to the next line. The string should end with a NULL character 0x00
; Arguments:  ds:si: Address of the string to be displayed
; Registers Destroyed: ax
Printf PROC
push bx
mov ah,0Eh ;teletype output
xor bx, bx ;page 0
DISPLAY_CHAR:
lodsb ;get next character
int 10h ;display
test al, al ;end of string?
jne DISPLAY_CHAR
mov al,0Dh ;display carriage return 
int 10h
mov al,0Ah ;  and line feed
int 10h
pop bx
ret
Printf ENDP
;----------------------------------------------------------------------------
; HookISR
;----------------------------------------------------------------------------
; Description: Installs a new interrupt service routine
; Arguments: AL: Interrupt number , SI: Buffer in which to save old ISR address (DWORD) , DX: Address of new ISR
; Registers Destroyed: ah, bx, es
HookISR PROC
mov ax, 3521h ; saving old interrupt vector --> Get current interrupt handler for INT 21h . AH=35h - GET INTERRUPT VECTOR and AL=21h for int 21
int 21h ;Get Address of Old ISR  --> Call DOS  (Current interrupt handler returned in ES:BX)
mov word ptr [si], bx ;Save it
mov word ptr [si+2], es
mov ah, 25h ;Install New ISR
int 21h
ret
HookISR ENDP
