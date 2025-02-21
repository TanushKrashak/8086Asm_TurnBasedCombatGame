.model small
.stack 100h

data SEGMENT                                                                          	
;==================================================================================
; PROPERTIES & VARIABLES
;==================================================================================    	
	; Game Stats
	TotalStats              DB 6 
	MaxStamina              DB 100
	LightAttackStaminaCost  DB 15
	HeavyAttackStaminaCost  DB 30
	DefendStaminaCost       DB 5
	UltimateAttackStaminaCost DB 80 
	HPGainPerTurn           DB 5
	STGainPerTurn           DB 10
	KnightExtraSTGain       DB 5  
	BurnDamage              DB 10
	BurnDuration            DB 2
	PoisonDamage            DB 5
	PoisonDuration          DB 4
	
	; Player Stats
	Player1Stats  	DB 0,0,0,0,0,0,0	
	Player2Stats  	DB 0,0,0,0,0,0,0
	Player3Stats  	DB 50,50,0,0,0,0,0
	Player4Stats  	DB 0,0,0,0,0,0,0   
	PlayersStamina	DB 100,100,100,100     ; All players' stamina stored here
	PlayersUltCooldown DB 0,0,0,0         ; All players' ultimate cooldown, wraps after their class' UltC   
	
	; Player Statuses
	; burn,poison,paralyse,vitality,rage,LAtk,HAtk,Ult
	Player1Status   DB 11000000B
	Player2Status   DB 11000000B
	Player3Status   DB 11000000B
	Player4Status   DB 11000000B
	      
	; Debuff Countdowns
	P1BurnCounter       DB 1
	P2BurnCounter       DB 1
	P3BurnCounter       DB 1
	P4BurnCounter       DB 1
	P1PoisonCounter     DB 1
	P2PoisonCounter     DB 1
	P3PoisonCounter     DB 1
	P4PoisonCounter     DB 1	
	
	; Buff Countdowns
	Team1Vitality 	DB 0
	Team2Vitality 	DB 0
    
    ; Game Helpers
    PlayerCount        DB 4	; Number of players
    CurrentTurn        DB 0	; Indicate which player's turn it is, takes values between 0-3 inclusive
    AliveAndHealStatus DB 11110000B	; p4_alive, p3_alive, p2_alive, p1_alive, p4_heal,p3_heal,p2_heal,p1_heal
    CurrentTurnStats   DB 00000000B ; p4_crit, p3_crit, p2_crit, p1_crit, p4_block, p3_block, p2_block, p1_block  
    CurrentlyTargeting DB 00000000B ; p1_target, p2_target, p3_target, p4_target                 
    Team1Classes       DB 00000000B ; Higher nibble for P1 class, lower nibble for P2 class
    Team2Classes       DB 00000000B ; Higher nibble for P3 class, lower nibble for P4 class     
    MatchTurn 		   DB 0 ; Shows the Turn of the Game
    TeamSynergies      DB 00000000B ; Higher nibble for team 1, lower nibble for team 2.
    ; Synergy indices: 1) Nobles Oblige, 2) Great Wall, 3) Assassin's Creed, 4) Scorched Earth, 5) Count's Generosity, 6) Holy Empire
    
    ; Temporary Values
    DamageToBeDealt DW 0 ; used for the damage function, prevents value being discarded from GPRs
    EnemyIdentifier DB 0;

	; Class Stats     (HP, MaxHP,LDmg,HDmg,Def,  CC,UltC)
	KnightStats    	DB  85,  85,  20,  35,  30,  30,  1 ; Balanced, high defense
	AssassinStats  	DB  30,  60,  30,  40,  10,  50,  4 ; Lower health, high crit chance
	PyromancerStats	DB  50,  50,  20,  30,  20,  30,  4 ; Lower stats overall, but compensated by burn passive
	HealerStats    	DB  70 , 70,  15,  30,  15,  30,  4  ; LDmg deals actual damage to enemy, HDmg heals teammate
	VanguardStats  	DB  100, 100, 10,  35,  50,   0,  4  ; Max HP and Def, very low crit
	VampireStats   	DB  70,  70,  15,  25,  15,  99,  4  ; High health, low attack to account for 50% heal chance
		         
;==================================================================================
; STRINGS
;==================================================================================  
	; Player Names
    PlayerText  DB 'Player ', '$'
    TeamText    DB 'Team ', '$'           
    
    ; Class Names
    Knight      DB 'Knight', '$'     
    Assassin    DB 'Assassin', '$'
    Pyromancer  DB 'Pyromancer', '$'
    Healer      DB 'Healer', '$'
    Vanguard    DB 'Vanguard', '$'
    Vampire     DB 'Vampire', '$'      
    
    ; Game Option Texts    
    PrintPlayerStatsText        DB 'Choose Your Class!',0Dh,0Ah, '[1]-Knight',0Dh,0Ah, '[2]-Assassin',0Dh,0Ah, '[3]-Pyromancer',0Dh,0Ah, '[4]-Healer',0Dh,0Ah, '[5]-Vanguard',0Dh,0Ah, '[6]-Vampire ',0Dh,0Ah, '$'
    ChooseYourMoveText          DB 'Make Your Choice!',0Dh,0Ah, '$'
    MoveChoicesText             DB '[1]-Light Attack',0Dh,0Ah, '[2]-Heavy Attack',0Dh,0Ah, '[3]-Defend',0Dh,0Ah, '[4]-Heal',0Dh,0Ah, '[5]-Ultimate',0Dh,0Ah, '$'
    YouCheckIfText              DB 'You Selected Class ', '$' 
    StatsText                   DB 'Stats:', '$'   
    TurnText                    DB 'Turn ', '$'
    FightText                   DB ' - Fight!',0Dh,0Ah,'$' 
    ReplayText                  DB 0Dh,0Ah, 'Replay?',0Dh,0Ah,'$'
    
    ; Stat Printing Texts
    HealthText                  DB 0DH, 0AH, 'Health: ', '$' 
    MaxHealthText               DB 0DH, 0AH, 'MaxHealth: ', '$'
    LightAttackDamageText       DB 0DH, 0AH, 'Light Attack Damage: ', '$'
    HeavyAttackDamageText       DB 0DH, 0AH, 'Heavy Attack Damage: ', '$'
    DefenseText                 DB 0DH, 0AH, 'Defense: ', '$'
    CriticalChanceText          DB 0DH, 0AH, 'Critical Chance: ', '$' 
    StaminaText                 DB 0DH, 0AH, 'Stamina: ', '$' 
    UltimateCDText              DB 0DH, 0AH,  'Ultimate Cooldown: ', '$'

	; In-Combat Texts
	CriticalHitText             DB 'Critical Hit!',0DH, 0AH, '$'
    NormalHitText               DB 'Normal Hit!',0DH, 0AH,'$'    
    DamagedText                 DB 'Damaged ', '$'       
    ShowEnemyHPText             DB 'Enemy Currently Has ', '$'   
    LeftText                    DB 'HP Left!',0DH, 0AH, '$'
    ForText                     DB 'For ', '$'
    AllPlayersDiedText          DB 'All players are dead!', '$'
    SelectTeam1TargetText       DB 'Select Enemy:', 0DH, 0AH, '[1]-Player 3',0Dh,0Ah, '[2]-Player 4',0Dh,0Ah,'$'
    SelectTeam2TargetText       DB 'Select Enemy:', 0DH, 0AH, '[1]-Player 1',0Dh,0Ah, '[2]-Player 2',0Dh,0Ah,'$'  
    InvalidInputText            DB 'Pwease enter correct input UWU',0Dh,0Ah,'$' 
    NotEnoughStaminaText        DB 'Not Enough Stamina For Action!',0Dh,0Ah,'$'
    UltimateNotReadyText        DB 'Your ultimate ability is not yet ready!', '$' 
    SelfHealText                DB 'Health restored by 5', 0Dh, 0Ah, '$'   
    BurnDamageText              DB ' is burning and lost 10 health!', 0Dh, 0Ah, '$'
    BurnInflictionText          DB ' has been engulfed in flames!', 0Dh, 0Ah, '$'
    PoisonDamageText            DB ' is poisoned and lost 5 health!', 0Dh, 0Ah, '$'
    PoisonInflictionText        DB ' has been poisoned!', 0Dh, 0Ah, '$' 
    ParalysisWarning            DB ' has been inflicted with vampiric cum, and will be paralyzed for the next turn!', 0Dh, 0Ah, '$'   
    ParalysisText               DB ' is paralyzed and couldn`t move!', 0Dh, 0Ah, '$'  
    Team1Won                    DB 0Dh,0Ah,'Player 1 and 2 WIN!', '$'
    Team2Won                    DB 0Dh,0Ah,'Player 3 AND 4 WIN!', '$' 
    HolyEmpireHealText          DB 0Dh, 0Ah, 'Holy Empire: Health restored by 5!', 0Dh, 0Ah, '$'  
    HealerHeavyText				DB ' Has Been Healed For 15 HP!', 0Dh, 0Ah, '$'
    BurnUltimateText            DB ' has been engulfed in flames, and will burn for the next 4 turns!', 0Dh, 0Ah, '$'   
    VampHealHeavyText         	DB ' Sank Their Fangs Into Their Enemy Draining Their Life, Restoring ','$'
	HPText						DB 'HP!', 0Dh, 0Ah, '$'                                                   
	KnightUltimateText 			DB "The Knight's Valor Shone Bright, Shielding All From Fatigue, Granting ", '$'
	KnightUltimateRemText		DB ' Unyielding Endurance For 2 Turns.',0Dh,0Ah, '$'
    
    ; Synergy texts
    NoblesObligeText            DB 0Dh, 0Ah, 'Unleashed Synergy: Nobles Oblige! Both Knights shall deal an additonal 10 damage!',0Dh,0Ah,'$'
    GreatWallText               DB 0Dh, 0Ah, 'Unleashed Synergy: Great Wall! Your party`s Vanguard has received an additonal 30 HP, and your party`s Healer has received a defence buff',0Dh,0Ah,'$'
    AssassinsCreedText          DB 0Dh, 0Ah, 'Unleashed Synergy: Assassin`s Creed! Both Assassins can now perform their ultimate attack after only 3 turns, at the cost of 10 HP', 0Dh, 0Ah, '$'  
    ScorchedEarthText           DB 0Dh, 0Ah, 'Unleashed Synergy: Scorched Earth! Enemy players will be burnt for 1 additional turn!', 0Dh, 0Ah, '$'
    CountsGenerosityText        DB 0Dh, 0Ah, 'Unleashed Synergy: Count`s Generosity! Absorbed health will now be shared with your party`s Vanguard!',0Dh,0Ah,'$'
    HolyEmpireText              DB 0Dh, 0Ah, 'Unleashed Synergy: Holy Empire! Your party`s Knight will now receive an additonal 5 HP for every heal action!',0Dh,0Ah,'$'
    
data ENDS
      
      
code SEGMENT
;==================================================================================
; I/O FUNCTIONS
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

	; Load system time into CX and DX (CH: Hour, CL: Minute, DH: Second, DL: 1/100th of a second)
	GetTime:
        MOV AH, 2CH
        INT 21H  
        RET
   
   	; Generic random function, expects chance in AL. Result in CF
	GetChance:
	    CALL GetTime   ; Load Counter and Data registers with time data
        MOV BL, TotalStats    ; Load length of array for based offset later   
        MOV BH, 0   ;Ensure BX is same as BL in terms of actual value
        CMP AL, DL      ; DL has hundredth of a second
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
 		MOV DX, OFFSET UltimateCDText     
 		CALL PrintLine	  		 	
 		MOV AL, [SI+6]       
 		CALL PrintInt 
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
	
	; Prints match turn and update its value		
	PrintMatchTurn:   
		CALL PrintNewLine           
		INC MatchTurn
		MOV DX, OFFSET TurnText
		CALL PrintLine
		MOV AH, 0
		MOV AL, MatchTurn
		CALL PrintInt
		MOV DX, OFFSET FightText
		CALL PrintLine 
		CALL PrintNewLine
		RET	 
			          	    
