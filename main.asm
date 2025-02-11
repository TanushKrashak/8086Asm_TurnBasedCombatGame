.model small
.stack 100h

data SEGMENT
    msg DB 'Hello, World!$' ; String to print (terminated with `$` for DOS)                 
data ENDS

code SEGMENT     
main:        
    MOV AX, data
    MOV DS, AX       

    ; Print "Hello, World!"
    MOV DX, OFFSET msg  ; Load the address of the string
    MOV AH, 09h    		; DOS print string function
    INT 21h             ; Call DOS interrupt


    ; Exit program
    MOV AH, 4Ch        
    INT 21h         
code ENDS
END main     
