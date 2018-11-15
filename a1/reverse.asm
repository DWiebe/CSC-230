; reverse.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: To reverse the bits in the word IN1:IN2 and to store the
; result in OUT1:OUT2. For example, if the word stored in IN1:IN2 is
; 0xA174, then reversing the bits will yield the value 0x2E85 to be
; stored in OUT1:OUT2.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
   
    ;10100001 01110100
    ;00101110 10000101
   
   
    ; These first lines store a word into IN1:IN2. You may
    ; change the value of the word as part of your coding and
    ; testing.
    ;
    ldi R16, 0xA1
    sts IN1, R16
    ldi R16, 0x74
    sts IN2, R16
	LDI R19, 0x00
	LDI R20, 0x00
	
	
	
	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x80
	AND R16, R18
	AND R17, R18

	LDI R21, 0x07
LOOP1:
	LSR R16
	LSR R17
	DEC R21
	BRNE LOOP1
	
	OR  R19, R16
	OR  R20, R17


	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x40
	AND R16, R18
	AND R17, R18

	LDI R21, 0x05
LOOP2:
	LSR R16
	LSR R17
	DEC R21
	BRNE LOOP2
	
	OR  R19, R16
	OR  R20, R17	


	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x20
	AND R16, R18
	AND R17, R18

	LDI R21, 0x03
LOOP3:
	LSR R16
	LSR R17
	DEC R21
	BRNE LOOP3
	
	OR  R19, R16
	OR  R20, R17


	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x10
	AND R16, R18
	AND R17, R18

	LDI R21, 0x01
LOOP4:
	LSR R16
	LSR R17
	DEC R21
	BRNE LOOP4
	
	OR  R19, R16
	OR  R20, R17


	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x08
	AND R16, R18
	AND R17, R18

	LDI R21, 0x01
LOOP5:
	LSL R16
	LSL R17
	DEC R21
	BRNE LOOP5
	
	OR  R19, R16
	OR  R20, R17


	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x04
	AND R16, R18
	AND R17, R18

	LDI R21, 0x03
LOOP6:
	LSL R16
	LSL R17
	DEC R21
	BRNE LOOP6
	
	OR  R19, R16
	OR  R20, R17

	
	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x02
	AND R16, R18
	AND R17, R18

	LDI R21, 0x05
LOOP7:
	LSL R16
	LSL R17
	DEC R21
	BRNE LOOP7
	
	OR  R19, R16
	OR  R20, R17
	

	LDS R16, IN1
	LDS R17, IN2
	LDI R18, 0x01
	AND R16, R18
	AND R17, R18

	LDI R21, 0x07
LOOP8:
	LSL R16
	LSL R17
	DEC R21
	BRNE LOOP8
	
	OR  R19, R16
	OR  R20, R17









	STS OUT1, R20	;set the outputs
	STS OUT2, R19

	DONE: RJMP DONE



; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x200
IN1:	.byte 1
IN2:	.byte 1
OUT1:	.byte 1
OUT2:	.byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