;==================================================================================
; COMBAT FUNCTIONS
;==================================================================================  	 
    ; Restore Stamina of each player after every turn by STGainPerTurn. Increases stamina of a dead player too, as it doesn't matter since they can't act and upon revival, stamina is restored to 100 regardless
    RecoverStamina:
        MOV AL, STGainPerTurn
        MOV AH, KnightExtraSTGain
        MOV SI, OFFSET PlayersStamina
        Player1RecoverST:
            MOV AH, [SI]                 
            ADD AH, AL
            TEST Team1Classes, 11110000B
            JNZ P1RecoveryFinal
            ADD [SI], AH
            P1RecoveryFinal:
                CALL ClampStatInSI
        Player2RecoverST:
            INC SI
            MOV AH, [SI]                 
            ADD AH, AL
            TEST Team1Classes, 00001111B
            JNZ P2RecoveryFinal
            ADD [SI], AH
            P2RecoveryFinal:
                CALL ClampStatInSI
        Player3RecoverST:
            INC SI
            MOV AH, [SI]                 
            ADD AH, AL
            TEST Team2Classes, 11110000B
            JNZ P3RecoveryFinal
            ADD [SI], AH
            P3RecoveryFinal:
                CALL ClampStatInSI
        Player4RecoverST:
            INC SI
            MOV AH, [SI]                 
            ADD AH, AL
            TEST Team2Classes, 00001111B
            JNZ P4RecoveryFinal
            ADD [SI], AH
            P4RecoveryFinal:
                CALL ClampStatInSI
        RET
                              
    ; Update ultimate cooldown of all players after each turn
    UpdateUltimateCooldown:
        ; P1 UltC
        MOV SI, OFFSET Player1Stats
        ADD SI, 6
        DEC [SI]
        CALL ClampStatInSI         ; R.I.P ClampThatMf, you were a terribly made function but still my baby boy
        ; P2 ultC
        MOV SI, OFFSET Player2Stats
        ADD SI, 6
        DEC [SI]
        CALL ClampStatInSI
        ; P3 UltC
        MOV SI, OFFSET Player3Stats
        ADD SI, 6
        DEC [SI]
        CALL ClampStatInSI
        ; P4 UltC
        MOV SI, OFFSET Player4Stats
        ADD SI, 6
        DEC [SI]
        CALL ClampStatInSI
        RET   
        
    ; Target an enemy player       
    ; Uses registers DX, AL 
    TargetEnemy:
        CMP CurrentTurn, 2
        JNC Team2Selection:
            TEST AliveAndHealStatus, 10000000B
            JZ P3Select                 ; P4 dead, skip to P3
            TEST AliveAndHealStatus, 01000000B
            JZ Team1Selection_Final
            MOV DX, OFFSET SelectTeam1TargetText
            CALL PrintLine
            CALL TakeCharInput
            CMP AL, '1'
            JE P3Selected    
            ; P4 Selected
            CMP CurrentTurn, 0
            JNE SetP2TargetP4 
            OR CurrentlyTargeting, 11000000B        ; P1 selected P4    
            JMP Team1Selection_Final
            SetP2TargetP4:
                OR CurrentlyTargeting, 00110000B    ; P2 selected P4
            RET
            ; P3 Select deals with any choice by P1 or P2 where P3 was chosen as target
            P3Select:
                TEST AliveAndHealStatus, 01000000B
                JZ Team1Selection_Final
                P3Selected:
                    CMP CurrentTurn, 0
                    JNE SetP2TargetP3 
                    OR CurrentlyTargeting, 10000000B        ; P1 selected P3 
                    JMP Team1Selection_Final
                    SetP2TargetP3:
                        OR CurrentlyTargeting, 00100000B    ; P2 selected P3
                    Team1Selection_Final:
                        RET  
        Team2Selection:
            TEST AliveAndHealStatus, 00010000B
            JZ P2Select                 ; P1 dead, skip to P2
            TEST AliveAndHealStatus, 00100000B
            JZ Team2Selection_Final
            MOV DX, OFFSET SelectTeam2TargetText
            CALL PrintLine
            CALL TakeCharInput
            CMP AL, '1'
            JE P1Selected    
            ; P1 Selected
            CMP CurrentTurn, 2
            JE SetP3TargetP1
            OR CurrentlyTargeting, 00000001B        ; P4 selected P2 
            JMP Team2Selection_Final
            SetP3TargetP1:
                OR CurrentlyTargeting, 00000100B    ; P3 selected P2
            RET
            ; P3 Select deals with any choice by P1 or P2 where P3 was chosen as target
            P2Select:
                TEST AliveAndHealStatus, 01000000B
                JZ Team2Selection_Final
                P1Selected:
                    CMP CurrentTurn, 2
                    JE SetP3TargetP2
                    OR CurrentlyTargeting, 00000000B        ; P4 selected P1  
                    JMP Team2Selection_Final
                    SetP3TargetP2:
                        OR CurrentlyTargeting, 00000000B    ; P3 selected P1
                    Team2Selection_Final:
                        RET 
                        
    ; Attacks the selected enemy
    ; Priority: Ultimate attack, attack
    EvaluateAttack:       	
    	; Is P1                	
    	CMP CurrentTurn, 0   		 
    	JNE EvalAttack_P2   	          
	    	; Check P1 Status       
	        TEST AliveAndHealStatus, 00010000B ; P1 Alive
	        JZ EvaluateAttack_P2Alive 
	        TEST AliveAndHealStatus, 00000001B ; P1 Healing
	        JNZ EvalAttack_CheckNextAttacker 
	        TEST CurrentTurnStats, 00000001B ; P1 Defending
	        JNZ EvalAttack_CheckNextAttacker
	        JMP P1LightAttack  
	    ; Is P2
        EvalAttack_P2: 
	        CMP CurrentTurn, 1
	        JNE EvalAttack_P3
	        ; Check P2 Status
	        EvaluateAttack_P2Alive:
	            TEST AliveAndHealStatus, 00100000B ; P2 Alive
		        JZ EvaluateAttack_P3Alive 
		        TEST AliveAndHealStatus, 00000010B ; P2 Healing
    	        JNZ EvalAttack_CheckNextAttacker
		        TEST CurrentTurnStats, 00000010B ; P2 Defending
		        JNZ EvalAttack_CheckNextAttacker    	        
				JMP P2LightAttack 
		; Is P3          
		EvalAttack_P3:   
	        CMP CurrentTurn, 2
    		JNE EvalAttack_P4   
	 		; Check P3 Status
	        EvaluateAttack_P3Alive:
	            TEST AliveAndHealStatus, 01000000B ; P3 Alive
		        JZ EvalAttack_P4 
		        TEST AliveAndHealStatus, 00000100B ; P3 Healing
    	        JNZ EvalAttack_CheckNextAttacker
		        TEST CurrentTurnStats, 00000100B ; P3 Defending
		        JNZ EvalAttack_CheckNextAttacker    	        
				JMP P3LightAttack 
		; Is P4    
		EvalAttack_P4: 		
            TEST AliveAndHealStatus, 10000000B ; P4 Alive
			JNZ EvalAttack_CheckNextAttacker 
	        TEST AliveAndHealStatus, 00001000B ; P4 Healing
	        JNZ EvalAttack_CheckNextAttacker
	        TEST CurrentTurnStats, 00001000B ; P4 Defending
	        JNZ EvalAttack_CheckNextAttacker    	        			
			JMP P4LightAttack	    
	    ; P1 Attacks	      
        P1LightAttack:
        	TEST Player1Status, 00000100B ; Check if Light Attack 
        	JZ P1HeavyAttack        	
        	CALL LoadPlayerStatsInDI       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	MOV CL, Team1Classes            ; Load Team1Classes to check for Pyro
        	AND CL, 11110000B               ; Remove P2's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn             ; Temp Store CurrentTurn        
        	AND BL, 11000000B               ; Remove redundant bits
        	CMP BL, 11000000B               ; Check if Atking P4         	   	         
        	JE P1StoreLightAtkDmgForP4
    	    CMP CL, 00100000B               ; Check is P1 is pyromancer
    	    JNE P1StoreLightAtkDmgForP3_Final    ; Not pyro, jump away!
    	    ; P1 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20
    	    JG P1StoreLightAtkDmgForP3_Final        ; Burn attempt failed 
    	    ; Apply burn to P3
    	    OR Player3Status, 10000000B
    	    ADD P3BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine
    	    P1StoreLightAtkDmgForP3_Final:
        	    MOV CurrentTurn, 2              ; Attacking P3  
        	    MOV EnemyIdentifier, 2          ; Store enemy ID  
                JMP FinishAttack
        	P1StoreLightAtkDmgForP4:
        	    CMP CL, 00100000B
        	    JNE P1StoreLightAtkDmgForP4_Final
        	    ; P1 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20
        	    JG P1StoreLightAtkDmgForP4_Final        ; Burn attempt failed 
        	    ; Apply burn to P4
        	    OR Player4Status, 10000000B
        	    ADD P4BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P1StoreLightAtkDmgForP4_Final:        	
            	    MOV CurrentTurn, 3 ; Attacking P4  
            	    MOV EnemyIdentifier, 3 ; Store enemy ID    	    
            	    JMP FinishAttack	       
        P1HeavyAttack:  
        	TEST Player1Status, 00000010B ; Check if Heavy Attack 
			JZ P1Ultimate        	
        	CALL LoadPlayerStatsInDI         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	MOV CL, Team1Classes            ; Load Team1Classes to check for Pyro
        	AND CL, 11110000B               ; Remove P2's class info        	
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 11000000B  ; Remove redundant bits
        	CMP BL, 11000000B  ; Check if Atking P4         	   	         
        	JE P1StoreHeavyAtkDmgForP4
        	CMP CL, 00100000B                   ; Check if P1 is a pyromancer
    	    JNE P1StoreHeavyAtkDmgForP3_Final
    	    ; P2 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20                  
    	    JG P1StoreHeavyAtkDmgForP3_Final        ; Burn attempt failed 
    	    ; Apply burn to P3
    	    OR Player3Status, 10000000B
    	    ADD P3BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine
    	    P1StoreHeavyAtkDmgForP3_Final:
	    	     MOV CurrentTurn, 2 ; Attacking P3    	      
	    	     MOV EnemyIdentifier, 2 ; Store enemy ID 
	    	     JMP FinishAttack     	     
    	    P1StoreHeavyAtkDmgForP4:
    	        CMP CL, 00100000B                      ; Check if P1 is a pyromancer
        	    JNE P1StoreHeavyAtkDmgForP4_Final
        	    ; P1 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20
        	    JG P1StoreHeavyAtkDmgForP4_Final        ; Burn attempt failed 
        	    ; Apply burn to P4
        	    OR Player4Status, 10000000B
        	    ADD P4BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P1StoreHeavyAtkDmgForP4_Final: 
    			    MOV CurrentTurn, 3 ; Attacking P3    	      
    				MOV EnemyIdentifier, 3; Store enemy ID  			
        	     	JMP FinishAttack      	         	               
        P1Ultimate:
            MOV AL, Team1Classes            ; Temp store Team1Classes          
            AND AL, 11110000B               ; Remove P2's class info
            CMP Team1Classes, 01010000B     ; Check if vampire
            JNE P1PyroCheck       
            ; If Vampire, paralyze the target
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 11000000B  ; Remove redundant bits
        	CMP BL, 11000000B  ; Check if Atking P4         	   	         
        	JE P1ParalysesP4   	      
    	    OR Player3Status, 00100000B     ; Paralyze P3 
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET ParalysisWarning
    	    CALL PrintLine
    	    CALL PrintNewLine
    	    RET   	     
    	    P1ParalysesP4:    	      
        	    OR Player4Status, 00100000B     ; Paralyze P4 
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisWarning
        	    CALL PrintLine
        	    CALL PrintNewLine
        	    RET    
        ; Pyromancer Ultimate  
        P1PyroCheck: 
            ; Check if P2 is Pyromancer
            CMP AL, 00100000B
            JNE P1AssassinCheck
            ; Set burn bit, and update burn counters for both enemies
            OR Player3Status, 10000000B
            MOV P3BurnCounter, 4
            OR Player4Status, 10000000B
            MOV P4BurnCounter, 4
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '2'
            CALL PrintChar
            MOV DX, OFFSET BurnUltimateText
            CALL PrintLine
            JMP FinishAttack
        P1AssassinCheck:
            CMP AL, 00010000B       ; Check if P1 is assassin
            JNE P1KnightCheck     	      
        	MOV AL, 200 ; instakill     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; If only one enemy alive, pick them
        	TEST AliveAndHealStatus, 01000000B
        	JZ P1AssassinatesP4                 ; P3 dead, target P4
        	TEST AliveAndHealStatus, 10000000B  
        	JZ P1AssassinatesP3                 ; P4 dead, target P3
        	; Both alive, randomly select any one
        	CALL GetChance
        	CMP DL, 50
        	JLE P1AssassinatesP3
    	    P1AssassinatesP4:
        	    MOV CurrentTurn, 3 ; Attacking P4
        	    MOV EnemyIdentifier, 3 ; Store enemy ID
        	    JMP FinishAttack   
        	P1AssassinatesP3:        	
        	     MOV CurrentTurn, 2 ; Attacking P3 
        	     MOV EnemyIdentifier, 2 ; Store enemy ID      	    
        	     JMP FinishAttack      
		; Knight Ultimate  
        P1KnightCheck:             
            CMP AL, 00000000B  ; Check if Knight
            JNE FinishAttack
            ; Set Vitality bit, and update vitality counters for team
            OR Player1Status, 00010000B
            MOV Team1Vitality, 2
            OR Player2Status, 00010000B            
            MOV DX, OFFSET KnightUltimateText
            CALL PrintLine  
            ; Print team  
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar 
             MOV DX, OFFSET KnightUltimateRemText  
             CALL PrintLine
            JMP FinishAttack        	           
        ; P2 Attacks	      
        P2LightAttack:
        	TEST Player2Status, 00000100B ; Check if Light Attack 
        	JZ P2HeavyAttack        	
        	CALL LoadPlayerStatsInDI       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
            MOV CL, Team1Classes            ; Load Team1Classes to check for Pyro
        	AND CL, 00001111B               ; Remove P1's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 00110000B  ; Remove redundant bits
        	CMP BL, 11000000B               ; Check if Atking P4        ;TODO: FIX! ANDing BL's higher 2 bits with 00 will always make 'CMP BL, 11000000B' True
        	JE P2StoreLightAtkDmgForP4
        	CMP CL, 00000010B               ; Check if P2 is a pyromancer
    	    JNE P2StoreLightAtkDmgForP3_Final
    	    ; P2 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20                  
    	    JG P2StoreLightAtkDmgForP3_Final        ; Burn attempt failed 
    	    ; Apply burn to P3
    	    OR Player3Status, 10000000B
    	    ADD P3BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine         	   	         
        	P2StoreLightAtkDmgForP3_Final:
        	     MOV CurrentTurn, 2 ; Attacking P3  
        	     MOV EnemyIdentifier, 2 ; Store enemy ID 
        	     JMP FinishAttack
        	P2StoreLightAtkDmgForP4:     
                CMP CL, 00100000B                      ; Check if P2 is a pyromancer
        	    JNE P2StoreLightAtkDmgForP4_Final
        	    ; P2 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20
        	    JG P2StoreLightAtkDmgForP4_Final        ; Burn attempt failed 
        	    ; Apply burn to P4
        	    OR Player4Status, 10000000B
        	    ADD P4BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine 
            	P2StoreLightAtkDmgForP4_Final:        	
            	     MOV CurrentTurn, 3 ; Attacking P4  
            	     MOV EnemyIdentifier, 3 ; Store enemy ID     	    
            	     JMP FinishAttack	       
        P2HeavyAttack:  
        	TEST Player2Status, 00000010B ; Check if Heavy Attack 
			JZ P2Ultimate        	
        	CALL LoadPlayerStatsInDI         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	MOV CL, Team1Classes            ; Load Team1Classes to check for Pyro
        	AND CL, 00001111B               ; Remove P1's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00110000B  ; Remove redundant bits
        	CMP BL, 00110000B  ; Check if Atking P4                      
        	JE P2StoreHeavyAtkDmgForP4
        	CMP CL, 00000010B               ; Check if P2 is a pyromancer
    	    JNE P2StoreHeavyAtkDmgForP3_Final
    	    ; P2 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20                  
    	    JG P2StoreHeavyAtkDmgForP3_Final        ; Burn attempt failed 
    	    ; Apply burn to P3
    	    OR Player3Status, 10000000B
    	    ADD P3BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine
    	    P2StoreHeavyAtkDmgForP3_Final:            	   	         
	    	     MOV CurrentTurn, 2 ; Attacking P3    	      
	    	     MOV EnemyIdentifier, 2 ; Store enemy ID 
	    	     JMP FinishAttack     	     
    	     P2StoreHeavyAtkDmgForP4:
    	        CMP CL, 00000010B                      ; Check if P2 is a pyromancer
        	    JNE P2StoreHeavyAtkDmgForP4_Final
        	    ; P2 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20
        	    JG P2StoreHeavyAtkDmgForP4_Final        ; Burn attempt failed 
        	    ; Apply burn to P4
        	    OR Player4Status, 10000000B
        	    ADD P4BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P2StoreHeavyAtkDmgForP4_Final:  
    			    MOV CurrentTurn, 3 ; Attacking P3    	      
    				MOV EnemyIdentifier, 3; Store enemy ID  
        	    	JMP FinishAttack      	         	               
        P2Ultimate:
            MOV AL, Team1Classes        ; Temp store Team1Classes          
            AND AL, 00001111B           ; Remove P1's class info
            ; If Vampire, paralyze the target
            CMP AL, 00000101B
            JNE P2PyroCheck
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 11000000B  ; Remove redundant bits
        	CMP BL, 11000000B  ; Check if Atking P4         	   	         
        	JE P2ParalysesP4	      
    	    OR Player3Status, 00100000B     ; Paralyze P3 
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '3'
    	    CALL PrintChar
    	    MOV DX, OFFSET ParalysisWarning
    	    CALL PrintLine
    	    CALL PrintNewLine
    	    RET   	     
    	    P2ParalysesP4: 	      
        	    OR Player4Status, 00100000B     ; Paralyze P4 
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisWarning
        	    CALL PrintLine
        	    CALL PrintNewLine 
        	    RET
        ; Pyromancer Ultimate
        P2PyroCheck:
         ; Check if P2 is Pyromancer
            CMP AL, 00000010B
            JNE P2AssassinCheck
            ; Set burn bit, and update burn counters for both enemies
            OR Player3Status, 10000000B
            MOV P3BurnCounter, 4
            OR Player4Status, 10000000B
            MOV P4BurnCounter, 4
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '2'
            CALL PrintChar
            MOV DX, OFFSET BurnUltimateText
            CALL PrintLine
            RET
        P2AssassinCheck:
            CMP AL, 00000001B       ; Check if P2 is assassin
            JNE P2KnightCheck     	      
        	MOV AL, 200 ; instakill     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; If only one enemy alive, pick them
        	TEST AliveAndHealStatus, 01000000B
        	JZ P2AssassinatesP4                 ; P3 dead, target P4
        	TEST AliveAndHealStatus, 10000000B  
        	JZ P2AssassinatesP3                 ; P4 dead, target P3
        	; Both alive, randomly select any one
        	CALL GetChance
        	CMP DL, 50
        	JLE P2AssassinatesP3
    	    P2AssassinatesP4:
        	    MOV CurrentTurn, 3 ; Attacking P4
        	    MOV EnemyIdentifier, 3 ; Store enemy ID
        	    JMP FinishAttack   
        	P2AssassinatesP3:        	
        	     MOV CurrentTurn, 2 ; Attacking P3 
        	     MOV EnemyIdentifier, 2 ; Store enemy ID      	    
        	     JMP FinishAttack	  
		; Knight Ultimate  
        P2KnightCheck:             
            CMP AL, 00000000B  ; Check if Knight
            JNE FinishAttack
            ; Set Vitality bit, and update vitality counters for team
            OR Player1Status, 00010000B
            MOV Team1Vitality, 2
            OR Player2Status, 00010000B            
            MOV DX, OFFSET KnightUltimateText
            CALL PrintLine  
            ; Print team  
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar 
             MOV DX, OFFSET KnightUltimateRemText  
             CALL PrintLine
            JMP FinishAttack        	     
        ; P3 Attacks	      
        P3LightAttack:
        	TEST Player3Status, 00000100B ; Check if Light Attack 
        	JZ P3HeavyAttack        	
        	CALL LoadPlayerStatsInDI       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX                         
        	MOV CL, Team2Classes    ; Temp store Team2Classes
        	AND CL, 11110000B        ; Remove P4's class info        	
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1
        	JNE P3StoreLightAtkDmgForP2
        	CMP CL, 00100000B               ; Check if P3 is a pyromancer
    	    JNE P3StoreLightAtkDmgForP1_Final
    	    ; P3 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20                  
    	    JG P3StoreLightAtkDmgForP1_Final        ; Burn attempt failed 
    	    ; Apply burn to P1
    	    OR Player1Status, 10000000B
    	    ADD P1BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine            	   	         
        	P3StoreLightAtkDmgForP1_Final:
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID 
        	     JMP FinishAttack  
        	P3StoreLightAtkDmgForP2:
            	CMP CL, 00100000B               ; Check if P3 is a pyromancer
        	    JNE P3StoreLightAtkDmgForP2_Final
        	    ; P3 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20                  
        	    JG P3StoreLightAtkDmgForP2_Final        ; Burn attempt failed 
        	    ; Apply burn to P2
        	    OR Player2Status, 10000000B
        	    ADD P2BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P3StoreLightAtkDmgForP2_Final:          	
            	     MOV CurrentTurn, 1 ; Attacking P2 
            	     MOV EnemyIdentifier, 1 ; Store enemy ID         	    	   
            	     JMP FinishAttack	       
        P3HeavyAttack:  
        	TEST Player3Status, 00000010B ; Check if Heavy Attack 
			JZ P3Ultimate        	
        	CALL LoadPlayerStatsInDI         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX 
        	MOV CL, Team2Classes        ; Temp store Team2Classes
        	AND CL, 11110000B           ; Remove P4's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits    
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JNE P3StoreHeavyAtkDmgForP2
        	CMP CL, 00100000B
        	JNE P3StoreHeavyAtkDmgForP1_Final
        	; P3 is pyromancer
    	    CALL GetChance
    	    CMP DL, 20                  
    	    JG P3StoreHeavyAtkDmgForP1_Final        ; Burn attempt failed 
    	    ; Apply burn to P1
    	    OR Player1Status, 10000000B
    	    ADD P1BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine
    	    P3StoreHeavyAtkDmgForP1_Final:
        	     MOV CurrentTurn, 1 ; Attacking P1 
        	     MOV EnemyIdentifier, 1 ; Store enemy ID  
        	     JMP FinishAttack 
        	P3StoreHeavyAtkDmgForP2:
        	    CMP CL, 00100000B               ; Check if P3 is a pyromancer
        	    JNE P3StoreHeavyAtkDmgForP2_Final
        	    ; P3 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20                  
        	    JG P3StoreHeavyAtkDmgForP2_Final        ; Burn attempt failed 
        	    ; Apply burn to P2
        	    OR Player2Status, 10000000B
        	    ADD P2BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P3StoreHeavyAtkDmgForP2_Final:        	
            	    MOV CurrentTurn, 0 ; Attacking P2 
            	    MOV EnemyIdentifier, 0 ; Store enemy ID      	     
            	    JMP FinishAttack     	         	               
        P3Ultimate:
            MOV AL, Team2Classes        ; Temp store Team2Classes
            AND AL, 11110000B           ; Remove P4's class info
            CMP AL, 01010000B           ; If Vampire, paralyze the target
            JNE P3PyroCheck
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P3ParalysesP2  	      
    	    OR Player1Status, 00100000B     ; Paralyze P1
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET ParalysisWarning
    	    CALL PrintLine
    	    CALL PrintNewLine 
    	    RET  	     
    	    P3ParalysesP2: 	      
        	    OR Player2Status, 00100000B     ; Paralyze P2 
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisWarning
        	    CALL PrintLine
        	    CALL PrintNewLine
        	    RET
        ; Pyromancer Ultimate
        P3PyroCheck:         
            CMP AL, 00100000B     ; Check if P3 is Pyromancer
            JNE P3AssassinCheck
            ; Set burn bit, and update burn counters for both enemies
            OR Player1Status, 10000000B
            MOV P1BurnCounter, 4
            OR Player2Status, 10000000B
            MOV P2BurnCounter, 4
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar
            MOV DX, OFFSET BurnUltimateText
            CALL PrintLine
            RET
        P3AssassinCheck:
            CMP AL, 00010000B       ; Check if P3 is assassin    
            JNE P3KnightCheck  	      
        	MOV AL, 200 ; instakill     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; If only one enemy alive, pick them
        	TEST AliveAndHealStatus, 00010000B
        	JZ P3AssassinatesP2                 ; P1 dead, target P2
        	TEST AliveAndHealStatus, 00100000B  
        	JZ P3AssassinatesP1                 ; P2 dead, target P1
        	; Both alive, randomly select any one
        	CALL GetChance
        	CMP DL, 50
        	JLE P3AssassinatesP1
    	    P3AssassinatesP2:
        	    MOV CurrentTurn, 1 ; Attacking P2
        	    MOV EnemyIdentifier, 1 ; Store enemy ID
        	    JMP FinishAttack   
        	P3AssassinatesP1:        	
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID      	    
        	     JMP FinishAttack	         
        ; Knight Ultimate  
        P3KnightCheck:             
            CMP AL, 00000000B  ; Check if Knight
            JNE FinishAttack
            ; Set Vitality bit, and update vitality counters for team
            OR Player3Status, 00010000B
            MOV Team2Vitality, 2
            OR Player4Status, 00010000B            
            MOV DX, OFFSET KnightUltimateText
            CALL PrintLine  
            ; Print team  
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar 
             MOV DX, OFFSET KnightUltimateRemText  
             CALL PrintLine
            JMP FinishAttack 	     
        ; P4 Attacks	      
        P4LightAttack:
        	TEST Player4Status, 00000100B ; Check if Light Attack 
        	JZ P4HeavyAttack        	
        	CALL LoadPlayerStatsInDI       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	MOV CL, Team2Classes        ; Temp store Team2Classes
        	AND CL, 00001111B           ; Remove P3's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn         ; Temp Store CurrentTurn        
        	AND BL, 00000000B           ; Remove redundant bits
        	CMP BL, 00000000B           ; Check if Atking P1         	   	         
        	JNE P4StoreLightAtkDmgForP2
        	CMP CL, 00000010B           ; Check if P4 is a pyromancer
        	JNE P4StoreLightAtkDmgForP1_Final
        	CALL GetChance
    	    CMP DL, 20                  
    	    JG P3StoreLightAtkDmgForP1_Final        ; Burn attempt failed 
    	    ; Apply burn to P1
    	    OR Player1Status, 10000000B
    	    ADD P1BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine  
        	P4StoreLightAtkDmgForP1_Final:   
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID
        	     JMP FinishAttack   
        	P4StoreLightAtkDmgForP2:
            	CMP CL, 00000010B                   ; Check if P4 is a pyromancer
        	    JNE P3StoreLightAtkDmgForP2_Final
        	    ; P4 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20                  
        	    JG P4StoreLightAtkDmgForP2_Final        ; Burn attempt failed 
        	    ; Apply burn to P2
        	    OR Player2Status, 10000000B
        	    ADD P2BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P4StoreLightAtkDmgForP2_Final:    	
            	    MOV CurrentTurn, 1 ; Attacking P2 
            	    MOV EnemyIdentifier, 1 ; Store enemy ID      	    
            	    JMP FinishAttack	       
        P4HeavyAttack:  
        	TEST Player4Status, 00000010B ; Check if Heavy Attack 
			JZ P4Ultimate        	
        	CALL LoadPlayerStatsInDI         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	MOV CL, Team2Classes        ; Temp store Team2Classes
        	AND CL, 00001111B           ; Remove P3's class info
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JNE P4StoreHeavyAtkDmgForP2
        	CMP CL, 00000010B           ; Check if P4 is a pyromancer
        	JNE P4StoreHeavyAtkDmgForP1_Final
        	CALL GetChance
    	    CMP DL, 20                  
    	    JG P3StoreHeavyAtkDmgForP1_Final        ; Burn attempt failed 
    	    ; Apply burn to P1
    	    OR Player1Status, 10000000B
    	    ADD P1BurnCounter, 2
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET BurnInflictionText
    	    CALL PrintLine
    	    P4StoreHeavyAtkDmgForP1_Final:
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID  
        	     JMP FinishAttack 
        	P4StoreHeavyAtkDmgForP2:
        	    CMP CL, 00000010B                   ; Check if P4 is a pyromancer
        	    JNE P3StoreHeavyAtkDmgForP2_Final
        	    ; P4 is pyromancer
        	    CALL GetChance
        	    CMP DL, 20                  
        	    JG P4StoreHeavyAtkDmgForP2_Final        ; Burn attempt failed 
        	    ; Apply burn to P2
        	    OR Player2Status, 10000000B
        	    ADD P2BurnCounter, 2
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET BurnInflictionText
        	    CALL PrintLine
        	    P4StoreHeavyAtkDmgForP2_Final:        	
            	     MOV CurrentTurn, 1 ; Attacking P2 
            	     MOV EnemyIdentifier, 1 ; Store enemy ID     	     
            	     JMP FinishAttack 
        P4Ultimate:
            MOV AL, Team2Classes        ; Temp store Team2Classes
            AND AL, 00001111B           ; Remove P3's class info
            ; If Vampire, paralyze the target
            CMP AL, 00000101B
            JNE P4PyroCheck
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P4ParalysesP2  	      
    	    OR Player1Status, 00100000B     ; Paralyze P1
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET ParalysisWarning
    	    CALL PrintLine
    	    CALL PrintNewLine
    	    RET   	     
    	    P4ParalysesP2: 	      
        	    OR Player2Status, 00100000B     ; Paralyze P2 
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisWarning
        	    CALL PrintLine
        	    CALL PrintNewLine
        	    RET	 
        ; Pyromancer Ultimate
        P4PyroCheck:         
            CMP AL, 00000010B     ; Check if P4 is Pyromancer
            JNE P4AssassinCheck
            ; Set burn bit, and update burn counters for both enemies
            OR Player1Status, 10000000B
            MOV P1BurnCounter, 4
            OR Player2Status, 10000000B
            MOV P2BurnCounter, 4
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar
            MOV DX, OFFSET BurnUltimateText
            CALL PrintLine
            RET
        P4AssassinCheck:
            CMP AL, 00000001B       ; Check if P4 is Assassin  
            JNE P4KnightCheck    	      
        	MOV AL, 200 ; instakill     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; If only one enemy alive, pick them
        	TEST AliveAndHealStatus, 00010000B
        	JZ P4AssassinatesP2                 ; P1 dead, target P2
        	TEST AliveAndHealStatus, 00100000B  
        	JZ P4AssassinatesP1                 ; P2 dead, target P1
        	; Both alive, randomly select any one
        	CALL GetChance
        	CMP DL, 50
        	JLE P4AssassinatesP1
    	    P4AssassinatesP2:
        	    MOV CurrentTurn, 1 ; Attacking P2
        	    MOV EnemyIdentifier, 1 ; Store enemy ID
        	    JMP FinishAttack   
        	P4AssassinatesP1:        	
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID      	    
        	     JMP FinishAttack	
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1 
		; Knight Ultimate  
        P4KnightCheck:             
            CMP AL, 00000000B  ; Check if Knight
            JNE FinishAttack
            ; Set Vitality bit, and update vitality counters for team
            OR Player3Status, 00010000B
            MOV Team2Vitality, 2
            OR Player4Status, 00010000B            
            MOV DX, OFFSET KnightUltimateText
            CALL PrintLine  
            ; Print team  
            MOV DX, OFFSET TeamText
            CALL PrintLine
            MOV DX, '1'
            CALL PrintChar 
             MOV DX, OFFSET KnightUltimateRemText  
             CALL PrintLine
            JMP FinishAttack         	                        
        ; Finish Attack, used for Finishing Attack Logic
        FinishAttack: 
			CALL LoadPlayerStatsInDI
			MOV CurrentTurn, DL  ; Revert Current Turn To OG Val 
			CALL DoDamage
		EvalAttack_CheckNextAttacker:	
			INC CurrentTurn    
			CMP CurrentTurn, 4 ; Check if all attacks have been done   			
			JGE EndAttackCycle          
			JMP EvaluateAttack
			RET   
		; Reset Attack Variables
		EndAttackCycle:
	        MOV CurrentlyTargeting, 0B         ; reset targetting
    		AND AliveAndHealStatus, 11110000B  ; reset healing
    		MOV CurrentTurn, 0	
        RET
    
    ; Func to deal damage, needs Damage to be moved to DamageToBeDealt    
    ; Enemy Stats should be Loaded on DI      
    ; Enemy Number should be Loaded on BH
    DoDamage:     	                	
    	MOV SI, DI  ; Mov Enemy Stats into SI cuz UpdateCrit updates DI    	      
    	CALL UpdateCrit               	    	   
    	; Crits Calc    	
    	; CurrentTurn AND CurrentTurnStats For P1  
    	CMP CurrentTurn, 0
	    JNE DoDamage_CheckP2Crit
	    TEST CurrentTurnStats, 00010000B      ; check crit
	    JZ DoDamage_CheckP2Crit	    
	    JMP DoDamage_PlayerHasCrit  
	    ; CurrentTurn AND CurrentTurnStats For P2
    	DoDamage_CheckP2Crit:
		    CMP CurrentTurn, 1        
    		JNE DoDamage_CheckP3Crit
		    TEST CurrentTurnStats, 00100000B   ; check crit
		    JZ DoDamage_CheckP3Crit	    
		    JMP DoDamage_PlayerHasCrit             
		; CurrentTurn AND CurrentTurnStats For P3
		DoDamage_CheckP3Crit:
		    CMP CurrentTurn, 2
    		JNE DoDamage_CheckP4Crit
		    TEST CurrentTurnStats, 01000000B  ; check crit
		    JZ DoDamage_CheckP4Crit	    
		    JMP DoDamage_PlayerHasCrit	
		; P4 Crit Check
		DoDamage_CheckP4Crit:
			TEST CurrentTurnStats, 10000000B  ; check crit
		    JNZ DoDamage_PlayerHasCrit
		    JMP	DoDamage_PlayerDidNotCrit	
    	DoDamage_PlayerHasCrit:
    		; Double Damage
    		MOV AX, DamageToBeDealt
    		MOV BL, 2 ; For Doubling Damage
    		MUL BL
    		MOV DamageToBeDealt, AX 
    	DoDamage_PlayerDidNotCrit:
    	; Defending Logic
    	MOV AL, [SI+4]	
    	MOV BL, 2  ; For Doubling Defense for block
    	; Check if Enemy P3
    	CMP BH, 2      	
    	JNE DoDamage_CheckIfEnemyP4
    	TEST CurrentTurnStats, 00000100B   ; Check If P3 Blocking
	    	JZ DoDamage_EnemyIsNotBlocking
    		MUL BL ; Double Defense cuz Blocking 
    	; Check if Enemy P4
    	DoDamage_CheckIfEnemyP4:
    		CMP BH, 3  
    		JNE DoDamage_CheckIfEnemyP1  
    		TEST CurrentTurnStats, 00001000B   ; Check If P4 Blocking    
    		JZ DoDamage_EnemyIsNotBlocking
    		MUL BL     
    	; Check if Enemy P1
    	DoDamage_CheckIfEnemyP1:
    		CMP BH, 0  
			JNE DoDamage_CheckIfEnemyP2  
    		TEST CurrentTurnStats, 00000001B   ; Check If P1 Blocking    
    		JZ DoDamage_EnemyIsNotBlocking
    		MUL BL
    	; Check if Enemy P1  
    	DoDamage_CheckIfEnemyP2:
    		TEST CurrentTurnStats, 00000010B   ; Check If P2 Blocking  
    		JZ DoDamage_EnemyIsNotBlocking
			MUL BL   
    	DoDamage_EnemyIsNotBlocking: 
			MOV DH, AL ; Store Final Def in DH
	    	MOV AX, DamageToBeDealt        
	    	SUB AL, DH  ; Damage Shred cuz of Def    	
	    	JC DoDamage_SetLowestDmgValue  ; negative dmg not allowed  
	    	CMP AL, 5
	    	JC DoDamage_SetLowestDmgValue  ; dmg < 5 not allowed
	    	JMP DoDamage_DoDamage
    	DoDamage_SetLowestDmgValue:
 			MOV AL, 5   ; Lowest possible dmg value     				 	
    	DoDamage_DoDamage:  	
			SUB [SI], AL
			MOV AH, 0
			MOV DamageToBeDealt, AX	
			; P1 Heavy is done by Vamp Heal logic
			CMP CurrentTurn, 0   
			JNE CheckIfP2IsVamp						
    	    MOV BH, Team1Classes     
    	    AND BH, 01000000B 
    	    CMP BH, 01000000B
    	    JNE DoDamage_NotVampireOrHeavy        	            	        	
    		TEST Player1Status, 00000010B
    		JNZ HeavyVampHealLogic    		    		
    		JMP DoDamage_NotVampireOrHeavy       	    	    
    	    CheckIfP2IsVamp:  
				; P2 Heavy is done by Vamp Heal logic
				CMP CurrentTurn, 1   
				JNE CheckIfP3IsVamp						
	    	    MOV BH, Team1Classes     
	    	    AND BH, 00000100B 
	    	    CMP BH, 00000100B
	    	    JNE DoDamage_NotVampireOrHeavy        	            	        	
	    		TEST Player2Status, 00000010B
	    		JNZ HeavyVampHealLogic    		    		
	    		JMP DoDamage_NotVampireOrHeavy  
    	    CheckIfP3IsVamp:  
				; P3 Heavy is done by Vamp Heal logic
				CMP CurrentTurn, 2   
				JNE CheckIfP4IsVamp						
	    	    MOV BH, Team2Classes     
	    	    AND BH, 01000000B 
	    	    CMP BH, 01000000B
	    	    JNE DoDamage_NotVampireOrHeavy        	            	        	
	    		TEST Player3Status, 00000010B
	    		JNZ HeavyVampHealLogic    		    		
	    		JMP DoDamage_NotVampireOrHeavy 	
    	    CheckIfP4IsVamp:  
				; P3 Heavy is done by Vamp Heal logic
				CMP CurrentTurn, 3   
				JNE DoDamage_NotVampireOrHeavy						
	    	    MOV BH, Team2Classes     
	    	    AND BH, 00000100B 
	    	    CMP BH, 00000100B
	    	    JNE DoDamage_NotVampireOrHeavy        	            	        	
	    		TEST Player4Status, 00000010B
	    		JNZ HeavyVampHealLogic    		    		
	    		JMP DoDamage_NotVampireOrHeavy 	    		    		    	    	
			; Vamp check Ends  
			HeavyVampHealLogic:
				MOV AX, DamageToBeDealt
				CALL LoadPlayerStatsInDI 
				; Print Vampire Heal Text
	    		CALL PrintPlayerName
	    		MOV DX, OFFSET VampHealHeavyText
	    		CALL PrintLine 
	    		MOV DL, AL      	        	
	    		CALL PrintInt
	    		MOV DX, OFFSET HPText
	    		CALL PrintLine   
	    		; Heal
	    		MOV SI, DI ; Put the stats into SI so that it can be clamped
	    		ADD [SI], AL	        		
				CALL ClampStatInSI    			        			        		    		    	  
	   	DoDamage_NotVampireOrHeavy:	
	   		MOV DamageToBeDealt, AX					  
			JNC DoDamage_NoClamp
			MOV [SI], 0
		DoDamage_NoClamp: 			
			; Print Damage Value	
	        MOV DX, OFFSET DamagedText
	        CALL PrintLine        
	        ; Temp Change CurrentTurn	                
	        MOV BL, CurrentTurn
	        MOV BH, EnemyIdentifier 	
	        MOV CurrentTurn, BH        
	    	CALL PrintPlayerName
	    	MOV CurrentTurn, BL ; Revert CurrentTurn 	    		    
	    	MOV DX, OFFSET ForText
	    	CALL PrintLine
	    	MOV AX, DamageToBeDealt ; Print stored damage dealt    	
	    	CALL PrintInt              
	    	CALL PrintNewLine
	    	; Display Enemy Remaining HP
	    	MOV DX, OFFSET ShowEnemyHPText
	    	CALL PrintLine
	    	MOV AL, [SI]
	    	CALL PrintInt
	    	MOV DX, OFFSET LeftText
	    	CALL PrintLine
	   	RET                        	  
       
    ; Set block bit in CurrentTurnStatus for player with current turn.
    ; Must be called after AlternateTurn, as this function does NOT check the AliveAndHealStatus block
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
    
    ; Update AliveAndHealStatus after every turn by checking HP of every player
    UpdateStatusOnDeath:
        MOV AL, AliveAndHealStatus
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
            MOV AliveAndHealStatus, AL  ;Update AliveAndHealStatus finally   
            RET    
                                                                                                         
    ; Generic function to clamp value between 0 and 100, expects target value in SI
    ; Must always be called immediately after subtraction to prevent against the SF being overwritten later 
    ClampStatInSI:
        LAHF
        TEST AH, 10000000B          ; Test whether sign flag is set
        JZ TestOver100
        MOV [SI], 0
        RET
        TestOver100:  
            CMP [SI], 100
            JLE ClampStatInSI_End
            MOV [SI], 100                          
        ClampStatInSI_End:
            RET

    ; Apply Burn and Poison effects after every turn, update burn and poison counters accordingly 
    ApplyDOT:  
        MOV BL, BurnDamage
        MOV BH, PoisonDamage
        TEST AliveAndHealStatus, 00010000B      ; Test whether P1 is alive
        JZ ApplyDOTP2 
        MOV SI, OFFSET Player1Stats             ; Load P1 health into SI
        TEST Player1Status, 10000000B           ; Test P1 burn bit
        JZ PoisonCheckP1         
        SUB [SI], BL                            ; Apply burn damage to P1 
        DEC P1BurnCounter
        CMP P1BurnCounter, 0
        JNE P1BurnPrint
        MOV P1BurnCounter, 0
        AND Player1Status, 01111111B
        P1BurnPrint:
            MOV DX, OFFSET PlayerText
            CALL PrintLine
            MOV DL, '1'
            CALL PrintChar
            MOV DX, OFFSET BurnDamageText
            CALL PrintLine
        PoisonCheckP1:    
            TEST Player1Status, 01000000B               ; Test P1 poison bit
            JZ ApplyDOTP2
            SUB [SI], BH                                ; Apply poison damage to P1
            DEC P1PoisonCounter
            CMP P1PoisonCounter, 0
            JNE P1PoisonPrint                   ; Reset Poison counter and bit for P2
            MOV P1PoisonCounter, 0
            AND Player1Status, 10111111B
            P1PoisonPrint:  
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '1'
                CALL PrintChar
                MOV DX, OFFSET PoisonDamageText
                CALL PrintLine      
        ApplyDOTP2:       
            CALL ClampStatInSI                            ; Clamp P1's health if needed                                 
            TEST AliveAndHealStatus, 00100000B          ; Test whether P2 is alive
            JZ ApplyDOTP3
            MOV SI, OFFSET Player2Stats                 ; Load P2 health into SI
            TEST Player2Status, 10000000B               ; Test P2 burn bit
            JZ PoisonCheckP2
            SUB [SI], BL                                ; Apply burn damage to P2
            DEC P2BurnCounter
            CMP P2BurnCounter, 0
            JNE P2BurnPrint
            MOV P2BurnCounter, 0
            AND Player2Status, 01111111B
            P2BurnPrint:   
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '2'
                CALL PrintChar
                MOV DX, OFFSET BurnDamageText
                CALL PrintLine
            PoisonCheckP2:
                TEST Player2Status, 01000000B       ; Check P2 poison bit
                JZ ApplyDOTP3
                SUB [SI], BH                        ; Apply poison damage to P2
                DEC P2PoisonCounter
                CMP P2PoisonCounter, 0
                JNE P2PoisonPrint                   ; Reset Poison counter and bit for P2
                MOV P2PoisonCounter, 0
                AND Player2Status, 10111111B
                P2PoisonPrint: 
                    MOV DX, OFFSET PlayerText
                    CALL PrintLine
                    MOV DL, '2'
                    CALL PrintChar
                    MOV DX, OFFSET PoisonDamageText
                    CALL PrintLine                    
        ApplyDOTP3:
            CALL ClampStatInSI                          ; Clamp P2's health if needed
            TEST AliveAndHealStatus, 01000000B        ; Test whether P3 is alive
            JZ ApplyDOTP4
            MOV SI, OFFSET Player3Stats               ; Load P3 health into SI
            TEST Player3Status, 10000000B             ; Test P3 burn bit
            JZ PoisonCheckP3
            SUB [SI], BL                              ; Apply burn damage to P3
            DEC P3BurnCounter
            CMP P3BurnCounter, 0
            JNE P3BurnPrint
            MOV P3BurnCounter, 0
            AND Player3Status, 01111111B
            P3BurnPrint:   
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '3'
                CALL PrintChar
                MOV DX, OFFSET BurnDamageText
                CALL PrintLine
            PoisonCheckP3:
                TEST Player3Status, 01000000B       ; Check P3 poison bit
                JZ ApplyDOTP4
                SUB [SI], BH                        ; Apply poison damage to P3
                DEC P3PoisonCounter
                CMP P3PoisonCounter, 0
                JNE P3PoisonPrint                   ; Reset Poison counter and bit for P3
                MOV P3PoisonCounter, 0
                AND Player3Status, 10111111B
            P3PoisonPrint: 
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '3'
                CALL PrintChar
                MOV DX, OFFSET PoisonDamageText
                CALL PrintLine
        ApplyDOTP4:   
            CALL ClampStatInSI                          ; Clamp P3's health if needed
            TEST AliveAndHealStatus, 10000000B        ; Test whether P4 is alive
            JZ ApplyDOT_Final
            MOV SI, OFFSET Player4Stats               ; Load P4 health into SI
            TEST Player4Status, 10000000B             ; Test P4 burn bit
            JZ PoisonCheckP4
            SUB [SI], BL                              ; Apply burn damage to P4
            DEC P4BurnCounter
            CMP P4BurnCounter, 0
            JNE P4BurnPrint
            MOV P4BurnCounter, 0                    ; Reset burn effect
            AND Player4Status, 01111111B
            P4BurnPrint:  
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '4'
                CALL PrintChar
                MOV DX, OFFSET BurnDamageText
                CALL PrintLine            
            PoisonCheckP4:
                TEST Player4Status, 01000000B           ; Check P4 poison bit
                JZ ApplyDOT_Final
                SUB [SI], BH                            ; Apply poison damage to P4
                DEC P4PoisonCounter
                CMP P4PoisonCounter, 0
                JNE P4PoisonPrint                   ; Reset Poison counter and bit for P4
                MOV P4PoisonCounter, 0
                AND Player4Status, 10111111B
                P4PoisonPrint:  
                    MOV DX, OFFSET PlayerText
                    CALL PrintLine
                    MOV DL, '4'
                    CALL PrintChar
                    MOV DX, OFFSET PoisonDamageText
                    CALL PrintLine
        ApplyDOT_Final:
            CALL ClampStatInSI                            ; Clamp P4's health if needed
            RET    
        
    ; Loads current player's stats into DI
    LoadPlayerStatsInDI:
	    ; Check Turn 0 (Player 1)  
		CMP CurrentTurn, 0
		JNE LCheckForOneTurn
		MOV DI, OFFSET Player1Stats		
		JMP LEndPrintPlayerName
		LCheckForOneTurn:
		    ; Check Turn 1 (Player 2)  
			CMP CurrentTurn, 1
			JNE LCheckForTwoTurn
			MOV DI, OFFSET Player2Stats			
			JMP LEndPrintPlayerName
		LCheckForTwoTurn:
		    ; Check Turn 2 (Player 3)  
			CMP CurrentTurn, 2
			JNE LCheckForThreeTurn
			MOV DI, OFFSET Player3Stats			
			JMP LEndPrintPlayerName
		LCheckForThreeTurn:
			; Turn 3 (Player 4)	
			MOV DI, OFFSET Player4Stats		  
			JMP LEndPrintPlayerName
		LEndPrintPlayerName:    		  			
			RET                        
        
    ; Updates critical bit in CurrentTurnStatus for players 
    ; USES DX, AH and AL
    UpdateCrit:
        ; Determine current player
        CALL LoadPlayerStatsInDI                  
        MOV AL, [DI+5]  ;Load chance to be compared into AL       
        CALL GetChance 
        JNC GoodLuck ;If current 1/100 of second is less than crit chance, we have critical hit >:)    
        ; Logic for normal hit
        MOV DX, OFFSET NormalHitText 
        CALL PrintLine
        CMP CurrentTurn, 0
        JNE P1_ResetCritical
        AND AL, 11101111b ;Reset P1_Crit
        JMP bGetChance_Final
        P1_ResetCritical:
            CMP CurrentTurn, 1
            JNE P2_ResetCritical
            AND AL, 11011111b;Reset P2_Crit
            JMP bGetChance_Final
        P2_ResetCritical:
            CMP CurrentTurn, 2
            JNE P3_ResetCritical
            AND AL, 10111111b ;Reset P3_Crit
            JMP bGetChance_Final
        P3_ResetCritical:
            AND CurrentTurn, 01111111b    ;  Reset P4_Crit
            JMP bGetChance_Final    
        ;Critical Hit
        GoodLuck:
            MOV DX, OFFSET CriticalHitText
            CALL PrintLine
            MOV AH, CurrentTurn 
            MOV AL, CurrentTurnStats
            CMP CurrentTurn, 0
            JNE P1_SetCritical
            OR AL, 00010000b ;Set P1_Crit 
            JMP bGetChance_Final
            P1_SetCritical:
                CMP CurrentTurn, 1     
                JNE P2_SetCritical
                OR AL, 00100000b ;Set P2_Crit
                JMP bGetChance_Final 
            P2_SetCritical:
                CMP CurrentTurn, 2  
                JNE P3_SetCritical
                OR AL, 01000000b ;Set P3_Crit
                JMP bGetChance_Final
            P3_SetCritical:
                OR AL, 10000000b ;Set P4_Crit
        bGetChance_Final:
        	MOV CurrentTurnStats, AL
        	RET 

	; Circular increments current turn
     UpdateCurrentTurn:
        INC CurrentTurn
        CMP CurrentTurn, 4
        JGE WrappedIs4
        RET
        WrappedIs4: 
            MOV CurrentTurn, 0
            RET
	
	; Progress player turns
	 AlternateTurn:
	 	; REVISE THIS DH LOGIC!
