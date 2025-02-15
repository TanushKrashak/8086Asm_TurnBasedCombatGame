.model small
.stack 100h

data SEGMENT     
;==================================================================================
; PROPERTIES & VARIABLES
;==================================================================================    	
	; Game Stats
	TotalStats   DB 6 
	MaxStamina   DB 100
	LStaminaCost DB 15 ; LAttack cost
	HStaminaCost DB 35 ; HAttack cost
	BStaminaCost DB 5   ; Block cost
	; Ultimate cost would be 100 anyways, so no need to declare it here.
	HPGainPerTurn DB 5
	STGainPerTurn DB 10
	
	
	; Player Stats
	Player1Stats  	DB 0,0,0,0,0,0,0	
	Player2Stats  	DB 0,0,0,0,0,0,0
	Player3Stats  	DB 0,0,0,0,0,0,0
	Player4Stats  	DB 0,0,0,0,0,0,0   
	PlayersStamina	DB 80, 80, 80, 80     ; All players' stamina stored here
	PlayersCooldown DB 0, 0, 0, 0         ; All players' ultimate cooldown, wraps after their class' UltC   
	
	; Player Statuses
	; burn,poison,paralyse,0,vitality,rage,0,0
	Player1Status  DB 0000000B
	Player2Status  DB 0000000B
	Player3Status  DB 0000000B
	Player4Status  DB 0000000B

    PlayerCount      DB 4	; Number of players, 4
    CurrentTurn      DB 0	; Indicate which player's turn it is, takes values between 0-3 inclusive
    AliveState       DB 00000000B	; p4_alive, p3_alive, p2_alive, p1_alive. Lower nibble reserved
    CurrentTurnStats DB 00000000B ; p4_crit, p3_crit, p2_crit, p1_crit, p4_block, p3_block, p2_block, p1_block

	; Class Stats (HP, MaxHP, LDmg, HDmg, Def, CC, UltC)
	KnightStats    	DB  85,  85,  20,  35,  60,  30,  3 ; Balanced, high defense
	AssassinStats  	DB  60,  60,  30,  40,  20,  50,  4 ; Lower health, high crit chance
	PyromancerStats	DB  50,  50,  20,  30,  40,  30,  4 ; Lower stats overall, but compensated by burn passive
	HealerStats    	DB  70 , 70,  15,  30,  30,  30,  4  ; LDmg deals actual damage to enemy, HDmg heals teammate
	VanguardStats  	DB  100, 100, 10,  35,  100, 5,   4  ; Max HP and Def, very low crit
	VampireStats   	DB  70,  70,  15,  25,  30,  25,  4  ; High health, low attack to account for 50% heal chance
		         
