CODE SEGMENT
ASSUME CS:CODE
ORG 2000H


START:

MOV DX , 0FF2BH
MOV AL , 90H
OUT DX , AL

MOV DX , 8000H
MOV AL ,0
OUT DX , AL


MOV BL , 5
LP:

MOV CX , 0FFFFH
DELAY2:
LOOP DELAY2

MOV DX , 8000H
MOV AL ,BL
OUT DX , AL

MOV DX , 0FF28H
IN AL , DX

AND AL , 03H
CMP AL , 03H
JE LP

CMP AL , 02H
JE INCREMENT
CMP AL , 01H
JE DECR
JMP LP
DECR:
CMP BL,0
JE LP

SUB BL , 5


JMP LP



INCREMENT:
CMP BL,255
JE LP
ADD BL , 5
JMP LP









END START
CODE ENDS