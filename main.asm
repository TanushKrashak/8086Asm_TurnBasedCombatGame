.model small
.stack 100h

.data
    num1 dw 5       ; First number
    num2 dw 10      ; Second number
    result dw 0     ; Variable to store the result


.code
main:    
    mov ax, @data
    mov ds, ax
    
    mov ax, num1
    mov bx, num2
    add ax, bx    
    mov result, ax

    mov ah, 4Ch
    int 21h
end main
