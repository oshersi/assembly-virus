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
