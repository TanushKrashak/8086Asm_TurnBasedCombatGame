.model small
.stack 100h

data SEGMENT
    test_health db 03h
    death_msg db 'You are dead :(', '$'  
    placeholder db 'Alive! ', '$'      
    TotalStats DB 6
    P1Stats DB 50, 100, 25, 50, 30, 50, 99
    P2Stats DB 50, 100, 25, 50, 30, 50, 20
    Crit_Message DB 'Critical Hit!', '$'
    Hit_Message DB 'Normal Hit!', '$' 
    AllDeadMsg DB 'All players are dead!', '$'
    PlayerCount DB 4  
    CurrentTurn DB 0
    AliveState DB 00000000B
    CurrentTurnStats DB 00000000B ; p4_crit, p3_crit, p2_crit, p1_crit
data ENDS

code SEGMENT     
    PrintNewline:
        MOV DL, 0Dh
        CALL PrintChar
        MOV DL, 0Ah
        CALL PrintChar    
        RET
        
    PrintLine:
        MOV ah, 09h
        INT 21h    
        CALL PrintNewline
        RET

    PrintChar:
        MOV ah, 02h
        INT 21h
        RET  
    GetTime:
        MOV AH, 2CH
        INT 21H  
        RET
        
    bGetChance:  
        ; Generic random function
        CALL GetTime   ; Load Counter and Data registers with time data
        MOV BL, [TotalStats]    ; Load length of array for based offset later   
        MOV BH, 0   ;Ensure BX is same as BL in terms of actual value
        MOV AL, [P1Stats + BX]  ;Load crit chance stat into AL
        CMP AL, DL      ; DL has hundredth of a second 
        ; Determine current player
        MOV AH, CurrentTurn 
        MOV AL, CurrentTurnStats  ; Load current turn'stats for updation
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
            MOV DX, offset Crit_Message
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
            
     WrappedIncrement:
        INC AL
        MOV AH, 0
        MOV BL, PlayerCount
        DIV BL  ; Remainder in AH is the actual turn number   
        MOV CurrentTurn, AH   ; Remainder = CurrentTurn 
        RET

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
        MOV DX, offset AllDeadMsg
        CALL PrintLine
        CALL PrintNewLine
        RET
 
main:
    MOV AX, data
    MOV ds, AX                   
    CALL bGetChance
    MOV AH, 4Ch
    INT 21h

code ENDS
END main
