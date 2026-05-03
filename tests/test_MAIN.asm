; tests/test_MAIN.asm — Smoke test for MAIN module
; Day 1: Validates the build pipeline with a hello-world.

.MODEL SMALL
.STACK 1024

.DATA
    HELLO_MSG DB 'HELLO$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AH, 09h
    LEA DX, HELLO_MSG
    INT 21h

    MOV AH, 4Ch
    MOV AL, 0
    INT 21h
MAIN ENDP

END MAIN
