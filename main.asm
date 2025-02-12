.model small
.stack 100h

data SEGMENT     
;==================================================================================
; PROPERTIES & VARIABLES
;==================================================================================    
	; Player 1 Stats
	P1Health DB 3  
	P1MaxHealth DB 100    
	P1LightAttackDamage DB 25
	P1HeavyAttackDamage DB 50     
	P1Defense DB 30      
	P1CriticalChance DB 50
	
	; Player 2 Stats
	P2Health DB 100   
	P2MaxHealth DB 100  
	P2LightAttackDamage DB 25
	P2HeavyAttackDamage DB 50     
	P2Defense DB 30      
	P2CriticalChance DB 50         

	; Class Stats (HP, MaxHP, LDmg, HDmg, Def, CC)
	KnightStats    DB 100, 100,  20,  50,  40,  10  ; Balanced, high defense
	AssassinStats  DB  60,  60,  30,  20,  20,  50  ; Lower health, high crit chance
	DuelistStats   DB  90,  90,  35,  15,  25,  20  ; Good health, High LDmg and medium crit
		         
;==================================================================================
; STRINGS
;==================================================================================  
	; Player Names
    P1 DB 'Player 1:', '$'        
    
    ; Class Names
    Knight DB 'Knight', '$'     
    Assassin DB 'Assassin', '$'
    Duelist DB 'Duelist', '$'    
    
    ; Game Option Texts    
    P1ClassSelection DB 'Choose Your Class! (Press 1-Knight, 2-Assassin, or 3-Duelist): ', '$'  
    YouCheckIf DB 'You Selected Class ', '$' 
    Player1Stats DB 0DH, 0AH, 'Player 1 Stats:', '$'  
    
    ; Stat Printing Texts
    HealthText DB 0DH, 0AH, 'Health: ', '$' 
    MaxHealthText DB 0DH, 0AH, 'MaxHealth: ', '$'
    LightAttackDamageText DB 0DH, 0AH, 'Light Attack Damage: ', '$'
    HeavyAttackDamageText DB 0DH, 0AH, 'Heavy Attack Damage: ', '$'
    DefenseText DB 0DH, 0AH, 'Defense: ', '$'
    CriticalChanceText DB 0DH, 0AH, 'Critical Chance: ', '$'
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
	 	          
	; Function to print newline, equivalent to '\n'. Requires PrintChar 	          
	PrintNewline:
        MOV DL, 0Dh
        CALL PrintChar
        MOV DL, 0Ah
        CALL PrintChar    
        RET
	; Function To take Input From User, Stored in AL
	TakeCharInput:
		MOV AH, 01h        ; DOS function to read a character 
	    INT 21h            ; Input from user
	    RET         
 	
 	; This function converts an Integer to a String and then prints it
 	; Each digit in the int has to be scanned individually and then 
 	; you have to add '0' to convert it to a Character 
 	; This assumes your number has been loaded into AX register
	PrintInt:	    
	    MOV BX, 10         ; Divisor = 10 To get Remain	   		    	 
		ExtractDigitsFromInt:
		    MOV DX, 0h          ; Clear DX 
		    DIV BX              ; AX / 10 -> Quotient in AX, Remainder in DX
		    ADD DL, '0'         ; Convert remainder to ASCII  	    
		    CALL PrintChar
		    CMP AX, 0000h         ; Check if all digits extracted
		    JNZ ExtractDigitsFromInt ; If not, continue loop
   		RET

 	 
 	PrintP1Stats:
 		MOV DX, OFFSET Player1Stats
 		CALL PrintLine    
 		MOV DX,0000h ; Reset DX 		
 		; Print Health	
 		MOV DX, OFFSET HealthText
 		CALL PrintLine	  
 		MOV AH, 00h		 	
 		MOV AL, P1Health       
 		CALL PrintInt 	
 		; Print Max Health	
 		MOV DX, OFFSET MaxHealthText
 		CALL PrintLine	  		 	
 		MOV DL, P1MaxHealth       
 		CALL PrintLine 	 
 		; Print Light Atk Damage	
 		MOV DX, OFFSET LightAttackDamageText
 		CALL PrintLine	  		 	
 		MOV DL, P1LightAttackDamage       
 		CALL PrintLine 		              
 		; Print Heavy Atk Damage
 		MOV DX, OFFSET HeavyAttackDamageText
 		CALL PrintLine	  		 	
 		MOV DL, P1HeavyAttackDamage       
 		CALL PrintLine 
 		; Print Defense	
 		MOV DX, OFFSET DefenseText
 		CALL PrintLine	  		 	
 		MOV DL, P1Defense
 		CALL PrintLine 
 		 ; Print Critical Chance	
 		MOV DX, OFFSET CriticalChanceText     
 		CALL PrintLine	  		 	
 		MOV DL, P1CriticalChance       
 		CALL PrintLine 
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
        
    ; Print Player Stats
    CALL PrintP1Stats       
    
               
    ; Exit Program
    MOV AH, 4Ch        ; DOS function to terminate program
    INT 21h            ; Exit program
code ENDS
END main
