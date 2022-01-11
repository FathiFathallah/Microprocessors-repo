.MODEL SMALL


STRCAT MACRO STRING1 , STRING2
LOCAL LAST , COUNTER , TRANSFERING_DATA , RESET_SI
PUSH AX
PUSH CX

MOV DI , OFFSET STRING1         ; DESTINATION INDEX
MOV SI , OFFSET STRING2         ; SOURCE INDEX
MOV CX , 0

LAST:
MOV AL , [DI]
CMP AL , 00H
JE COUNTER
INC DI
JMP LAST

COUNTER:
MOV AL , [SI]
CMP AL , 00H
JE RESET_SI
INC SI
INC CX
JMP COUNTER

RESET_SI:
MOV SI , OFFSET STRING2

TRANSFERING_DATA:
MOV AL , [SI]
MOV [DI] , AL
INC SI
INC DI
LOOP TRANSFERING_DATA


POP CX
POP AX
ENDM

;//////////////////////////////////

PRINT MACRO STRING
LOCAL PRINTING , PRINTED
PUSH AX
PUSH DX

MOV SI , OFFSET STRING
PRINTING:
MOV DL , [SI]
CMP DL , 00H
JE PRINTED
MOV AH , 02H
INT 21H
INC SI
JMP PRINTING

PRINTED:
POP DX
POP AX
ENDM

;//////////////////////////////////

PRINTLINE MACRO
MOV DL , 0AH
MOV AH , 02H
INT 21H
ENDM

;//////////////////////////////////


.DATA
BEFORE DB "BEFORE CONCATENATION :" , 0 
AFTER DB "AFTER CONCATENATION :" , 0 
STR1 DB "Najah.edu:" , 0
STR2 DB " Microprocessor-10636322" , 0


.CODE
MOV AX , @DATA
MOV DS , AX


PRINT BEFORE
PRINTLINE
PRINT STR1                                 ; PRINT STR1 BEFORE CONCATENATION
PRINTLINE

STRCAT STR1,STR2                           ; NOW WE CALL THE MACRO OF CONCATENATION

PRINT AFTER                                ; PRINT THEM AFTER CONCATENATION 
PRINTLINE
PRINT STR1
PRINTLINE


STRCAT STR2,BEFORE
PRINT STR2 

.EXIT
END