;        ; Each recursive call increments DH by 1. At DH = 4 (0->1->2->3-->4), we know that 4 recursions were already made. In this case, all players are dead
;        INC DH
;        CMP DH, 4
;        JE AllDead  ; Jump to AllDead to prevent infinite recursion        
        CALL UpdateCurrentTurn   ; Increment AL, wrap if necessary
        MOV DL, AliveAndHealStatus    ; Load AliveAndHealStatus byte into DL to check if the current player is dead or not
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
	        MOV DX, OFFSET AllPlayersDiedText
	        CALL PrintLine
	        CALL PrintNewLine
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
	    ; Assassin   (1 in binary)
	    CheckIfAssassin:  
	        CMP BL, '2' 
	        JNE CheckIfPyromancer     
	        CMP CurrentTurn, 0  
	        JNE CheckP2Assassin
	        OR Team1Classes, 00010000B
	        JMP Assassin_Final  
	        CheckP2Assassin:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Assassin
    	        OR Team1Classes, 00000001B
    	        JMP Assassin_Final
    	    CheckP3Assassin:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Assassin
    	        OR Team2Classes, 00010000B
    	        JMP Assassin_Final
            MakeP4Assassin:
                OR Team2Classes, 00000001B
            Assassin_Final:
    	        MOV DI, OFFSET AssassinStats  
    	        MOV DX, OFFSET Assassin  
    	        JMP EndClassSelection   
	    ; Pyromancer    (2 in binary)  
	    CheckIfPyromancer:  
	        CMP BL, '3'  
	        JNE CheckIfHealer
	        CMP CurrentTurn, 0  
	        JNE CheckP2Pyromancer
	        OR Team1Classes, 00100000B
	        JMP Pyromancer_Final  
	        CheckP2Pyromancer:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Pyromancer
    	        OR Team1Classes, 00000010B
    	        JMP Pyromancer_Final
    	    CheckP3Pyromancer:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Pyromancer
    	        OR Team2Classes, 00100000B
    	        JMP Pyromancer_Final
            MakeP4Pyromancer:
                OR Team2Classes, 00000010B
            Pyromancer_Final: 
    	        MOV DI, OFFSET PyromancerStats  
    	        MOV DX, OFFSET Pyromancer  
    	        JMP EndClassSelection  
	    ; Healer     (3 in binary)
	    CheckIfHealer:  
	        CMP BL, '4'  
	        JNE CheckIfVanguard   
	        CMP CurrentTurn, 0  
	        JNE CheckP2Healer
	        OR Team1Classes, 00110000B
	        JMP Healer_Final  
	        CheckP2Healer:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Healer
    	        OR Team1Classes, 00000011B
    	        JMP Healer_Final
    	    CheckP3Healer:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Healer
    	        OR Team2Classes, 00110000B
    	        JMP Healer_Final
            MakeP4Healer:
                OR Team2Classes, 00000011B
            Healer_Final:  
    	        MOV DI, OFFSET HealerStats  
    	        MOV DX, OFFSET Healer  
    	        JMP EndClassSelection  
	    ; Vanguard     (4 in binary)
	    CheckIfVanguard:  
	        CMP BL, '5'  
	        JNE CheckIfVampire 
	        CMP CurrentTurn, 0  
	        JNE CheckP2Vanguard
	        OR Team1Classes, 01000000B
	        JMP Vanguard_Final  
	        CheckP2Vanguard:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Vanguard
    	        OR Team1Classes, 00000100B
    	        JMP Vanguard_Final
    	    CheckP3Vanguard:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Vanguard
    	        OR Team2Classes, 01000000B
    	        JMP Vanguard_Final
            MakeP4Vanguard:
                OR Team2Classes, 00000100B
            Vanguard_Final:     
    	        MOV DI, OFFSET VanguardStats  
    	        MOV DX, OFFSET Vanguard  
    	        JMP EndClassSelection  
	    ; Vampire        (5 in binary)
	    CheckIfVampire:  
	        CMP BL, '6'  
	        JNE ClassSelection_InvalidInput 
	        CMP CurrentTurn, 0  
	        JNE CheckP2Vampire
	        OR Team1Classes, 01010000B
	        JMP Vampire_Final  
	        CheckP2Vampire:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Vampire
    	        OR Team1Classes, 00000101B
    	        JMP Vampire_Final
    	    CheckP3Vampire:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Vampire
    	        OR Team2Classes, 01010000B
    	        JMP Vampire_Final
            MakeP4Vampire:
                OR Team2Classes, 00000101B
            Vampire_Final: 
    	        MOV DI, OFFSET VampireStats  
    	        MOV DX, OFFSET Vampire
    	        JMP EndClassSelection 
	    ; Input out of bound 
	    ClassSelection_InvalidInput:
            MOV DX, OFFSET InvalidInputText 
            MOV BL, 'X'
            CALL PrintLine
            CALL PrintNewLine
            RET  	    
	    EndClassSelection:   
		    CALL PrintLine 
			CALL PrintNewLine			
			CALL PrintNewLine
			RET
	 
	; Loads Player Stats based on the DI Value
	; Player Has To Be Loaded inside SI	
    InitializePlayerStats:           
        MOV CX, 7                    ; Loop counter (7 elements)        
	    InitializePlayerStatsLoop:
	        MOV AL, [DI]    
	        MOV [SI], AL    
	        INC SI          
	        INC DI          
	        LOOP InitializePlayerStatsLoop  ; Repeat until CX = 0
	    RET
	          
	; Apply Vanguard's passive (+5 Def)  to teammates
	ApplyVanguardPassive:
	    TEST Team1Classes, 01000000B    ; Check if P1 is Vanguard
	    JZ ApplyP2Vanguard
	    ADD [Player2Stats+4], 5
	    ApplyP2Vanguard:
	        TEST Team1Classes, 00000100B    ; Check if P2 is Vanguard
	        JZ ApplyP3Vanguard
	        ADD [Player2Stats+4], 5
	    ApplyP3Vanguard:
	        TEST Team2Classes, 01000000B    ; Check if P3 is Vanguard
	        JZ ApplyP4Vanguard
	        ADD [Player4Stats+4], 5
	    ApplyP4Vanguard:
	        TEST Team2Classes, 00000100B    ; Check if P4 is Vanguard
	        JZ ApplyVanguardPassive_Final
	        ADD [Player3Stats+4], 5
	    ApplyVanguardPassive_Final:
	        RET  
	        
	; Give Player choice for in Combat, Loads Choice in AL    
	GivePlayerMainChoice:
		CALL PrintPlayerName
		CALL PrintNewLine 				
 	 	MOV DX, OFFSET ChooseYourMoveText  
    	CALL PrintLine   	 
	    MOV DX, OFFSET MoveChoicesText  
    	CALL PrintLine                                    
    	CALL TakeCharInput
    	MOV BL, AL        
    	CALL PrintNewLine
    	CALL PrintNewLine 
    	MOV AL, BL   
    	CMP AL, '1'
    	JE LightAttack
    	CMP AL, '2'
    	JE HeavyAttack
    	CMP AL, '3'
    	JE Defend
    	CMP AL, '4'
    	JE Heal
    	CMP AL, '5'
    	JE UltimateAttack
    	JMP GivePlayerMainChoice_InvalidInput    	
    	RET  
    	; Light Attack 	   
    	LightAttack:    	   
    		MOV DH, LightAttackStaminaCost 
    	    ; Change Status Indicating which type of attack 
			; was chosen by the player, it is done by updating
    	    ; the 3rd last bit on the PlayerXStatus vars
    	    CMP CurrentTurn, 0
    	    JNE LightMChoice_1  
    	    CMP Team1Vitality, 0            ; Check if under vitality
    	    JG Light_P1SkipStaminaCheck     	    
    	    CMP [PlayersStamina+0], DH      ; Check if has 15 stamina
    	    JC NotEnoughStamina   	                      
    	    SUB [PlayersStamina+0], DH      ; Deduct Stamina  
    	    Light_P1SkipStaminaCheck:
	    	    OR Player1Status, 00000100B
	    	    JMP AttackFinal
    	    LightMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE LightMChoice_2 
        	   	CMP Team1Vitality, 0        ; Check if under vitality
    	    	JG Light_P2SkipStaminaCheck   
	    	    CMP [PlayersStamina+1], DH ; Check if has 15 stamina  	    	    
	    	    JC NotEnoughStamina           	                       
	    	    SUB [PlayersStamina+1], DH ; Deduct Stamina  
	    	    Light_P2SkipStaminaCheck:
        	    	OR Player2Status, 00000100B
        	    	JMP AttackFinal
            LightMChoice_2:
                CMP CurrentTurn, 2
                JNE LightMChoice_3  
        	   	CMP Team2Vitality, 0        ; Check if under vitality
    	    	JG Light_P3SkipStaminaCheck                  
	    	    CMP [PlayersStamina+2], DH ; Check if has 15 stamina
	    	    JC NotEnoughStamina          
	    	    SUB [PlayersStamina+2], DH ; Deduct Stamina 
	    	    Light_P3SkipStaminaCheck:        
        	    	OR Player3Status, 00000100B 
                	JMP AttackFinal
            LightMChoice_3:   
        	   	CMP Team2Vitality, 0        ; Check if under vitality
    	    	JG Light_P4SkipStaminaCheck                   	
	    	    CMP [PlayersStamina+3], DH ; Check if has 15 stamina
	    	    JC NotEnoughStamina 
	    	    SUB [PlayersStamina+3], DH ; Deduct Stamina    
	    	    Light_P4SkipStaminaCheck:              
        	    	OR Player4Status, 00000100B
        	    	JMP AttackFinal 
        ; Heavy Attack    	      	    
    	HeavyAttack:   
    		MOV DH, HeavyAttackStaminaCost 	      
    	    ; Change Status Indicating which type of attack 
    	    ; was chosen by the player, it is done by updating
    	    ; the 2nd last bit on the PlayerXStatus vars
    	    CMP CurrentTurn, 0
    	    JNE HeavyMChoice_1  
    	   	CMP Team1Vitality, 0        ; Check if under vitality
	    	JG Heavy_P1SkipStaminaCheck     	     
    	    CMP [PlayersStamina+0], DH ; Check if has 30 stamina
    	    JC NotEnoughStamina 	 
    	    SUB [PlayersStamina+0], DH ; Deduct Stamina   
			Heavy_P1SkipStaminaCheck:    	        	    
    	    	OR Player1Status, 00000010B  ; Set Heavy Atk    	    
    	    ; Heavy is done by healer logic
    	    MOV BH, Team1Classes     
    	    AND BH, 00110000B 
    	    CMP BH, 00110000B
    	    JE P1HeavyHeal 
    	    ; Healer check Ends        	 
    	    JMP AttackFinal
    	    HeavyMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE HeavyMChoice_2 
        	    CMP Team1Vitality, 0        ; Check if under vitality
	    		JG Heavy_P2SkipStaminaCheck
        	    CMP [PlayersStamina+1], DH ; Check if has 30 stamina
				JC NotEnoughStamina         
				SUB [PlayersStamina+1], DH ; Deduct Stamina  
				Heavy_P2SkipStaminaCheck: 
        	    	OR Player2Status, 00000010B        
	    	    ; Heavy is done by healer logic
	    	    MOV BH, Team1Classes     
	    	    AND BH, 00000011B 
	    	    CMP BH, 00000011B
	    	    JE P2HeavyHeal   
	    	    ; Healer check Ends      	           	            	    
        	    JMP AttackFinal
            HeavyMChoice_2:
                CMP CurrentTurn, 2
                JNE HeavyMChoice_3  
                CMP Team2Vitality, 0        ; Check if under vitality
	    		JG Heavy_P3SkipStaminaCheck
        	    CMP [PlayersStamina+2], DH ; Check if has 30 stamina
				JC NotEnoughStamina  
				SUB [PlayersStamina+2], DH ; Deduct Stamina
				Heavy_P3SkipStaminaCheck:                  
        	    	OR Player3Status, 00000010B    
	    	    ; Heavy is done by healer logic
	    	    MOV BH, Team2Classes     
	    	    AND BH, 00110000B 
	    	    CMP BH, 00110000B
	    	    JE P3HeavyHeal   
	    	    ; Healer check Ends          	    
                JMP AttackFinal
            HeavyMChoice_3:
           		CMP Team2Vitality, 0        ; Check if under vitality
	    		JG Heavy_P4SkipStaminaCheck    
        	    CMP [PlayersStamina+3], DH ; Check if has 30 stamina
				JC NotEnoughStamina 
				SUB [PlayersStamina+3], DH ; Deduct Stamina  
				Heavy_P4SkipStaminaCheck:
        	    	OR Player4Status, 00000010B 
	    	    ; Heavy is done by healer logic
	    	    MOV BH, Team2Classes     
	    	    AND BH, 00000011B 
	    	    CMP BH, 00000011B
	    	    JE P4HeavyHeal   
	    	    ; Healer check Ends         	    
        	    JMP AttackFinal  
        	; Checks if p2 alive and heals them, else heals self
        	P1HeavyHeal:
        		TEST AliveAndHealStatus, 00100000B
        		JZ HeavyHealLogic
        		MOV BH, CurrentTurn ; Temp Store 
        		MOV CurrentTurn, 1  ; Set Current Turn to P2  
        		JMP HeavyHealLogic
        	; Checks if p1 alive and heals them, else heals self
        	P2HeavyHeal:
        		TEST AliveAndHealStatus, 00010000B
        		JZ HeavyHealLogic
        		MOV BH, CurrentTurn ; Temp Store 
        		MOV CurrentTurn, 0  ; Set Current Turn to P1  
        		JMP HeavyHealLogic  
        	; Checks if p4 alive and heals them, else heals self
        	P3HeavyHeal:
        		TEST AliveAndHealStatus, 10000000B
        		JZ HeavyHealLogic
        		MOV BH, CurrentTurn ; Temp Store 
        		MOV CurrentTurn, 3  ; Set Current Turn to P4   
        		JMP HeavyHealLogic
        	; Checks if p3 alive and heals them, else heals self
        	P4HeavyHeal:
        		TEST AliveAndHealStatus, 01000000B
        		JZ HeavyHealLogic
        		MOV BH, CurrentTurn ; Temp Store 
        		MOV CurrentTurn, 2  ; Set Current Turn to P3   	      		  
        		JMP HeavyHealLogic
    		HeavyHealLogic:
				CALL LoadPlayerStatsInDI 
        		CALL PrintPlayerName
        		MOV DX, OFFSET HealerHeavyText
        		CALL PrintLine      
        		MOV CurrentTurn, BH  ; Revert Current Turn
        		MOV SI, DI ; Put the stats into SI so that it can be clamped
        		ADD [SI], 15 	        		
    			CALL ClampStatInSI          			        			
        		RET	
        			         			        			
        ; Defend	    	    
    	Defend:
    	    CMP CurrentTurn, 0
    	    JNE CheckMChoice_1
    	    OR CurrentTurnStats, 00000001B
    	    RET
    	    CheckMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE CheckMChoice_2
        	    OR CurrentTurnStats, 00000010B
        	    RET
            CheckMChoice_2:
                CMP CurrentTurn, 2
                JNE CheckMChoice_3
                OR CurrentTurnStats, 00000100B
                RET
            CheckMChoice_3:
                OR CurrentTurnStats, 00001000B
                RET 
		; Heal                
        Heal:
            CMP CurrentTurn, 0
    	    JNE HealMChoice_1
    	    MOV SI, OFFSET Player1Stats   
    	    OR AliveAndHealStatus, 00000001B
    	    MOV BL, TeamSynergies
    	    AND BL, 11110000B
	        CMP BL, 01100000B        ; Check Team 1 for Holy Empire
    	    JE CheckKnight_P1
    	    JMP HealFinal    
    	    CheckKnight_P1:
    	        TEST Team1Classes, 11110000B
    	        JNZ HealFinal                   ; P1 not a Knight, won't benefit from Holy Empire
    	        ADD [SI], 5                     ; Heal P1 for an additional 5 HP
                MOV DX, OFFSET HolyEmpireHealText
                CALL PrintLine
    	        JMP HealFinal
    	    JMP HealFinal
    	    HealMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE HealMChoice_2
        	    MOV SI, OFFSET Player2Stats 
        	    OR AliveAndHealStatus, 00000010B
        	    CMP TeamSynergies, 01100000B        ; Check Team 1 for Holy Empire
        	    JE CheckKnight_P2
        	    JMP HealFinal    
        	    CheckKnight_P2:
        	        TEST Team1Classes, 00001111B
        	        JNZ HealFinal                   ; P2 not a Knight, won't benefit from Holy Empire
        	        ADD [SI], 5                     ; Heal P2 for an additional 5 HP
                    MOV DX, OFFSET HolyEmpireHealText
                    CALL PrintLine
        	        JMP HealFinal
            HealMChoice_2:
                CMP CurrentTurn, 2
                JNE HealMChoice_3
                OR AliveAndHealStatus, 00000100B; 
        	    MOV SI, OFFSET Player3Stats
        	    MOV BL, TeamSynergies
        	    AND BL, 00001111B
    	        CMP BL, 00000110B                   ; Check Team 2 for Holy Empire
        	    JE CheckKnight_P3
                JMP HealFinal
                CheckKnight_P3:
                    TEST Team2Classes, 11110000B    ; Check if P3 is Knight
                    JNZ HealFinal
                    ADD [SI], 5                     ; Heal P3 for an additonal 5 HP
                    MOV DX, OFFSET HolyEmpireHealText
                    CALL PrintLine
                    JMP HealFinal
            HealMChoice_3:
        	    MOV SI, OFFSET Player4Stats 
        	    OR AliveAndHealStatus, 00001000B
        	    CMP TeamSynergies, 00000110B        ; Check for Holy Empire
        	    JE CheckKnight_P4
                JMP HealFinal
                CheckKnight_P4:
                    TEST Team2Classes, 00001111B    ; Check if P4 is Knight
                    JNZ HealFinal
                    ADD [SI], 5                     ; Heal P4 for an additonal 5 HP
                    MOV DX, OFFSET HolyEmpireHealText
                    CALL PrintLine
                    JMP HealFinal
        	    JMP HealFinal             
        ClampHP:      
            MOV [SI], 100
            RET
    	HealFinal: 
    	    MOV AL, HPGainPerTurn
    	    ADD [SI], AL
    	    CMP [SI], 100
    	    JGE ClampSection
    	    PrintHealText:  
        	    MOV DX, OFFSET SelfHealText
        	    CALL PrintLine
        	    RET      
    	    ClampSection:
    	        CALL ClampHP 
    	        JMP PrintHealText 
        UltimateAttack:      
            MOV DH, UltimateAttackStaminaCost
            CMP CurrentTurn, 0
            JNE UltimateMChoice_1
            CMP [PlayersUltCooldown], 0           ; Check if P1 has ultimate ready
            JNE UltimateNotReady
            CMP Team1Vitality, 0                ; Check if under vitality
	    	JG Ultimate_P1SkipStaminaCheck     	     
    	    CMP [PlayersStamina], DH          ; Check if has 80 stamina
    	    JC NotEnoughStamina 	 
    	    SUB [PlayersStamina], DH          ; Deduct Stamina   
			Ultimate_P1SkipStaminaCheck:    
                OR Player1Status, 00000001B         ; Set P1's Ult bit
                MOV AL, Team1Classes                ; Load Team1Classes into AL
                AND AL, 11110000B                   ; Remove P2's class info
                CMP AL, 00100000B                   ; Check P1 pyromancer
                JNE P1AssassinUltimateCheck
                ; Pyromancer ultimate targets both enemies, no need to give target choice
                MOV [PlayersUltCooldown], 4           ; Reset Pyromancer ultimate cooldown
                JMP AttackFinalNoChoice
                P1AssassinUltimateCheck:
                    CMP AL, 00010000B               ; Check P1 assassin
                    JNE P1KnightUltimateCheck
                    ; Assassin ultimate is random, no need to give target choice
                    MOV BL, TeamSynergies           ; Load TeamSynergies in temp GPR
                    AND BL, 11110000B               ; Remove Team 2's synergy bits
                    CMP BL, 00110000B               ; Check for Assassin's Creed
                    JE SetP1UltCooldownTo3     
                    MOV [PlayersUltCooldown], 4       ; Set cooldown to 4
                    JMP AttackFinalNoChoice
                    SetP1UltCooldownTo3:
                        MOV [PlayersUltCooldown], 3  ; Set cooldown to 3
                        JMP AttackFinalNoChoice
                P1KnightUltimateCheck:
                    ; Knight ultimate is for player's own team, no need to give target choice 
                    CMP AL, 00000000B
                    JNE AttackFinalNoChoice
                    MOV [PlayersUltCooldown], 3        ; Reset Knight's ultimate cooldown
                    JMP AttackFinalNoChoice
            UltimateMChoice_1:
                CMP CurrentTurn, 1
                JNE UltimateMChoice_2
                CMP [PlayersUltCooldown+1], 0       ; Check if P2 has ultimate ready
                JG UltimateNotReady
                CMP Team1Vitality, 0                ; Check if under vitality
    	    	JG Ultimate_P2SkipStaminaCheck     	     
        	    CMP [PlayersStamina+1], DH            ; Check if has 80 stamina
        	    JC NotEnoughStamina 	 
        	    SUB [PlayersStamina+1], DH            ; Deduct Stamina
        	    Ultimate_P2SkipStaminaCheck:   
                    OR Player2Status, 00000001B
                    MOV AL, Team1Classes            ; Load Team1Classes into AL
                    AND AL, 00001111B               ; Remove P1's class info 
                    CMP AL, 00000010B                     ; Check if P2 is pyromancer
                    JNE P2AssassinUltimateCheck           
                    ; Pyromancer ultimate targets both enemies, no need to give target choice
                    MOV [PlayersUltCooldown+1], 4           ; Reset Pyromancer ultimate cooldown
                    JMP AttackFinalNoChoice 
                    P2AssassinUltimateCheck:
                        CMP AL, 00000001B               ; Check if P2 is assassin
                        JNE P2KnightUltimateCheck
                        ; Assassin ultimate is random, no need to give target choice
                        MOV BL, TeamSynergies           ; Load TeamSynergies in temp GPR
                        AND BL, 11110000B               ; Remove Team 2's synergy bits
                        CMP BL, 00110000B               ; Check for Assassin's Creed
                        JE SetP2UltCooldownTo3
                        MOV [PlayersUltCooldown+1], 4
                        JMP AttackFinalNoChoice
                        SetP2UltCooldownTo3:
                            MOV [PlayersUltCooldown+1], 3
                            JMP AttackFinalNoChoice
                    P2KnightUltimateCheck:
                        ; Knight ultimate is for player's own team, no need to give target choice 
                        TEST AL, 00000000B
                        JNZ AttackFinal
                        MOV [PlayersUltCooldown+1], 3        ; Reset Knight ultimate cooldown
                        JMP AttackFinalNoChoice
            UltimateMChoice_2:
                CMP CurrentTurn, 2
                JNE UltimateMChoice_3 
                CMP [PlayersUltCooldown+2], 0       ; Check if P3 has ultimate ready
                JG UltimateNotReady
                CMP Team2Vitality, 0
                JG Ultimate_P3SkipStaminaCheck
                CMP [PlayersStamina+2], DH            ; Check if has 80 stamina
        	    JC NotEnoughStamina 	 
        	    SUB [PlayersStamina+2], DH            ; Deduct Stamina 
        	    Ultimate_P3SkipStaminaCheck:
                    OR Player3Status, 00000001B
                    MOV AL, Team2Classes    ; Load Team2Classes into AL
                    AND AL, 11110000B       ; Remove P4's class info
                    ; Pyromancer ultimate targets both enemies, no need to give target choice
                    CMP AL, 00100000B
                    JNE P3AssassinUltimateCheck
                    MOV [PlayersUltCooldown+2], 4
                    JMP AttackFinalNoChoice
                    P3AssassinUltimateCheck:
                        CMP AL, 00010000B
                        JNE P3KnightUltimateCheck
                        ; Assassin ultimate is random, no need to give target choice
                        MOV BL, TeamSynergies           ; Load TeamSynergies in temp GPR
                        AND BL, 00001111B               ; Remove Team 1's synergy bits
                        CMP BL, 00000011B               ; Check for Assassin's Creed
                        JE SetP3UltCooldownTo3
                        MOV [PlayersUltCooldown+2], 4
                        JMP AttackFinalNoChoice
                        SetP3UltCooldownTo3:
                            MOV [PlayersUltCooldown+2], 3
                            JMP AttackFinalNoChoice
                    P3KnightUltimateCheck:
                        CMP AL, 00000000B
                        ; Add logic to skip to next class' Ultimate Check 
                        ; Knight ultimate is for player's own team, no need to give target choice
                        MOV [PlayersUltCooldown+2], 3
                        JMP AttackFinalNoChoice
            UltimateMChoice_3:
                CMP [PlayersUltCooldown+3], 0       ; Check if P4 has ultimate ready
                JG UltimateNotReady
                CMP Team2Vitality, 0
                JG Ultimate_P4SkipStaminaCheck
                CMP [PlayersStamina+3], DH            ; Check if has 80 stamina
        	    JC NotEnoughStamina 	 
        	    SUB [PlayersStamina+3], DH            ; Deduct Stamina
        	    Ultimate_P4SkipStaminaCheck: 
                    OR Player4Status, 00000001B
                    MOV AL, Team2Classes
                    AND AL, 00001111B
                    CMP AL, 00000010B
                    JNE P4AssassinUltimateCheck
                    ; Pyromancer ultimate targets both enemies, no need to give target choice
                    MOV [PlayersUltCooldown+3], 4     ; Reset Pyromancer ultimate cooldown
                    JMP AttackFinalNoChoice                                                  
                    P4AssassinUltimateCheck:
                        ; Assassin ultimate is random, no need to give target choice
                        CMP AL, 00000001B
                        JNE P4KnightUltimateCheck
                        ; Assassin ultimate is random, no need to give target choice
                        MOV BL, TeamSynergies           ; Load TeamSynergies in temp GPR
                        AND BL, 00001111B               ; Remove Team 1's synergy bits
                        CMP BL, 00000011B               ; Check for Assassin's Creed
                        JE SetP4UltCooldownTo3
                        MOV [PlayersUltCooldown+3], 4
                        JMP AttackFinalNoChoice
                        SetP4UltCooldownTo3:
                            MOV [PlayersUltCooldown+3], 3
                            JMP AttackFinalNoChoice   
                    P4KnightUltimateCheck:
                        CMP AL, 00000000B
                        ; JNE P4HealerUltimateCheck
                        ; Knight ultimate is for player's own team, no need to give target choice
                        MOV [PlayersUltCooldown+3], 3
                        JMP AttackFinalNoChoice           
    	; Attack Chosen, In case some common finishing
    	; logic is required         
    	AttackFinal:       		
    		CALL TargetEnemy
    		AttackFinalNoChoice:
        		CALL PrintNewLine 
        	    RET      
    	; Not Enough Stamina             
 		NotEnoughStamina:
 			MOV DX, OFFSET NotEnoughStaminaText
 			CALL PrintLine
 			JMP GivePlayerMainChoice
 		; Ultimate not yet ready
 		UltimateNotReady:
 		    MOV DX, OFFSET UltimateNotReadyText
 		    CALL PrintLine
 		    JMP GivePlayerMainChoice
 		; Invalid INput
    	GivePlayerMainChoice_InvalidInput:
    	    MOV DX, OFFSET InvalidInputText
    	    CALL PrintLine
    	    JMP GivePlayerMainChoice   
    	RET
    
    ; Set synergies for both teams. Must be called at the end of each team's class selection phase. Relies on Team1Classes and Team2Classes to be properly masked	
    UpdateSynergy:     
        CMP CurrentTurn, 2
        JNC LoadTeam2Classes 
        MOV BL, Team1Classes
        MOV SI, OFFSET Player1Stats
        MOV DI, OFFSET Player2Stats
        JMP UpdateSynergy_BeginChecks 
        LoadTeam2Classes: 
            MOV BL, Team2Classes
            MOV SI, OFFSET Player3Stats
            MOV DI, OFFSET Player4Stats 
        UpdateSynergy_BeginChecks:
        ; Nobless Oblige, both knights 
        TEST BL, 11111111B 
        JNZ CheckGreatWall
        ; Increase LDmg and HDmg of both knights by 10
        ADD [SI+2], 10
        ADD [SI+3], 10
        ADD [DI+2], 10
        ADD [DI+3], 10
        OR TeamSynergies, 00000001B     ; Update TeamSynergies 
        MOV DX, OFFSET NoblesObligeText
        CALL PrintLine
        JMP UpdateSynergy_Final
        CheckGreatWall:            ; Healer (0011) + Vanguard (0100)
            CMP BL, 00110100B
            JE GreatWall_FirstHealer   
            CMP BL, 01000011B
            JE GreatWall_FirstVanguard
            JMP CheckScorchedEarth
            MOV DX, OFFSET GreatWallText
            CALL PrintLine
            GreatWall_FirstHealer:
                ADD [SI+4], 10
                ADD [DI+1], 30
                ADD [DI+2], 30
                OR TeamSynergies, 00000010B
                JMP UpdateSynergy_Final
            GreatWall_FirstVanguard:
                ADD [DI+4], 10
                ADD [SI+1], 30
                ADD [SI+2], 30
                OR TeamSynergies, 00000010B 
                JMP UpdateSynergy_Final 
        CheckScorchedEarth:         ; Both Pyromancers (00100010)
            CMP BL, 00100010B
            JNE CheckAssassinCreed
            MOV DX, OFFSET ScorchedEarthText
            CALL PrintLine
            OR TeamSynergies, 00000100B
            JMP UpdateSynergy_Final
        CheckAssassinCreed:        ; Both Assassins (00010001)
            CMP BL, 00010001B  
            JNE CheckCountsGenerosity
            MOV DX, OFFSET AssassinsCreedText
            CALL PrintLine
            OR TeamSynergies, 00000011B
            ; Decrease HP and MaxHP by 10 for both assassins
            SUB [SI], 10
            SUB [SI+1], 10
            SUB [DI], 10
            SUB [DI+1], 10
            ; Decrease Ultimate cooldown by 1 for both assassins
            SUB [SI+6], 1
            SUB [DI+6], 1
            JMP UpdateSynergy_Final
        CheckCountsGenerosity:      ; Vampire (0101) + Vanguard (0100)
            CMP BL, 01010100B
            JE CountsGenerosity
            CMP BL, 01000101B 
            JE CountsGenerosity
            JMP CheckHolyEmpire
            CountsGenerosity:
                MOV DX, OFFSET CountsGenerosityText
                CALL PrintLine                     
                OR TeamSynergies, 00000101B
                JMP UpdateSynergy_Final
        CheckHolyEmpire:            ; Healer (0011) + Knight (0000)
            CMP BL, 00110000B
            JE HolyEmpire
            CMP BL, 00000011B
            JE HolyEmpire
            JMP UpdateSynergy_Final
            HolyEmpire: 
                MOV DX, OFFSET HolyEmpireText
                CALL PrintLine   
                OR TeamSynergies, 00000110B
        UpdateSynergy_Final:
            CMP CurrentTurn, 2
            JC ShiftSynergyLeft
            RET
            ShiftSynergyLeft:
                MOV CL, 4
                SHL TeamSynergies, CL
                RET
            
    	                                                                            	    	   
