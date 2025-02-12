.model small
.stack 100h

data SEGMENT
    P1 DB 'Player 1:', '$'
    P1ClassSelection DB 'Choose Your Class! (Press 1, 2, or 3): ', '$'  
    YouSelected DB 'You Selected Class ', '$'
data ENDS

code SEGMENT     
; Function For Printing A Line
PrintLine:
	MOV AH, 09h        ; DOS print string function
    INT 21h            ; Print Msg
 	RET        
 
; Function For Printing A Character
PrintChar:
	MOV AH, 02h        ; DOS function to print a character
    INT 21h            ; Print Carriage Return     
    RET
 	
; Function To take Input From User
TakeCharInput:
	MOV AH, 01h        ; DOS function to read a character 
    INT 21h            ; Input from user
    RET
 	
main:
    MOV AX, data
    MOV DS, AX         ; Initialize Data Segment
               
    ; Print P1 MSG           
    MOV DX, OFFSET P1  
	CALL PrintLine
    
    ; Insert line break after MSG
    MOV DL, 0Dh        ; Carriage Return (CR)
    CALL PrintChar
    MOV DL, 0Ah        ; Line Feed (LF)
	CALL PrintChar
          
    ; Print P1ClassSelection MSG
    MOV DX, OFFSET P1ClassSelection  
	CALL PrintLine
    
    ; Get User Input (Single Character)   
    CALL TakeCharInput
    MOV BL, AL         ; Store input in BX
        
    ; Insert a line break after printing input
    MOV DL, 0Dh        ; Carriage Return (CR)
	CALL PrintChar
    MOV DL, 0Ah        ; Line Feed (LF)
	CALL PrintChar
    
    ; Print the input          
    MOV DX, OFFSET YouSelected
	CALL PrintLine
    
    ; Print the input character from BX
    MOV DL, BL         ; Move the input character to DL for printing
	CALL PrintChar

    ; Exit Program
    MOV AH, 4Ch        ; DOS function to terminate program
    INT 21h            ; Exit program
code ENDS
END main
