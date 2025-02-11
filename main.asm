.model small
.stack 100h

.data
    msg db 'Hello, World!$'  ; String to print (terminated with `$` for DOS)

.code
main:               
    MOV AX, data
    MOV DS, AX       

    ; Print "Hello, World!"
    MOV DX, OFFSET msg  ; Load the address of the string
    MOV AH, 09h    		; DOS print string function
    int 21h             ; Call DOS interrupt

    ; Exit program
    mov ah, 4Ch
    INT 21h         
END main
