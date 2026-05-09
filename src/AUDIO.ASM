; AUDIO.ASM — PC speaker tone generation for continuous audio based on difficulty
.MODEL SMALL
.DATA
    INCLUDE SHARED.INC

    ; Pattern data: freq, duration_ms pairs, terminated by 0
    ; Single pattern for all difficulties (fixed speed)
    CONTINUOUS_PATTERN DW 440, 500, 660, 500, 0

.CODE
    PUBLIC SND_PLAY_PATTERN, SND_SILENCE, SND_PLAY_CONTINUOUS

;---------------------------------------------------------------
; SND_PLAY_TONE — Start playing a continuous tone.
; In: BX = frequency in Hz (e.g., 440 = A)
; Preserves: AX, BX, CX, DX
;---------------------------------------------------------------
SND_PLAY_TONE PROC
    PUSH AX
    PUSH BX
    PUSH DX

    ; Check for zero frequency
    OR   BX, BX
    JZ   SPT_SKIP

    ; Compute divisor = 1193180 / frequency
    MOV  DX, 12h          ; 1193180 = 0012_34DCh
    MOV  AX, 34DCh
    DIV  BX               ; AX = divisor

    ; Program PIT channel 2 (control register)
    PUSH AX
    MOV  AL, 0B6h         ; channel 2, both bytes, mode 3 (square wave)
    OUT  43h, AL
    POP  AX
    OUT  42h, AL          ; low byte
    MOV  AL, AH
    OUT  42h, AL          ; high byte

    ; Enable speaker (bits 0-1 of port 61h)
    IN   AL, 61h
    OR   AL, 03h
    OUT  61h, AL

SPT_SKIP:
    POP  DX
    POP  BX
    POP  AX
    RET
SND_PLAY_TONE ENDP

;---------------------------------------------------------------
; SND_SILENCE — Stop the speaker.
; Preserves: AX
;---------------------------------------------------------------
SND_SILENCE PROC
    PUSH AX
    IN   AL, 61h
    AND  AL, 0FCh         ; clear bits 0-1
    OUT  61h, AL
    POP  AX
    RET
SND_SILENCE ENDP

;---------------------------------------------------------------
; SND_DELAY — Busy-wait for CX milliseconds.
; Uses INT 15h AH=86h for microsecond delay.
; Preserves: AX, CX, DX
;---------------------------------------------------------------
SND_DELAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    ; INT 15h, AH=86h: CX:DX = microseconds to wait
    ; Convert milliseconds in CX to microseconds
    MOV  AX, CX
    MOV  DX, 1000
    MUL  DX               ; DX:AX = CX * 1000 = microseconds
    MOV  CX, DX
    MOV  DX, AX
    MOV  AH, 86h
    INT  15h
    POP  DX
    POP  CX
    POP  AX
    RET
SND_DELAY ENDP

;---------------------------------------------------------------
; SND_PLAY_PATTERN — Play a pattern of (freq, duration_ms) pairs.
; In: DS:SI = pattern data. Terminated by freq=0.
; Preserves: AX, BX, CX, SI
;---------------------------------------------------------------
SND_PLAY_PATTERN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

SPP_LOOP:
    MOV  BX, [SI]          ; frequency
    OR   BX, BX
    JZ   SPP_DONE
    ADD  SI, 2
    MOV  CX, [SI]          ; duration
    ADD  SI, 2

    CALL SND_PLAY_TONE
    CALL SND_DELAY
    CALL SND_SILENCE

    ; Small gap between tones
    MOV  CX, 30
    CALL SND_DELAY

    JMP  SPP_LOOP

SPP_DONE:
    CALL SND_SILENCE
    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
SND_PLAY_PATTERN ENDP

;---------------------------------------------------------------
; SND_PLAY_CONTINUOUS — Play a continuous looping pattern.
; In: BX = difficulty (ignored, single pattern for all modes)
; Plays one cycle of the pattern, caller should loop for continuous.
; Preserves: AX, BX, SI
;---------------------------------------------------------------
SND_PLAY_CONTINUOUS PROC
    PUSH AX
    PUSH BX
    PUSH SI

    ; Set DS to @DATA
    MOV  AX, @DATA
    MOV  DS, AX

    ; Always use the same pattern regardless of difficulty
    LEA  SI, CONTINUOUS_PATTERN
    CALL SND_PLAY_PATTERN

    POP  SI
    POP  BX
    POP  AX
    RET
SND_PLAY_CONTINUOUS ENDP

END
