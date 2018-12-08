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

