CODE SEGMENT
ASSUME CS:CODE
ORG 2000H
;-------------------------------------------all the macros we need(functions)--------------------------------------

STORE_FUN MACRO    ;THIS FUNCTION WILL STORE THE NUMBERS FROM STACK AND STORE IT TO DX (3 digits)
MOV BX , 1
MOV DX , 0
POP AX
MUL BX
ADD DX , AX
POP AX
PUSH DX
PUSH AX
MOV AX , 10
MUL BX
MOV BX , AX
POP AX
MOV DX , 0
MUL BX
POP DX
ADD AX , DX
POP DX
PUSH AX
PUSH DX
MOV AX , 10
MUL BX
MOV BX , AX
POP AX
MOV DX , 0
MUL BX
POP DX
ADD AX , DX
PUSH AX
POP DX
ENDM

DELAY_FUN MACRO
LOCAL DELAY_LP
POP DX  ; THE DELAY SPEED WILL BE STORED IN DX
PUSH CX
PUSH DX
MOV CX , DX
DELAY_LP:
LOOP DELAY_LP
POP DX
POP CX
PUSH DX
ENDM



ANGLE_FUN MACRO ; CX = STEPS | STEPS BASED ON THE ANGLE WILL BE STORED IN CX | STEPS = (x*512)/360
MOV AX , 512
MUL DX
MOV CX , 360
DIV CX
MOV CX , AX
ENDM

;-----------------------------------------------------------------------------------------------------------------
;------------------------------------- CONFIGURATION 8279 | 8255 ----------------------------------------------------

START:

MOV DX , 8001H ;CONFIGURING THE 8279 IC

MOV AL , 00H ; THE MODE
OUT DX , AL

MOV AL , 32H ; THE CLK
OUT DX , AL

MOV AL , 0DFH ; CREAL ALL
OUT DX , AL

MOV CX , 0FFFH
DELAY:
LOOP DELAY


MOV DX , 0FF2BH ; 8255 PROGRAMMING (A OUTPUT)
MOV AL , 80H
OUT DX , AL
;-----------------------------------------------------------------------------------------------------------------------

MOV CL , 85H  ;COUNTER FOR THE WANTED 7-SEGMENT-DISPLAY


RETURN:
MOV SI , OFFSET ARRAY1
MOV DI , OFFSET ARRAY2
MOV CH , 00H  ;COUNTER FOR THE WANTED NUMBER

READ:
MOV DX , 8001H  ;Read from 8279 IC
IN AL , DX
AND AL , 07H
CMP AL , 00H	;Nothing is pressed in the 3 least segnificant bits = nothing is pressed from the keyboared 
JE READ

MOV DX , 8000H
IN AL , DX
AND AL , 3FH

;LOOP FOR CHECKING WHAT KEY WAS PRESSED
READ1:
CMP AL , [DI]
JE DISPLAY
INC SI
INC DI
INC CH
CMP [SI] , 00H
JE RETURN
JMP READ1

;DIS&Store it in the stack:
DISPLAY:
CMP CL , 82H
JE DIS_SPEED
MOV DX , 8001H  ;8279 Config Port
MOV AL , CL		;Choosing what 7-segment to display on
OUT DX , AL
DEC CL

MOV DX , 8000H
MOV AL , [SI]
OUT DX , AL

;NOW WE WILL HAVE THE VALUE OF NUMBER BY DOING THE XLAT , AL = ARRAY[CH]
MOV AL , CH
MOV BX , OFFSET NUMBER_ARRAY
XLAT
MOV AH , 00H
PUSH AX
JMP RETURN


DIS_SPEED:
MOV DX , 8001H
MOV AL , CL
OUT DX , AL
DEC CL

MOV AL , 7FH   ; DISPLAYING _ ON 7 SEGMENT DISPLAY 83H
MOV DX , 8000H
OUT DX , AL

MOV DX , 8001H
MOV AL , CL
OUT DX , AL


MOV AL , [SI]
MOV DX , 8000H
OUT DX , AL
;-----------------------------------------------------------------------------------------------------------------------------------------------
;LET'S NOT FORGET THE CH IS NOW THE VALUE FOR THE ARRAY3 FOR THE SPEED WE NEED |1-9|
;--------------------------------------------- done displaying the angle with the speed --------------------------------------------------------

STORE:

STORE_FUN  ; THE VALUE OF THE STEPS IS NOW STORED IN DX
PUSH DX
;SPEED = NUMBER_ARRAY[CH]
MOV AL , CH
MOV BX , OFFSET NUMBER_ARRAY
XLAT
MOV AH , 00H
;------------------------ AX = SPEED OF THE MOTOR (1-9)------
;NOTICE THAT WHEN WE DIVIDE AX/BX THE REMINDER WILL BE STORED IN DX, WHICH WILL MAKE THE WHOLE PROCESS WRONG BECAUSE DX = THE VALUE OF THE ANGLE :)
;ALSO WE NEED TO PUT 0 IN IT BEFORE DIVIDING

MOV BX , AX
MOV AX , 0FFFFH  	; THE SPEED => AX = 0FFFFH / 1-9(SPEED)
MOV DX , 0
DIV BX				; AX = 0FFFFH / SPEED
POP DX
PUSH AX  	; THE DELAY (SPEED) WILL BE PUSHED TO STACK
ANGLE_FUN 	; CX = HOW MANY STEPS SHOULD I MOVE ||| STEPS = (X*512)/360


EXECUTE:
MOV SI , OFFSET CUMULATIVE_STEP
MOV AX , [SI]
CMP AX , CX
JA LEFT
JB RIGHT
JMP START


LEFT:
MOV [SI] , CX
SUB AX , CX
MOV CX , AX
MOV BL , 0EEH
LPP1:
ROR BL , 1
MOV DX , 0FF28H
MOV AL , BL
OUT DX , AL
DELAY_FUN
LOOP LPP1
JMP START


RIGHT:
MOV [SI] , CX
SUB CX , AX
MOV BL , 0EEH
LPP2:
ROL BL , 1
MOV DX , 0FF28H
MOV AL , BL
OUT DX , AL
DELAY_FUN
LOOP LPP2
JMP START


ARRAY1 DB 0CH , 9FH , 4AH , 0BH , 99H , 29H , 28H , 8FH , 08H , 09H , 00H;, 88H , 38H , 6CH , 1AH , 68H , 0E8H
ARRAY2 DB 09H , 01H , 11H , 21H , 08H , 18H , 28H , 0H , 10H , 20H , 00H;, 30H , 38H , 31H , 39H , 29H , 19H
NUMBER_ARRAY DB 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
CUMULATIVE_STEP DW 0


END START
CODE ENDS