main:
;==================================================================================
; MAIN FUNCTION
;================================================================================== 
    MOV AX, data
    MOV DS, AX        
    
    ; Print P1 MSG     
					;====; 
					; COMMENTED OUT FOR DEBUGGING, NO NEED TO KEEP ON SELECTING CLASSES OVER AND OVER!!!!!
					;====;  
    MainP1ClassSelection:          
    	CALL PrintPlayerName    
    	CALL PrintNewLine   		          
        MOV DX, OFFSET PrintPlayerStatsText  
    	CALL PrintLine        
    	; Class Selection
    	CALL SelectPlayerClass  
    	CMP BL, 'X'
    	JE MainP1ClassSelection  
        MOV SI, OFFSET Player1Stats
       	CALL InitializePlayerStats    
       	; Print Stats
       	MOV SI, OFFSET Player1Stats
        CALL PrintPlayerStats      
        CALL PrintNewLine 
        CALL PrintNewLine   
    
    ; Print P2 MSG  
    MainP2ClassSelection:
        CALL UpdateCurrentTurn
    	CALL PrintPlayerName    
    	CALL PrintNewLine      	
        MOV DX, OFFSET PrintPlayerStatsText
    	CALL PrintLine        
    	; Class Selection
    	CALL SelectPlayerClass	 
    	CMP BL, 'X'
    	JE MainP2ClassSelection 
        MOV SI, OFFSET Player2Stats
       	CALL InitializePlayerStats    
    	; Print Stats 
    	MOV SI, OFFSET Player2Stats
        CALL PrintPlayerStats    
        CALL PrintNewLine 
        CALL PrintNewLine
    
    CALL UpdateSynergy
       
 	; Print P3 MSG
 	MainP3ClassSelection:
        CALL UpdateCurrentTurn
    	CALL PrintPlayerName    
    	CALL PrintNewLine      	
        MOV DX, OFFSET PrintPlayerStatsText
    	CALL PrintLine        
    	; Class Selection
    	CALL SelectPlayerClass	   
    	CMP BL, 'X'
    	JE MainP3ClassSelection 
        MOV SI, OFFSET Player3Stats
       	CALL InitializePlayerStats    
    	; Print Stats 
    	MOV SI, OFFSET Player3Stats
        CALL PrintPlayerStats    
        CALL PrintNewLine 
        CALL PrintNewLine 
    
 	; Print P4 MSG    
 	MainP4ClassSelection:
        CALL UpdateCurrentTurn
    	CALL PrintPlayerName    
    	CALL PrintNewLine      	
        MOV DX, OFFSET PrintPlayerStatsText
    	CALL PrintLine        
    	; Class Selection
    	CALL SelectPlayerClass	
    	CMP BL, 'X'
    	JE MainP4ClassSelection
        MOV SI, OFFSET Player4Stats
       	CALL InitializePlayerStats    
    	; Print Stats 
    	MOV SI, OFFSET Player4Stats
        CALL PrintPlayerStats    
        CALL PrintNewLine 
        CALL PrintNewLine  
        
    CALL UpdateSynergy
    CALL ApplyVanguardPassive
    CALL UpdateCurrentTurn
