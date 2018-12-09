;----------------------------------------------------------------------------
; SaveRegisters
;----------------------------------------------------------------------------
; Description: Saves the contents of all the registers on the stack
; Arguments:  <none>
; Registers Destroyed: <none>
SaveRegisters MACRO
push ax
push bx
push cx
push dx
push es
push ds
push si
push di
push bp
pushf
ENDM
;----------------------------------------------------------------------------
; RestoreRegisters
;----------------------------------------------------------------------------
; Description: Restores the contents of all the registers from the stack
; Arguments: <none>
; Registers Destroyed: ax, bx, cx, dx, es, ds, si, di, bp, flags
RestoreRegisters MACRO
popf
pop bp
pop di
pop si
pop ds
pop es
pop dx
pop cx
pop bx
pop ax
ENDM
;----------------------------------------------------------------------------
; PrintReturnCode
;----------------------------------------------------------------------------
; Description: Displays the return code stored in the register AX 
; Arguments: AX contains the code to be displayed
; Registers Destroyed: <none>
PrintReturnCode MACRO
pushf
push ax
push bx
push cx
xchg ax,cx ;save return code
xor bx,bx
mov ah,0Eh
mov al,ch
add al,'0'
int 10h ;display high bit
mov al,cl
add al,'0'
int 10h ;display low bit
pop cx
pop bx
pop ax
popf
ENDM
;----------------------------------------------------------------------------
; Printf
;----------------------------------------------------------------------------
; Description: Displays a string, and goes to the next line. The string should end with a NULL character 0x00
; Arguments: ds:si: Address of the string to be displayed
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
mov al,0Dh ;display carriage return ...
int 10h
mov al,0Ah ;... and line feed
int 10h
pop bx
ret
Printf ENDP
;----------------------------------------------------------------------------
; GetRelocation
;----------------------------------------------------------------------------
; Description: Gets the relocation value (aka delta offset) i.e the value that must be added to each variable in the program 
; if the program has been relocated. The program gets relocated when it attaches itself to the host file.
; If the program has not been relocated, the value returned is 0
; Arguments:  Register: Register in which the value is to be stored
; Registers Destroyed: <none>
GetRelocation MACRO Register
LOCAL GetIPCall
call GetIPCall ;this will push the IP on the stack
GetIPCall:
pop Register
sub Register, offset GetIPCall
ENDM
