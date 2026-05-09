; FILEIO.ASM — Leaderboard persistence to SCORES.DAT
.MODEL SMALL
.DATA
    INCLUDE SHARED.INC

    SCORES_FILE     DB "SCORES.DAT", 0
    LEADERBOARD     DB LB_MAX_ENTRIES * LB_ENTRY_SIZE DUP (0)

.CODE
    PUBLIC FILE_LOAD_SCORES, FILE_SAVE_SCORES

;---------------------------------------------------------------
; FILE_LOAD_SCORES — Load leaderboard from SCORES.DAT.
; If file doesn't exist, initializes leaderboard to zeros.
; Preserves: AX, BX, CX, DX, SI, DI
;---------------------------------------------------------------
FILE_LOAD_SCORES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Set DS to @DATA
    MOV  AX, @DATA
    MOV  DS, AX

    ; Open SCORES.DAT for reading
    MOV  AH, 3Dh         ; Open file
    MOV  AL, 0           ; Read-only
    LEA  DX, SCORES_FILE
    INT  21h
    JC   FLS_NO_FILE     ; Carry set if error (file not found)

    ; File opened successfully, AX = file handle
    MOV  BX, AX          ; BX = handle

    ; Read up to 40 bytes (5 entries * 8 bytes)
    MOV  AH, 3Fh         ; Read from file
    MOV  CX, LB_MAX_ENTRIES * LB_ENTRY_SIZE  ; 40 bytes
    LEA  DX, LEADERBOARD
    INT  21h

    ; Close file
    MOV  AH, 3Eh
    INT  21h

    JMP  FLS_DONE

FLS_NO_FILE:
    ; File doesn't exist, initialize leaderboard to zeros (already done)

FLS_DONE:
    POP  DI
    POP  SI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
FILE_LOAD_SCORES ENDP

;---------------------------------------------------------------
; FILE_SAVE_SCORES — Save leaderboard to SCORES.DAT.
; Creates/truncates the file and writes the data.
; Preserves: AX, BX, CX, DX, SI, DI
;---------------------------------------------------------------
FILE_SAVE_SCORES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Set DS to @DATA
    MOV  AX, @DATA
    MOV  DS, AX

    ; Create/truncate SCORES.DAT
    MOV  AH, 3Ch         ; Create file
    MOV  CX, 0           ; Normal attributes
    LEA  DX, SCORES_FILE
    INT  21h
    JC   FSS_ERROR       ; If error, skip

    ; File created, AX = handle
    MOV  BX, AX

    ; Write 40 bytes
    MOV  AH, 40h         ; Write to file
    MOV  CX, LB_MAX_ENTRIES * LB_ENTRY_SIZE  ; 40 bytes
    LEA  DX, LEADERBOARD
    INT  21h

    ; Close file
    MOV  AH, 3Eh
    INT  21h

FSS_ERROR:
    POP  DI
    POP  SI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
FILE_SAVE_SCORES ENDP

END</content>