;==================================================================================
; STRINGS
;==================================================================================  
	; Player Names
    PlayerText DB 'Player ', '$'           
    
    ; Class Names
    Knight DB 'Knight', '$'     
    Assassin DB 'Assassin', '$'
    Pyromancer DB 'Pyromancer', '$'
    Healer DB 'Healer', '$'
    Vanguard DB 'Vanguard', '$'
    Vampire DB 'Vampire', '$'      
    
    ; Game Option Texts    
    PrintPlayerStatsText DB 'Choose Your Class!',0Dh,0Ah, '[1]-Knight',0Dh,0Ah, '[2]-Assassin',0Dh,0Ah, '[3]-Pyromancer',0Dh,0Ah, '[4]-Healer',0Dh,0Ah, '[5]-Vanguard',0Dh,0Ah, '[6]-Vampire ',0Dh,0Ah, '$'
    ChooseYourMoveText DB 'Make Your Choice!',0Dh,0Ah, '$'
    MoveChoicesText DB '1-Light Attack',0Dh,0Ah, '2-Heavy Attack',0Dh,0Ah, '3-Defend',0Dh,0Ah, '4-Heal',0Dh,0Ah, '5-Ultimate',0Dh,0Ah, '$'
    YouCheckIfText DB 'You Selected Class ', '$' 
    StatsText DB 'Stats:', '$'      
    
    ; Stat Printing Texts
    HealthText DB 0DH, 0AH, 'Health: ', '$' 
    MaxHealthText DB 0DH, 0AH, 'MaxHealth: ', '$'
    LightAttackDamageText DB 0DH, 0AH, 'Light Attack Damage: ', '$'
    HeavyAttackDamageText DB 0DH, 0AH, 'Heavy Attack Damage: ', '$'
    DefenseText DB 0DH, 0AH, 'Defense: ', '$'
    CriticalChanceText DB 0DH, 0AH, 'Critical Chance: ', '$' 
    StaminaText DB 0DH, 0AH, 'Stamina: ', '$' 

	; In-Combat Texts
	Crit_Message DB 'Critical Hit!', '$'
    Hit_Message DB 'Normal Hit!', '$' 
    AllDeadMsg DB 'All players are dead!', '$'

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
	 
    ; Restore Stamina of each player after every turn by STGainPerTurn. Increases stamina of a dead player too, as it doesn't matter since they can't act and upon revival, stamina is restored to 100 regardless
    RecoverStamina:
        MOV AL, STGainPerTurn
        MOV SI, OFFSET PlayersStamina
        MOV CX, 4
        StaminaRecoveryLoop: 
            MOV AH, [SI]
            ADD AH, AL
            CMP AH, 100
            JNC NoClamp
            MOV AH, 100             ; Current Player's stamina is above 100, clamp that mf
            NoClamp:
                MOV [SI], AH        ; Since SI holds address of current player's stamina, store updated stamina value back into it
            PDead:                  
                INC SI              ; Move to the next player
                LOOP StaminaRecoveryLoop
        RET
    
    ; Set block bit in CurrentTurnStatus for player with current turn.
    ; Must be called after AlternateTurn, as this function does NOT check the AliveStatus block
    SetBlock:
        MOV AL, CurrentTurnStats
        MOV AH, CurrentTurn
        CMP CurrentTurn, 0
        JNE P2_Check
        OR AL, 000000001B           ; Set Player 1's block bit
        MOV CurrentTurnStats, AL
        RET
        P2_Check:
            CMP CurrentTurn, 1
            JNE P3_Check
            OR AL, 00000010B        ; Set Player 2's block bit
            MOV CurrentTurnStats, AL
            RET
        P3_Check:
            CMP CurrentTurn, 2
            JNE P4_Check
            OR AL, 00000100B        ; Set Player 3's block bit
            MOV CurrentTurnStats, AL
            RET
        P4_Check:
            OR AL, 00001000B        ; Set Player 4's block bit
            MOV CurrentTurnStats, AL 
            RET   
    
    ; Update AliveState after every turn by checking HP of every player
    UpdateStatusOnDeath:
        MOV AL, AliveState
        MOV AH, Player1Stats
        CMP AH, 0
        JNE Check_P2_Alive
        AND AL, 11101111B       ; P1 dead, reset their alive bit
        Check_P2_Alive:
            MOV AH, Player2Stats
            CMP AH, 0           
            JNE Check_P3_Alive
            AND AL, 11011111B   ; P2 dead, reset their alive bit
        Check_P3_Alive:
            MOV AH, Player3Stats
            CMP AH, 0
            JNE Check_P4_Alive
            AND AL, 10111111B    ; P3 dead, reset their alive bit
        Check_P4_Alive:
            MOV AH, Player4Stats
            CMP AH, 0
            JNE UpdateStatusOnDeath_Final
            AND AL, 01111111B    ; P4 dead, reset their alive bit
        UpdateStatusOnDeath_Final:
            MOV AliveState, AL  ;Update AliveState finally   
            RET
            
	; Load system time into CX and DX (CH: Hour, CL: Minute, DH: Second, DL: 1/100th of a second)
	GetTime:
        MOV AH, 2CH
        INT 21H  
        RET
        
    ; Loads current player's stats into SI
    LoadPStats:
	    ; Check Turn 0 (Player 1)  
		CMP CurrentTurn, 0
		JNE LCheckForOneTurn
		MOV SI, OFFSET Player1Stats		
		JMP LEndPrintPlayerName
		LCheckForOneTurn:
		    ; Check Turn 1 (Player 2)  
			CMP CurrentTurn, 1
			JNE LCheckForTwoTurn
			MOV SI, OFFSET Player2Stats			
			JMP LEndPrintPlayerName
		LCheckForTwoTurn:
		    ; Check Turn 2 (Player 3)  
			CMP CurrentTurn, 2
			JNE LCheckForThreeTurn
			MOV SI, OFFSET Player3Stats			
			JMP LEndPrintPlayerName
		LCheckForThreeTurn:
			; Turn 3 (Player 4)	
			MOV SI, OFFSET Player4Stats		  
			JMP LEndPrintPlayerName
		LEndPrintPlayerName:
		    CALL LoadPlayerStats
		    SUB SI, 7	    		  			
			RET 
                 
	; Generic random function, expects chance in AL. Returns 1/0 in AL 
	GetChance:
	    CALL GetTime   ; Load Counter and Data registers with time data
        MOV BL, TotalStats    ; Load length of array for based offset later   
        MOV BH, 0   ;Ensure BX is same as BL in terms of actual value
        CMP AL, DL      ; DL has hundredth of a second
        JNC SetChanceTrue
        MOV AL, 0
        RET
        SetChanceTrue:
            MOV AL, 1 
        RET          
        
    ; Updates critical bit in CurrentTurnStatus for players
    UpdateCrit:
        
        ; Determine current player
        MOV AH, CurrentTurn

        MOV AL, [Player1Stats + BX]  ;Load chance to be compared into AL
        CALL GetChance
        JNC GoodLuck ;If current 1/100 of second is less than crit chance, we have critical hit >:)    
        ; Logic for normal hit
        MOV DX, OFFSET Hit_Message 
        CALL PrintLine
        CMP AH, 0   ; P1?
        JNE P1_ResetCritical
        AND AL, 11101111b ;Reset P1_Crit
        JMP bGetChance_Final
        P1_ResetCritical:
            CMP AH, 1
            JNE P2_ResetCritical
            AND AL, 11011111b;Reset P2_Crit
            JMP bGetChance_Final
        P2_ResetCritical:
            CMP AH, 2
            JNE P3_ResetCritical
            AND AL, 10111111b ;Reset P3_Crit
            JMP bGetChance_Final
        P3_ResetCritical:
            AND AH, 01111111b    ;  Reset P4_Crit
            JMP bGetChance_Final    
        ;Critical Hit
        GoodLuck:
            MOV DX, OFFSET Crit_Message
            CALL PrintLine
            MOV AH, CurrentTurn 
            MOV AL, CurrentTurnStats
            CMP AH, 0
            JNE P1_SetCritical
            OR AL, 00010000b ;Set P1_Crit 
            JMP bGetChance_Final
            P1_SetCritical:
                CMP AH, 1     
                JNE P2_SetCritical
                OR AL, 00100000b ;Set P2_Crit
                JMP bGetChance_Final 
            P2_SetCritical:
                CMP AH, 2  
                JNE P3_SetCritical
                OR AL, 01000000b ;Set P3_Crit
                JMP bGetChance_Final
            P3_SetCritical:
                OR AL, 10000000b ;Set P4_Crit
        bGetChance_Final:
        	MOV CurrentTurnStats, AL
        	RET 

	; Circular increments current turn
     WrappedIncrement:
        INC CurrentTurn
        CMP CurrentTurn, 4
        JE WrappedIs4
        RET
        WrappedIs4: 
            MOV CurrentTurn, 0
            RET
	
	; Progress player turns
	 AlternateTurn:
        ; Each recursive call increments DH by 1. At DH = 4 (0->1->2->3-->4), we know that 4 recursions were already made. In this case, all players are dead
        INC DH
        CMP DH, 4
        JE AllDead  ; Jump to AllDead to prevent infinite recursion
        MOV AL, CurrentTurn
        CALL WrappedIncrement   ; Increment AL, wrap if necessary
        MOV DL, AliveState    ; Load AliveState byte into DL to check if the current player is dead or not
        ; AH holds current turn
        CMP AH, 0
        JE P1_Turn
        CMP AH, 1
        JE P2_Turn        
        CMP AH, 2
        JE P3_Turn   
        ; JZ ensures that if the CurrentTurn's player is dead (nth bit = 0), we alternate turn again                
        P4_Turn:
	        TEST DL, 10000000b  ;Check if P4 is alive
	        JZ AlternateTurn                            
	        JMP Final
        P3_Turn:
	        TEST DL, 01000000b  ;Check if P3 is alive    
	        JZ AlternateTurn
	        JMP Final
        P2_Turn:
	        TEST DL, 00100000b  ;Check if P2 is alive
	        JZ AlternateTurn
	        JMP Final
        P1_Turn:
	        TEST DL, 00010000b  ;Check if P1 is alive
	        JZ AlternateTurn
	        JMP Final
        Final:
	        MOV DH, 0
	        RET
        ; Exception Case: All players are dead
        AllDead:
        MOV DX, OFFSET AllDeadMsg
        CALL PrintLine
        CALL PrintNewLine
        RET     
        
 	; This function converts an Integer in AL to a String and then prints it
 	; Each digit in the int has to be scanned individually and then 
 	; you have to add '0' to convert it to a Character 
	PrintInt:	 
		MOV AH, 00h	   
	    MOV BX, 10         ; Divisor
	    MOV CX, 0	   		
	    ; Basically just pushes remainder to stack
	    ; and then once all of the digits are done being pushed, it 
	    ; starts popping from the stack and prints them 1 at a time    	 
		ExtractDigitsFromInt:
		    MOV DX, 0h          ; Clear DX 
		    DIV BX              ; AX / 10 -> Quotient in AX, Remainder in DX
		    ADD DL, '0'         ; Convert remainder to ASCII  	
		    INC CX              ; keep track of digits count
		    PUSH DX		    
		    CMP AX, 0000h         ; Check if all digits extracted
		    JNZ ExtractDigitsFromInt ; If not, continue loop  		            
		PopFromStack:
			POP DX
			CALL PrintChar 
			MOV AH, 0h
			LOOP PopFromStack     ; keep going till CX becomes 0
   		RET

 	; Prints the player stats
	PrintPlayerStats:
 	    ; Print Player Num Stats: 
 	    CALL PrintPlayerName
		MOV DX, OFFSET StatsText		 	     	 
    	CALL PrintLine    	     	        	
 		; Print Health	
 		MOV DX, OFFSET HealthText
 		CALL PrintLine	   			 
 		MOV AL, [SI]       
 		CALL PrintInt 	
 		; Print Max Health	
 		MOV DX, OFFSET MaxHealthText
 		CALL PrintLine	  		 	
 		MOV AL, [SI+1]       
 		CALL PrintInt 	 
 		; Print Light Atk Damage	
 		MOV DX, OFFSET LightAttackDamageText
 		CALL PrintLine	  		 	
 		MOV AL, [SI+2]       
 		CALL PrintInt 		              
 		; Print Heavy Atk Damage
 		MOV DX, OFFSET HeavyAttackDamageText
 		CALL PrintLine	  		 	
 		MOV AL, [SI+3]       
 		CALL PrintInt 
 		; Print Defense	
 		MOV DX, OFFSET DefenseText
 		CALL PrintLine	  		 	
 		MOV AL, [SI+4]
 		CALL PrintInt 
 		 ; Print Critical Chance	
 		MOV DX, OFFSET CriticalChanceText     
 		CALL PrintLine	  		 	
 		MOV AL, [SI+5]       
 		CALL PrintInt    
 		; Print Player Stamina
 		 MOV DX, OFFSET StaminaText     
 		CALL PrintLine	 
 		MOV DH,0h   
 		; Player 1 Stamina
		 CMP CurrentTurn, 0
 		JNE P2StaminaPrintCheck
 		MOV AL, [PlayersStamina+0] 
 		JMP StaminaPrintCheckFinish 	
 		; Player 2 Stamina
 		P2StaminaPrintCheck:     
 			CMP CurrentTurn, 1 
 			JNE P3StaminaPrintCheck
 			MOV AL, [PlayersStamina+1]  
 			JMP StaminaPrintCheckFinish 
 		; Player 3 Stamina
 		P3StaminaPrintCheck:   
 		 	CMP CurrentTurn, 2 
 			JNE P4StaminaPrintCheck
 			MOV AL, [PlayersStamina+2] 
 			JMP StaminaPrintCheckFinish 
 		 ; Player 3 Stamina
 		P4StaminaPrintCheck:  		 	 			
 			MOV AL, [PlayersStamina+3]
 		StaminaPrintCheckFinish:  
 			CALL PrintInt	
 			RET
     
	; Function to get the player's class, stores result
	; in the BL Register     
	SelectPlayerClass:    
	    ; Get User Input
	    CALL TakeCharInput
	    MOV BH, 0
	    MOV BL, AL         ; Store input in BX           
		CALL PrintNewLine   
	  	; Print CheckIf Class Name
	    MOV DX, OFFSET YouCheckIfText     
	    CALL PrintLine
	    ; Knight       
	    CheckIfKnight:
	        CMP BL, '1'
	        JNE CheckIfAssassin
	        MOV DI, OFFSET KnightStats
	        MOV DX, OFFSET Knight
	        JMP EndClassSelection
	    ; Assassin  
	    CheckIfAssassin:  
	        CMP BL, '2'  
	        JNE CheckIfPyromancer  
	        MOV DI, OFFSET AssassinStats  
	        MOV DX, OFFSET Assassin  
	        JMP EndClassSelection   
	    ; Pyromancer  
	    CheckIfPyromancer:  
	        CMP BL, '3'  
	        JNE CheckIfHealer  
	        MOV DI, OFFSET PyromancerStats  
	        MOV DX, OFFSET Pyromancer  
	        JMP EndClassSelection  
	    ; Healer  
	    CheckIfHealer:  
	        CMP BL, '4'  
	        JNE CheckIfVanguard  
	        MOV DI, OFFSET HealerStats  
	        MOV DX, OFFSET Healer  
	        JMP EndClassSelection  
	    ; Vanguard  
	    CheckIfVanguard:  
	        CMP BL, '5'  
	        JNE CheckIfVampire  
	        MOV DI, OFFSET VanguardStats  
	        MOV DX, OFFSET Vanguard  
	        JMP EndClassSelection  
	    ; Vampire  
	    CheckIfVampire:  
	        CMP BL, '6'  
	        JNE EndClassSelection  
	        MOV DI, OFFSET VampireStats  
	        MOV DX, OFFSET Vampire  
	    EndClassSelection:	     
		    CALL PrintLine 
			CALL PrintNewLine			
			CALL PrintNewLine
			RET
	 
	; Loads Player Stats based on the DI Value
	; Player Has To Be Loaded inside SI	
    LoadPlayerStats:           
        MOV CX, 7                    ; Loop counter (7 elements)        
	    LoadPlayerStatsLoop:
	        MOV AL, [DI]    
	        MOV [SI], AL    
	        INC SI          
	        INC DI          
	        LOOP LoadPlayerStatsLoop  ; Repeat until CX = 0
	    RET      
	    
	; Give Player choice for in Combat, Loads Choice in AX	    
	GivePlayerMainChoice:
		CALL PrintPlayerName
		CALL PrintNewLine 				
 	 	MOV DX, OFFSET ChooseYourMoveText  
    	CALL PrintLine   	 
	    MOV DX, OFFSET MoveChoicesText  
    	CALL PrintLine                                    
    	CALL TakeCharInput        
    	CALL PrintNewLine
    	CALL PrintNewLine
    	RET
    	
	; Prints the current turn's player name, can be used to be print
	; all of the player names    	
	PrintPlayerName:      	
		; print "Player"    		
	    MOV DX, OFFSET PlayerText    
	    CALL PrintLine  
	    ; Check Turn 0 (Player 1)  
		CMP CurrentTurn, 0
		JNE CheckForOneTurn
		MOV DX, '1'		
		JMP EndPrintPlayerName
		CheckForOneTurn:
		    ; Check Turn 1 (Player 2)  
			CMP CurrentTurn, 1
			JNE CheckForTwoTurn
			MOV DX, '2'		
			JMP EndPrintPlayerName
		CheckForTwoTurn:
		    ; Check Turn 2 (Player 3)  
			CMP CurrentTurn, 2
			JNE CheckForThreeTurn
			MOV DX, '3'		
			JMP EndPrintPlayerName
		CheckForThreeTurn:
			; Turn 3 (Player 4)	
			MOV DX, '4'	  
			JMP EndPrintPlayerName
		EndPrintPlayerName:	    
			CALL PrintChar
			MOV DX, ' '
			CALL PrintChar			  			
			RET
	    	    
