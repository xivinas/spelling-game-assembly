; tests/test_STATE.asm — Smoke test for STATE module
; Validates GAME_TICK dispatches to correct screen handler for each state.

.MODEL SMALL
.STACK 1024

.DATA
    INCLUDE SHARED.INC
    PUBLIC CURRENT_STATE
    CURRENT_STATE DB STATE_TITLE

    MSG_STATE   DB 'State: $'
    MSG_OK      DB ' OK', 0Dh, 0Ah, '$'
    MSG_QUIT    DB 'State QUIT: RET (no call) OK', 0Dh, 0Ah, '$'

.CODE
    EXTRN GAME_TICK:PROC

    ; --- Stub screen handlers ---
    ; Each prints its state digit then returns.
    PUBLIC SCR_TITLE_RUN, SCR_NAME_RUN, SCR_DIFF_RUN
    PUBLIC SCR_INSTR_RUN, SCR_ROUND_RUN, SCR_JUDGE_RUN, SCR_END_RUN

SCR_TITLE_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '0'
    INT 21h
    POP DX
    POP AX
    RET
SCR_TITLE_RUN ENDP

SCR_NAME_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '1'
    INT 21h
    POP DX
    POP AX
    RET
SCR_NAME_RUN ENDP

SCR_DIFF_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '2'
    INT 21h
    POP DX
    POP AX
    RET
SCR_DIFF_RUN ENDP

SCR_INSTR_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '3'
    INT 21h
    POP DX
    POP AX
    RET
SCR_INSTR_RUN ENDP

SCR_ROUND_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '4'
    INT 21h
    POP DX
    POP AX
    RET
SCR_ROUND_RUN ENDP

SCR_JUDGE_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '5'
    INT 21h
    POP DX
    POP AX
    RET
SCR_JUDGE_RUN ENDP

SCR_END_RUN PROC
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, '6'
    INT 21h
    POP DX
    POP AX
    RET
SCR_END_RUN ENDP

    ; --- Test main ---
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Test state 0 (TITLE)
    MOV CURRENT_STATE, STATE_TITLE
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 1 (NAME)
    MOV CURRENT_STATE, STATE_NAME
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 2 (DIFF)
    MOV CURRENT_STATE, STATE_DIFF
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 3 (INSTR)
    MOV CURRENT_STATE, STATE_INSTR
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 4 (ROUND)
    MOV CURRENT_STATE, STATE_ROUND
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 5 (JUDGE)
    MOV CURRENT_STATE, STATE_JUDGE
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 6 (END)
    MOV CURRENT_STATE, STATE_END
    LEA DX, MSG_STATE
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK
    LEA DX, MSG_OK
    MOV AH, 09h
    INT 21h

    ; Test state 7 (QUIT) — should fall through, no handler called
    MOV CURRENT_STATE, STATE_QUIT
    LEA DX, MSG_QUIT
    MOV AH, 09h
    INT 21h
    CALL GAME_TICK

    MOV AH, 4Ch
    MOV AL, 0
    INT 21h
MAIN ENDP

END MAIN
