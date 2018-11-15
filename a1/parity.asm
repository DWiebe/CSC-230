; parity.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
; Your task: To compute the value of the parity bit (or "check" bit)
; that for R16 needed for even parity. For example, if R16 is equal to
; 0b10100010, then it has three set bits, and the parity is 1 (i.e., the
; parity bit would be set). As another example, if R16 is equal to
; 0b01010110, then it has four set bits, and the parity is 0 (i.e., the
; parity bit would be cleared). In our code, simply store the correct
; value of 0 or 1 in PARITY.
;
; Your solution must count bits by using masks, bit shifts, arithmetic
; operations, logical operations, and loops.  You are *not* to construct
; lookup tables (i.e., you are not to precompute an array such value
; 0xA2 has 1 stored with it, value 0x56 has 0 stored with it, etc).
;
; In your solution you are free to modify the original value stored
; in R16.

    .cseg
    .org 0
; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

    ; You may change the number stored in R16
	LDI R16, 0b11000100
	MOV R17, R16
	
	LDI R18, 0x08 ;counter for the loop
	LDI R19, 0x00 ;counter for set bits
	
LOOP:	
	MOV R20, R17
	ANDI R20, 0x01	;looks at one bit at a time
	CPI R20, 0x01
	BRNE SKIP
	INC R19		;the bit is set, so increment the counter
SKIP:
	LSR R17		;shift right to check the next bit
	DEC R18
	CPI R18, 0
	BRNE LOOP

	ANDI R19, 0x01	;if the last bit is set, the number is odd
	STS PARITY, R19 ;otherwise the number is even

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x202
PARITY: .byte 1  ; result of computing parity-bit value for even parity
; ==== END OF "DO NOT TOUCH" SECTION ==========
