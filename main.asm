.model small
.stack 100h

data SEGMENT     
;==================================================================================
; PROPERTIES & VARIABLES
;==================================================================================    	
	; Game Stats
	TotalStats   DB 6 
	MaxStamina   DB 100
	LightAttackStaminaCost DB 15
	HeavyAttackStaminaCost DB 30
	DefendStaminaCost DB 5 
	HPGainPerTurn DB 5
	STGainPerTurn DB 10  
	BurnDamage      DB 10
	BurnDuration    DB 2
	PoisonDamage    DB 5
	PoisonDuration  DB 4
	
	; Player Stats
	Player1Stats  	DB 0,0,0,0,0,0,0	
	Player2Stats  	DB 0,0,0,0,0,0,0
	Player3Stats  	DB 50,50,0,0,0,0,0
	Player4Stats  	DB 0,0,0,0,0,0,0   
	PlayersStamina	DB 100,100,100,100     ; All players' stamina stored here
	PlayersCooldown DB 0,0,0,0         ; All players' ultimate cooldown, wraps after their class' UltC   
	
	; Player Statuses
	; burn,poison,paralyse,vitality,rage,LAtk,HAtk,Ult
	Player1Status  DB 11000000B
	Player2Status  DB 11000000B
	Player3Status  DB 11000000B
	Player4Status  DB 11000000B

    PlayerCount        DB 4	; Number of players
    CurrentTurn        DB 0	; Indicate which player's turn it is, takes values between 0-3 inclusive
    AliveAndHealStatus DB 11110000B	; p4_alive, p3_alive, p2_alive, p1_alive, p4_heal,p3_heal,p2_heal,p1_heal
    CurrentTurnStats   DB 00000000B ; p4_crit, p3_crit, p2_crit, p1_crit, p4_block, p3_block, p2_block, p1_block  
    CurrentlyTargeting DB 00000000B ; p1_target, p2_target, p3_target, p4_target                 
    Team1Classes       DB 00000000B ; Higher nibble for P1 class, lower nibble for P2 class
    Team2Classes       DB 00000000B ; Higher nibble for P3 class, lower nibble for P4 class     
    
    ; Temporary Values
    DamageToBeDealt DW 0 ; used for the damage function, prevents value being discarded from GPRs
    EnemyIdentifier DB 0;

	; Class Stats (HP, MaxHP, LDmg, HDmg, Def, CC, UltC)
	KnightStats    	DB  85,  85,  20,  35,  60,  30,  3 ; Balanced, high defense
	AssassinStats  	DB  60,  60,  30,  40,  20,  50,  4 ; Lower health, high crit chance
	PyromancerStats	DB  50,  50,  20,  30,  40,  30,  4 ; Lower stats overall, but compensated by burn passive
	HealerStats    	DB  70 , 70,  15,  30,  30,  30,  4  ; LDmg deals actual damage to enemy, HDmg heals teammate
	VanguardStats  	DB  100, 100, 10,  35,  100, 0,   4  ; Max HP and Def, very low crit
	VampireStats   	DB  70,  70,  15,  25,  30,  99,  4  ; High health, low attack to account for 50% heal chance
		         
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
    MoveChoicesText DB '[1]-Light Attack',0Dh,0Ah, '[2]-Heavy Attack',0Dh,0Ah, '[3]-Defend',0Dh,0Ah, '[4]-Heal',0Dh,0Ah, '[5]-Ultimate',0Dh,0Ah, '$'
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
    UltimateCDText DB 0DH, 0AH,  'Ultimate Cooldown: ', '$'

	; In-Combat Texts
	CriticalHitText DB 'Critical Hit!',0DH, 0AH, '$'
    NormalHitText DB 'Normal Hit!',0DH, 0AH,'$'    
    DamagedText DB 'Damaged ', '$'       
    ShowEnemyHPText DB 'Enemy Currently Has ', '$'   
    LeftText DB 'HP Left!',0DH, 0AH, '$'
    ForText DB 'For ', '$'
    AllPlayersDiedText DB 'All players are dead!', '$'
    SelectTeam1TargetText DB 'Select Enemy:', 0DH, 0AH, '[1]-Player 3',0Dh,0Ah, '[2]-Player 4',0Dh,0Ah,'$'
    SelectTeam2TargetText DB 'Select Enemy:', 0DH, 0AH, '[1]-Player 1',0Dh,0Ah, '[2]-Player 2',0Dh,0Ah,'$'  
    InvalidInputText DB 'Pwease enter correct input UWU',0Dh,0Ah,'$' 
    NotEnoughStaminaText DB 'Not Enough Stamina For Action!',0Dh,0Ah,'$' 
    SelfHealText DB 'Health restored by 5', 0Dh, 0Ah, '$'   
    BurnDamageText DB ' is burning and lost 10 health!', 0Dh, 0Ah, '$'
    PoisonDamageText DB ' is poisoned and lost 5 health!', 0Dh, 0Ah, '$'      
    Team1Won DB 0Dh,0Ah,'Player 1 and 2 WIN!', '$'
    Team2Won DB 0Dh,0Ah,'Player 3 AND 4 WIN!', '$'
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
    
    ; Target an enemy player
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
    	;INT 20h 
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
        	CALL LoadPStats       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 11000000B  ; Remove redundant bits
        	CMP BL, 11000000B  ; Check if Atking P4         	   	         
        	JE P1StoreLightAtkDmgForP4
        	     MOV CurrentTurn, 2 ; Attacking P3  
        	     MOV EnemyIdentifier, 2 ; Store enemy ID  
        	     JMP FinishAttack
        	P1StoreLightAtkDmgForP4:        	
        	     MOV CurrentTurn, 3 ; Attacking P4  
        	     MOV EnemyIdentifier, 3 ; Store enemy ID    	    
        	     JMP FinishAttack	       
        P1HeavyAttack:  
        	TEST Player1Status, 00000010B ; Check if Heavy Attack 
			JZ P1Ultimate        	
        	CALL LoadPStats         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 11000000B  ; Remove redundant bits
        	CMP BL, 11000000B  ; Check if Atking P4         	   	         
        	JE P1StoreHeavyAtkDmgForP4
	    	     MOV CurrentTurn, 2 ; Attacking P3    	      
	    	     MOV EnemyIdentifier, 2 ; Store enemy ID 
	    	     JMP FinishAttack     	     
    	    P1StoreHeavyAtkDmgForP4: 
			    MOV CurrentTurn, 3 ; Attacking P3    	      
				MOV EnemyIdentifier, 3; Store enemy ID  			
    	     	JMP FinishAttack      	         	               
        P1Ultimate:       
        ; P2 Attacks	      
        P2LightAttack:
        	TEST Player2Status, 00000100B ; Check if Light Attack 
        	JZ P2HeavyAttack        	
        	CALL LoadPStats       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 00110000B  ; Remove redundant bits
        	CMP BL, 00110000B  ; Check if Atking P4         	   	         
        	JE P2StoreLightAtkDmgForP4
        	     MOV CurrentTurn, 2 ; Attacking P3  
        	     MOV EnemyIdentifier, 2 ; Store enemy ID 
        	     JMP FinishAttack 
        	P2StoreLightAtkDmgForP4:        	
        	     MOV CurrentTurn, 3 ; Attacking P4  
        	     MOV EnemyIdentifier, 3 ; Store enemy ID     	    
        	     JMP FinishAttack	       
        P2HeavyAttack:  
        	TEST Player2Status, 00000010B ; Check if Heavy Attack 
			JZ P2Ultimate        	
        	CALL LoadPStats         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00110000B  ; Remove redundant bits
        	CMP BL, 00110000B  ; Check if Atking P4         	   	         
        	JE P2StoreHeavyAtkDmgForP4
	    	     MOV CurrentTurn, 2 ; Attacking P3    	      
	    	     MOV EnemyIdentifier, 2 ; Store enemy ID 
	    	     JMP FinishAttack     	     
    	     P2StoreHeavyAtkDmgForP4: 
			    MOV CurrentTurn, 3 ; Attacking P3    	      
				MOV EnemyIdentifier, 3; Store enemy ID  
    	    	JMP FinishAttack      	         	               
        P2Ultimate:
        ; P3 Attacks	      
        P3LightAttack:
        	TEST Player3Status, 00000100B ; Check if Light Attack 
        	JZ P3HeavyAttack        	
        	CALL LoadPStats       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P3StoreLightAtkDmgForP1
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID 
        	     JMP FinishAttack  
        	P3StoreLightAtkDmgForP1:        	
        	     MOV CurrentTurn, 1 ; Attacking P2 
        	     MOV EnemyIdentifier, 1 ; Store enemy ID         	    	   
        	     JMP FinishAttack	       
        P3HeavyAttack:  
        	TEST Player3Status, 00000010B ; Check if Heavy Attack 
			JZ P3Ultimate        	
        	CALL LoadPStats         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P3StoreHeavyAtkDmgForP1
        	     MOV CurrentTurn, 1 ; Attacking P1 
        	     MOV EnemyIdentifier, 1 ; Store enemy ID  
        	     JMP FinishAttack 
        	P3StoreHeavyAtkDmgForP1:        	
        	     MOV CurrentTurn, 0 ; Attacking P2 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID      	     
        	     JMP FinishAttack     	         	               
        P3Ultimate:
        ; P4 Attacks	      
        P4LightAttack:
        	TEST Player4Status, 00000100B ; Check if Light Attack 
        	JZ P4HeavyAttack        	
        	CALL LoadPStats       	
        	MOV AL, [DI+2]  ; light atk dmg   
        	MOV AH, 0 
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting             
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn        
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P4StoreLightAtkDmgForP2
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID
        	     JMP FinishAttack   
        	P4StoreLightAtkDmgForP2:        	
        	     MOV CurrentTurn, 1 ; Attacking P2 
        	     MOV EnemyIdentifier, 1 ; Store enemy ID      	    
        	     JMP FinishAttack	       
        P4HeavyAttack:  
        	TEST Player4Status, 00000010B ; Check if Heavy Attack 
			JZ P4Ultimate        	
        	CALL LoadPStats         	      
        	MOV AL, [DI+3] ; heavy atk dmg     
        	MOV AH, 0
        	MOV DamageToBeDealt, AX
        	; Extract Enemy Number from Currently Targetting
        	MOV BL, CurrentlyTargeting                     
        	MOV DL, CurrentTurn ; Temp Store CurrentTurn
        	AND BL, 00000000B  ; Remove redundant bits
        	CMP BL, 00000000B  ; Check if Atking P1         	   	         
        	JE P4StoreHeavyAtkDmgForP2
        	     MOV CurrentTurn, 0 ; Attacking P1 
        	     MOV EnemyIdentifier, 0 ; Store enemy ID  
        	     JMP FinishAttack 
        	P4StoreHeavyAtkDmgForP2:        	
        	     MOV CurrentTurn, 1 ; Attacking P2 
        	     MOV EnemyIdentifier, 1 ; Store enemy ID     	     
        	     JMP FinishAttack 
        P4Ultimate:
        	     
        ; Finish Attack, used for Finishing Attack Logic
        FinishAttack: 
			CALL LoadPStats
			MOV CurrentTurn, DL  ; Revert Current Turn To OG Val 
			CALL DoDamage
		EvalAttack_CheckNextAttacker:	
			INC CurrentTurn    
			CMP CurrentTurn, 4 ; Check if all attacks have been done   			
			JE EndAttackCycle          
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
	    TEST CurrentTurnStats, 00010000B
	    JZ DoDamage_CheckP2Crit
	    CMP CurrentTurn, 0
	    JNZ DoDamage_CheckP2Crit
	    JMP DoDamage_PlayerHasCrit  
	    ; CurrentTurn AND CurrentTurnStats For P2
    	DoDamage_CheckP2Crit:
    		
    	DoDamage_PlayerHasCrit:
    		; Double Damage
    		MOV AX, DamageToBeDealt
    		MOV BL, 2 ; For Doubling Damage
    		MUL BL
    		MOV DamageToBeDealt, AX    	
    	MOV AX, DamageToBeDealt
		SUB [SI], AL   		
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
	         
    ; Deals DPS damage to players with poison/burn statuses
    DealDOT:
        
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
    ClampThatMf:
        LAHF
        TEST AH, 10000000B          ; Test whether sign flag is set
        JZ TestOver100
        MOV [SI], 0
        RET
        TestOver100:  
            CMP [SI], 100
            JNC ClampThatMf_End
            MOV [SI], 100
            RET                
        ClampThatMf_End:
            RET

    ; Apply Burn and Poison effects after every turn 
    ApplyDOT:  
        MOV BL, BurnDamage
        MOV BH, PoisonDamage
        TEST AliveAndHealStatus, 00010000B      ; Test whether P1 is alive
        JZ ApplyDOTP2 
        MOV SI, OFFSET Player1Stats             ; Load P1 health into SI
        TEST Player1Status, 10000000B           ; Test P1 burn bit
        JZ PoisonCheckP1         
        SUB [SI], BL                            ; Apply burn damage to P1 
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
            MOV DX, OFFSET PlayerText
            CALL PrintLine
            MOV DL, '1'
            CALL PrintChar
            MOV DX, OFFSET PoisonDamageText
            CALL PrintLine      
        ApplyDOTP2:       
            CALL ClampThatMf                            ; Clamp P1's health if needed                                 
            TEST AliveAndHealStatus, 00100000B          ; Test whether P2 is alive
            JZ ApplyDOTP3
            MOV SI, OFFSET Player2Stats                 ; Load P2 health into SI
            TEST Player2Status, 10000000B               ; Test P2 burn bit
            JZ PoisonCheckP2
            SUB [SI], BL                                ; Apply burn damage to P2   
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
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '2'
                CALL PrintChar
                MOV DX, OFFSET PoisonDamageText
                CALL PrintLine                    
        ApplyDOTP3:
            CALL ClampThatMf                          ; Clamp P2's health if needed
            TEST AliveAndHealStatus, 01000000B        ; Test whether P3 is alive
            JZ ApplyDOTP4
            MOV SI, OFFSET Player3Stats               ; Load P3 health into SI
            TEST Player3Status, 10000000B             ; Test P3 burn bit
            JZ PoisonCheckP3
            SUB [SI], BL                              ; Apply burn damage to P3 
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
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '3'
                CALL PrintChar
                MOV DX, OFFSET PoisonDamageText
                CALL PrintLine
        ApplyDOTP4:   
            CALL ClampThatMf                          ; Clamp P3's health if needed
            TEST AliveAndHealStatus, 10000000B        ; Test whether P4 is alive
            JZ ApplyDOT_Final
            MOV SI, OFFSET Player4Stats               ; Load P4 health into SI
            TEST Player4Status, 10000000B             ; Test P4 burn bit
            JZ PoisonCheckP4
            SUB [SI], BL                              ; Apply burn damage to P4 
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
                MOV DX, OFFSET PlayerText
                CALL PrintLine
                MOV DL, '4'
                CALL PrintChar
                MOV DX, OFFSET PoisonDamageText
                CALL PrintLine
        ApplyDOT_Final:
            CALL ClampThatMf                            ; Clamp P4's health if needed
            RET    
	; Load system time into CX and DX (CH: Hour, CL: Minute, DH: Second, DL: 1/100th of a second)
	GetTime:
        MOV AH, 2CH
        INT 21H  
        RET
        
    ; Loads current player's stats into DI
    LoadPStats:
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
                 
	; Generic random function, expects chance in AL. Result in CF
	GetChance:
	    CALL GetTime   ; Load Counter and Data registers with time data
        MOV BL, TotalStats    ; Load length of array for based offset later   
        MOV BH, 0   ;Ensure BX is same as BL in terms of actual value
        CMP AL, DL      ; DL has hundredth of a second
        RET          
        
    ; Updates critical bit in CurrentTurnStatus for players 
    ; USES DX, AH and AL
    UpdateCrit:
        ; Determine current player
        CALL LoadPStats                  
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
        JE WrappedIs4
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
        MOV AL, CurrentTurn
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
	        JMP Healer_Final  
	        CheckP2Pyromancer:        
    	        CMP CurrentTurn, 1
    	        JNE CheckP3Pyromancer
    	        OR Team1Classes, 00000010B
    	        JMP Healer_Final
    	    CheckP3Pyromancer:
    	        CMP CurrentTurn, 2
    	        JNE MakeP4Pyromancer
    	        OR Team2Classes, 00100000B
    	        JMP Healer_Final
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
    LoadPlayerStats:           
        MOV CX, 7                    ; Loop counter (7 elements)        
	    LoadPlayerStatsLoop:
	        MOV AL, [DI]    
	        MOV [SI], AL    
	        INC SI          
	        INC DI          
	        LOOP LoadPlayerStatsLoop  ; Repeat until CX = 0
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
    	JNE GivePlayerMainChoice_InvalidInput    	
    	RET  
    	; Light Attack 	   
    	LightAttack:    	   
    		MOV DH, LightAttackStaminaCost 
    	    ; Change Status Indicating which type of attack 
			; was chosen by the player, it is done by updating
    	    ; the 3rd last bit on the PlayerXStatus vars
    	    CMP CurrentTurn, 0
    	    JNE LightMChoice_1        	    
    	    CMP [PlayersStamina+0], DH ; Check if has 15 stamina
    	    JC NotEnoughStamina   	                      
    	    SUB [PlayersStamina+0], DH ; Deduct Stamina  
    	    OR Player1Status, 00000100B
    	    JMP AttackFinal
    	    LightMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE LightMChoice_2 
	    	    CMP [PlayersStamina+1], DH ; Check if has 15 stamina  	    	    
	    	    JC NotEnoughStamina           	                       
	    	    SUB [PlayersStamina+1], DH ; Deduct Stamina
        	    OR Player2Status, 00000100B
        	    JMP AttackFinal
            LightMChoice_2:
                CMP CurrentTurn, 2
                JNE LightMChoice_3
	    	    CMP [PlayersStamina+2], DH ; Check if has 15 stamina
	    	    JC NotEnoughStamina          
	    	    SUB [PlayersStamina+2], DH ; Deduct Stamina         
        	    OR Player3Status, 00000100B 
                JMP AttackFinal
            LightMChoice_3:        	
	    	    CMP [PlayersStamina+3], DH ; Check if has 15 stamina
	    	    JC NotEnoughStamina 
	    	    SUB [PlayersStamina+3], DH ; Deduct Stamina                  
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
    	    CMP [PlayersStamina+0], DH ; Check if has 30 stamina
    	    JC NotEnoughStamina 	 
    	    SUB [PlayersStamina+0], DH ; Deduct Stamina   
    	    OR Player1Status, 00000010B
    	    JMP AttackFinal
    	    HeavyMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE HeavyMChoice_2 
        	    CMP [PlayersStamina+1], DH ; Check if has 30 stamina
				JC NotEnoughStamina         
				SUB [PlayersStamina+1], DH ; Deduct Stamina   
        	    OR Player2Status, 00000010B
        	    JMP AttackFinal
            HeavyMChoice_2:
                CMP CurrentTurn, 2
                JNE HeavyMChoice_3 
        	    CMP [PlayersStamina+2], DH ; Check if has 30 stamina
				JC NotEnoughStamina  
				SUB [PlayersStamina+2], DH ; Deduct Stamina                  
        	    OR Player3Status, 00000010B 
                JMP AttackFinal
            HeavyMChoice_3:    
        	    CMP [PlayersStamina+3], DH ; Check if has 30 stamina
				JC NotEnoughStamina 
				SUB [PlayersStamina+3], DH ; Deduct Stamina       	    
        	    OR Player4Status, 00000011B
        	    JMP AttackFinal
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
    	    OR AliveAndHealStatus, 00000001B;
    	    JMP HealFinal
    	    HealMChoice_1:
        	    CMP CurrentTurn, 1
        	    JNE HealMChoice_2
        	    MOV SI, OFFSET Player2Stats 
        	    OR AliveAndHealStatus, 00000010B;
        	    JMP HealFinal
            HealMChoice_2:
                CMP CurrentTurn, 2
                JNE HealMChoice_3
        	    MOV SI, OFFSET Player3Stats
        	    OR AliveAndHealStatus, 00000100B; 
                JMP HealFinal
            HealMChoice_3:
        	    MOV SI, OFFSET Player4Stats 
        	    OR AliveAndHealStatus, 00001000B;
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
    	; Attack Chosen, In case some common finishing
    	; logic is required         
    	AttackFinal: 
    		CALL TargetEnemy
    		CALL PrintNewLine 
    	    RET      
    	; Not Enough Stamina             
 		NotEnoughStamina:
 			MOV DX, OFFSET NotEnoughStaminaText
 			CALL PrintLine
 			JMP GivePlayerMainChoice
 		; Invalid INput
    	GivePlayerMainChoice_InvalidInput:
    	    MOV DX, OFFSET InvalidInputText
    	    CALL PrintLine
    	    JMP GivePlayerMainChoice   
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
					;====; 
					; COMMENTED OUT FOR DEBUGGING, NO NEED TO KEEP ON SELECTING CLASSES OVER AND OVER!!!!!
					;====;