;                        
	; TEMPORARILY CLASS ASSIGNMENT ONLY!!!!  
	; p1 	
;	CALL SelectPlayerClass
;	MOV SI, OFFSET Player1Stats
;	CALL InitializePlayerStats
;		; p2
;	CALL UpdateCurrentTurn
;	MOV DI, OFFSET AssassinStats
;	MOV SI, OFFSET Player2Stats
;	CALL InitializePlayerStats                             
;    CALL UpdateSynergy                                 
;    ; p3                
;    CALL UpdateCurrentTurn 
;	MOV DI, OFFSET AssassinStats
;	MOV SI, OFFSET Player3Stats
;	CALL InitializePlayerStats                             
;        ; p4                                       
;	CALL UpdateCurrentTurn                
;	MOV DI, OFFSET AssassinStats 	
;	MOV SI, OFFSET Player4Stats
;	CALL InitializePlayerStats                        
;    CALL UpdateCurrentTurn 
;    CALL UpdateSynergy 
    MOV CurrentTurn, 0   
    GameLoop:              
    	; CHOICES For Round 1 (Should be moved to a function)    (Not moving this to a function yet, you might have had some more things planned for it which I don't know)                      	
    	; Give Player 1 Choice        	
    	CALL PrintMatchTurn
    	CMP CurrentTurn, 0
    	JNE P2GameChoice
    	TEST Player1Status, 00100000B
        JNZ P1Paralysed   	 
    	CALL GivePlayerMainChoice  
    	CALL PrintNewLine 
    	; Give Player 2 Choice	 
    	CALL AlternateTurn
    	JMP P2GameChoice
    	P1Paralysed:             
    	    MOV DX, OFFSET PlayerText
    	    CALL PrintLine
    	    MOV DX, '1'
    	    CALL PrintChar
    	    MOV DX, OFFSET ParalysisText	
    	    CALL PrintLine  
    	    AND Player1Status, 11011111B
    	    CALL AlternateTurn
    	P2GameChoice:
    	    CMP CurrentTurn, 1
    	    JNE P3GameChoice   
    	    TEST Player2Status, 00100000B
    	    JNZ P2Paralysed
        	CALL GivePlayerMainChoice
        	CALL PrintNewLine  	
    		CALL AlternateTurn
            JMP P3GameChoice
            P2Paralysed:             
        	    MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '2'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisText	
        	    CALL PrintLine  
        	    AND Player2Status, 11011111B
        	    CALL AlternateTurn  
    	; Give Player 3 Choice	
    	P3GameChoice:   
    	    CMP CurrentTurn, 2
    	    JNE P4GameChoice
    	    TEST Player3Status, 00100000B
    	    JNZ P3Paralysed
        	CALL GivePlayerMainChoice 
        	CALL PrintNewLine  
        	CALL AlternateTurn
            JMP P4GameChoice
        	P3Paralysed:
                MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '3'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisText	
        	    CALL PrintLine  
        	    AND Player3Status, 11011111B
        	    CALL AlternateTurn  
    	; Give Player 4 Choice	     		
    	P4GameChoice:  
    	    TEST Player4Status, 00100000B
    	    JNZ P4Paralysed
        	CALL GivePlayerMainChoice
        	CALL AlternateTurn
        	JMP LoopFinalBlock
        	P4Paralysed:
                MOV DX, OFFSET PlayerText
        	    CALL PrintLine
        	    MOV DX, '4'
        	    CALL PrintChar
        	    MOV DX, OFFSET ParalysisText	
        	    CALL PrintLine  
        	    AND Player4Status, 11011111B
        	    CALL AlternateTurn    		         
;        ; Apply DOT, update AliveAndHealStatus if any player is dead
;        CALL UpdateStatusOnDeath
        LoopFinalBlock:
        CALL EvaluateAttack
        CALL ApplyDOT 
        ; Check if either team is dead
        TEST AliveAndHealStatus, 11000000B
        JZ Team2Victory
        TEST AliveAndHealStatus, 00110000B
        JZ Team1Victory
        JMP GameLoop 
    
    Team1Victory:  
    	MOV DX, OFFSET Team1Won
    	CALL PrintLine 
    	JMP EndGame       	   
    Team2Victory:  
    	MOV DX, OFFSET Team2Won
		CALL PrintLine
	AskReplay:
	    MOV DX, OFFSET ReplayText 
	    CALL PrintLine
	    CALL TakeCharInput
	    CMP AL, '1'
	    JNE EndGame
	    
	    ; Resetting all game data
	    MOV Player1Status, 00000000B  
	    MOV Player2Status, 00000000B
	    MOV Player3Status, 00000000B
	    MOV Player4Status, 00000000B       
        MOV CurrentTurn, 0
        MOV AliveAndHealStatus, 11110000B
        MOV CurrentTurnStats, 00000000B
        MOV CurrentlyTargeting, 00000000B
        MOV Team1Classes, 00000000B 
        MOV Team2Classes, 00000000B  
        MOV MatchTurn, 0
        MOV TeamSynergies, 00000000B    
        JMP main   
        
        
    EndGame:
		MOV AH, 4Ch        ; DOS function to terminate program
		INT 21h            ; Exit program
code ENDS
END main
