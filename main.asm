.model small
.stack 100h

data SEGMENT     
;==================================================================================
; PROPERTIES & VARIABLES
;==================================================================================    
	; Player 1 Stats
	P1Health DB 100      
	P1LightAttackDamage DB 25
	P1HeavyAttackDamage DB 50     
	P1Defense DB 30      
	P1CriticalChance DB 50
	
	; Player 2 Stats
	P2Health DB 100      
	P2LightAttackDamage DB 25
	P2HeavyAttackDamage DB 50     
	P2Defense DB 30      
	P2CriticalChance DB 50         
	         
	; Strings
    P1 DB 'Player 1:', '$'        
    Knight DB 'Knight', '$'     
    Assassin DB 'Assassin', '$'
    Duelist DB 'Duelist', '$'    
    P1ClassSelection DB 'Choose Your Class! (Press 1-Knight, 2-Assassin, or 3-Duelist): ', '$'  
    YouCheckIf DB 'You Selected Class ', '$'
data ENDS
      
      
code SEGMENT
;==================================================================================
; FUNCTIONS
;==================================================================================    
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
	 	
	; Function To take Input From User, Stored in AL
	TakeCharInput:
		MOV AH, 01h        ; DOS function to read a character 
	    INT 21h            ; Input from user
	    RET         
 	 
 	      	      
main:
;==================================================================================
; MAIN FUNCTION
;================================================================================== 
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
    
    ; Get User Input
    CALL TakeCharInput
    MOV BL, AL         ; Store input in BX
        
    ; Insert a line break after printing input
    MOV DL, 0Dh        ; Carriage Return (CR)
	CALL PrintChar
    MOV DL, 0Ah        ; Line Feed (LF)
	CALL PrintChar
    
  	; Print CheckIf Class Name
    MOV DX, OFFSET YouCheckIf     
    CALL PrintLine       
    ; Knight  
    CheckIfKnight:
	    CMP BL,'1'      
	    JNE CheckIfAssassin        
		MOV DX, OFFSET Knight
		CALL PrintLine 
		CALL EndClassSelection    
	; Assassin  
	CheckIfAssassin:  	
	    CMP BL,'2'       
	    JNE CheckIfDuelist:    
    	MOV DX, OFFSET Assassin
    	CALL PrintLine 
    	CALL EndClassSelection 	
	; Duelist
	CheckIfDuelist:    	
		CMP BL,'3'       
		JNE EndClassSelection:		 
    	MOV DX, OFFSET Duelist
    	CALL PrintLine 
    	CALL EndClassSelection 	
    EndClassSelection:    
               
               
    ; Exit Program
    MOV AH, 4Ch        ; DOS function to terminate program
    INT 21h            ; Exit program
code ENDS
END main
