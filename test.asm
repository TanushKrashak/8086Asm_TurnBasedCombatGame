.model small
.stack 100h

data SEGMENT
    test_health db 03h
    death_msg db 'You are dead :(', '$'  
    placeholder db 'Alive! ', '$'
data ENDS

code SEGMENT     
    print_newline:
        MOV DL, 0Dh
        CALL print_char
        MOV DL, 0Ah
        CALL print_char    
        RET
        
    print_line:
        MOV ah, 09h
        INT 21h    
        CALL print_newline
        RET

    print_char:
        MOV ah, 02h
        INT 21h
        RET

main:   
    MOV AX, data
    MOV DS, AX   
    MOV AL, [test_health]
    CMP AL, 0
    JE end

    DEC AL
    MOV [test_health], AL

    MOV DX, offset placeholder
    CALL print_line
    JMP main;
                       
                       
end:                   
    MOV AL, test_health

    MOV DX, offset death_msg
    CALL print_line

    MOV AH, 4Ch
    INT 21h

code ENDS
END main