;    MainP1ClassSelection:          
;    	CALL PrintPlayerName    
;    	CALL PrintNewLine   		          
;        MOV DX, OFFSET PrintPlayerStatsText  
;    	CALL PrintLine        
;    	; Class Selection
;    	CALL SelectPlayerClass  
;    	CMP BL, 'X'
;    	JE MainP1ClassSelection  
;        MOV SI, OFFSET Player1Stats
;       	CALL LoadPlayerStats    
;       	; Print Stats
;       	MOV SI, OFFSET Player1Stats
;        CALL PrintPlayerStats      
;        CALL PrintNewLine 
;        CALL PrintNewLine   
;    
;    ; Print P2 MSG  
;    MainP2ClassSelection:
;        CALL UpdateCurrentTurn
;    	CALL PrintPlayerName    
;    	CALL PrintNewLine      	
;        MOV DX, OFFSET PrintPlayerStatsText
;    	CALL PrintLine        
;    	; Class Selection
;    	CALL SelectPlayerClass	 
;    	CMP BL, 'X'
;    	JE MainP2ClassSelection 
;        MOV SI, OFFSET Player2Stats
;       	CALL LoadPlayerStats    
;    	; Print Stats 
;    	MOV SI, OFFSET Player2Stats
;        CALL PrintPlayerStats    
;        CALL PrintNewLine 
;        CALL PrintNewLine   
;       
; 	; Print P3 MSG
; 	MainP3ClassSelection:
;        CALL UpdateCurrentTurn
;    	CALL PrintPlayerName    
;    	CALL PrintNewLine      	
;        MOV DX, OFFSET PrintPlayerStatsText
;    	CALL PrintLine        
;    	; Class Selection
;    	CALL SelectPlayerClass	   
;    	CMP BL, 'X'
;    	JE MainP3ClassSelection 
;        MOV SI, OFFSET Player3Stats
;       	CALL LoadPlayerStats    
;    	; Print Stats 
;    	MOV SI, OFFSET Player3Stats
;        CALL PrintPlayerStats    
;        CALL PrintNewLine 
;        CALL PrintNewLine 
;    
; 	; Print P4 MSG    
; 	MainP4ClassSelection:
;        CALL UpdateCurrentTurn
;    	CALL PrintPlayerName    
;    	CALL PrintNewLine      	
;        MOV DX, OFFSET PrintPlayerStatsText
;    	CALL PrintLine        
;    	; Class Selection
;    	CALL SelectPlayerClass	
;    	CMP BL, 'X'
;    	JE MainP4ClassSelection
;        MOV SI, OFFSET Player4Stats
;       	CALL LoadPlayerStats    
;    	; Print Stats 
;    	MOV SI, OFFSET Player4Stats
;        CALL PrintPlayerStats    
;        CALL PrintNewLine 
;        CALL PrintNewLine
                        
	; TEMPORARILY CLASS ASSIGNMENT ONLY!!!!  
	; p1 	
	MOV DI, OFFSET VampireStats
	MOV SI, OFFSET Player1Stats
	CALL LoadPlayerStats
		; p2
	CALL UpdateCurrentTurn
	MOV DI, OFFSET AssassinStats
	MOV SI, OFFSET Player2Stats
	CALL LoadPlayerStats                        
    CALL UpdateCurrentTurn   
    ; p3
	MOV DI, OFFSET AssassinStats
	MOV SI, OFFSET Player3Stats
	CALL LoadPlayerStats                        
    CALL UpdateCurrentTurn  
        ; p4
	MOV DI, OFFSET AssassinStats 	
	MOV SI, OFFSET Player4Stats
	CALL LoadPlayerStats                        
    CALL UpdateCurrentTurn 
    
    GameLoop:              
    	; CHOICES For Round 1 (Should be moved to a function)    (Not moving this to a function yet, you might have had some more things planned for it which I don't know)                      	
    	; Give Player 1 Choice 
    	CMP CurrentTurn, 0
    	JNE P2GameChoice
    	CALL GivePlayerMainChoice 
    	CALL PrintNewLine	 
    	; Give Player 2 Choice	 
    	CALL AlternateTurn	
    	P2GameChoice:
    	    CMP CurrentTurn, 1
    	    JNE P3GameChoice
        	CALL GivePlayerMainChoice
        	CALL PrintNewLine    	
    		CALL AlternateTurn  
    	; Give Player 3 Choice	
    	P3GameChoice:
        	CALL GivePlayerMainChoice 
        	CALL PrintNewLine   
        	CALL AlternateTurn 
    	; Give Player 4 Choice	     		
    	P4GameChoice:
        	CALL GivePlayerMainChoice
        	CALL AlternateTurn 
        ; All alive players have chosen their moves, begin evaluation         
    	CALL EvaluateAttack        
        
;        ; Apply DOT, update AliveAndHealStatus if any player is dead
;        CALL ApplyDOT 
;        CALL UpdateStatusOnDeath
        
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
    EndGame:
		MOV AH, 4Ch        ; DOS function to terminate program
		INT 21h            ; Exit program
code ENDS
END main