main:
;==================================================================================
; MAIN FUNCTION
;================================================================================== 
    MOV AX, data
    MOV DS, AX        
    
    ; Print P1 MSG           
	CALL PrintPlayerName    
	CALL PrintNewLine   		          
    MOV DX, OFFSET PrintPlayerStatsText  
	CALL PrintLine        
	; Class Selection
	CALL SelectPlayerClass    
    MOV SI, OFFSET Player1Stats
   	CALL LoadPlayerStats    
   	; Print Stats
   	MOV SI, OFFSET Player1Stats
    CALL PrintPlayerStats      
    CALL PrintNewLine 
    CALL PrintNewLine    
    
    ; Print P2 MSG
    MOV CurrentTurn, 1 ; do this for printing correct name
	CALL PrintPlayerName    
	CALL PrintNewLine      	
    MOV DX, OFFSET PrintPlayerStatsText
	CALL PrintLine        
	; Class Selection
	CALL SelectPlayerClass	
    MOV SI, OFFSET Player2Stats
   	CALL LoadPlayerStats    
	; Print Stats 
	MOV SI, OFFSET Player2Stats
    CALL PrintPlayerStats    
    CALL PrintNewLine 
    CALL PrintNewLine      
    
 	; Print P3 MSG
    MOV CurrentTurn, 2 ; do this for printing correct name
	CALL PrintPlayerName    
	CALL PrintNewLine      	
    MOV DX, OFFSET PrintPlayerStatsText
	CALL PrintLine        
	; Class Selection
	CALL SelectPlayerClass	
    MOV SI, OFFSET Player3Stats
   	CALL LoadPlayerStats    
	; Print Stats 
	MOV SI, OFFSET Player3Stats
    CALL PrintPlayerStats    
    CALL PrintNewLine 
    CALL PrintNewLine 
    
 	; Print P4 MSG
    MOV CurrentTurn, 3 ; do this for printing correct name
	CALL PrintPlayerName    
	CALL PrintNewLine      	
    MOV DX, OFFSET PrintPlayerStatsText
	CALL PrintLine        
	; Class Selection
	CALL SelectPlayerClass	
    MOV SI, OFFSET Player4Stats
   	CALL LoadPlayerStats    
	; Print Stats 
	MOV SI, OFFSET Player4Stats
    CALL PrintPlayerStats    
    CALL PrintNewLine 
    CALL PrintNewLine   
                             
	; CHOICES For Round 1 (Should be moved to a function)                          	
	; Give Player 1 Choice	 
	MOV CurrentTurn, 0	
	CALL GivePlayerMainChoice   
	; Give Player 2 Choice	 
	MOV CurrentTurn, 1	
	CALL GivePlayerMainChoice
	; Give Player 3 Choice	 
	MOV CurrentTurn, 2	
	CALL GivePlayerMainChoice   
	; Give Player 4 Choice	 
	MOV CurrentTurn, 3
	CALL GivePlayerMainChoice
	         
                   
    MOV AH, 4Ch        ; DOS function to terminate program
    INT 21h            ; Exit program
code ENDS
END main
