
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
    ; saving old interrupt vector --> Get current interrupt handler for INT 21h
    mov ax, 3521h ; DOS function 35h GET INTERRUPT VECTOR for interrupt 21h --> AH=35h - GET INTERRUPT VECTOR and AL=21h for int 21
    int 21h ; Call DOS  (Current interrupt handler returned in ES:BX)
    mov [old_interrupt_21h], bx
    mov [old_interrupt_21h + 2], es

    ; setting new interrupt vector
    cli ; Clear interrupt flag; interrupts disabled when interrupt flag cleared.
    push ds
    push cs
    pop ds
    lea dx, myint21h ; Load DX with the offset address of the start of this TSR program (the virus body)
    mov ax, 2521h ; DOS function 25h SET INTERRUPT VECTOR for interrupt 21h
    int 21h
    pop ds
    sti ;Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction.

    ; TSR
    mov dx, 00ffh  ; I don't know how many paragraphs to keep resident, so keep a bunch (maybe its will change) 
    mov ax, 3100h ; DOS function TSR, return code 00h
    int 21h       ; Call my own TSR program first, then call DOS

    ; here comes data & hew handler part
    .data
    old_interrupt_21h dw ?, ?

    myint21h proc ;specifies that the procedure is a standard procedure function
    ; here come the virus  body
    
    
    
    ; transfer control to an old interrupt 21h handler
        push word ptr [cs:old_interrupt_21h + 2] ; segment
        push word ptr [cs:old_interrupt_21h]     ; offset
        retf
    myint21h endp

end start



