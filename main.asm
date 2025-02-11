.model small
.stack 100h

data SEGMENT
    P1 DB 'Player 1:', '$'
    P1ClassSelection DB 'Choose Your Class! (Press 1, 2, or 3): ', '$'  
    YouSelected DB 'You Selected Class ', '$'
data ENDS

code SEGMENT
main:
    MOV AX, data
    MOV DS, AX         ; Initialize Data Segment
               
    ; Print P1 MSG           
    MOV DX, OFFSET P1  
    MOV AH, 09h        ; DOS print string function
    INT 21h            ; Print Player 1 message
    
    ; Insert line break after MSG
    MOV DL, 0Dh        ; Carriage Return (CR)
    MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print Carriage Return
    MOV DL, 0Ah        ; Line Feed (LF)
    MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print Line Feed
          
    ; Print P1ClassSelection MSG
    MOV DX, OFFSET P1ClassSelection  
    MOV AH, 09h        ; DOS print string function
    INT 21h            ; Print class selection prompt
    
    ; Get User Input (Single Character)
    MOV AH, 01h        ; DOS function to read a character 
    INT 21h            ; Input from user
    MOV BX, AX         ; Store input in BX
        
    ; Insert a line break after printing input
    MOV DL, 0Dh        ; Carriage Return (CR)
    MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print Carriage Return
    MOV DL, 0Ah        ; Line Feed (LF)
    MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print Line Feed
    
    ; Print the input          
    MOV DX, OFFSET YouSelected
    MOV AH, 09h        ; DOS print string function
    INT 21h            ; Print "You Selected Class"
    
    ; Print the input character from BX
    MOV DL, BL         ; Move the input character to DL for printing
    MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print the input character

    ; Exit Program
    MOV AH, 4Ch        ; DOS function to terminate program
    INT 21h            ; Exit program

code ENDS
END main
