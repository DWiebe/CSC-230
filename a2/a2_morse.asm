; a2_morse.asm
; CSC 230: Spring 2018
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2018-Feb-10)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are 
; "DO NOT TOUCH" sections. You are *not* to modify the lines
; within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; I have added for this assignment an additional kind of section
; called "TOUCH CAREFULLY". The intention here is that one or two
; constants can be changed in such a section -- this will be needed
; as you try to test your code on different messages.
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

.include "m2560def.inc"

.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0
	; Copy test encoding (of SOS) into SRAM
	;
	ldi ZH, high(TESTBUFFER)
	ldi ZL, low(TESTBUFFER)
	ldi r16, 0x30
	st Z+, r16
	ldi r16, 0x37
	st Z+, r16
	ldi r16, 0x30
	st Z+, r16
	clr r16
	st Z, r16

	; initialize run-time stack
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16

	; initialize LED ports to output
	ldi r17, 0xff
	sts S_DDRB, r17
	sts S_DDRL, r17

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION **** 
; ***************************************************

	; If you're not yet ready to execute the
	; encoding and flashing, then leave the
	; rjmp in below. Otherwise delete it or
	; comment it out.

	;rjmp stop

    ; The following seven lines are only for testing of your
    ; code in part B. When you are confident that your part B
    ; is working, you can then delete these seven lines. 
	;ldi r17, high(TESTBUFFER)
	;ldi r16, low(TESTBUFFER)
	;push r17
	;push r16
	;rcall flash_message
    ;pop r16
    ;pop r17
   
; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The only things you can change in this section is
; the message (i.e., MESSAGE01 or MESSAGE02 or MESSAGE03,
; etc., up to MESSAGE09).
;

	; encode a message
	;
	ldi r17, high(MESSAGE09 << 1)
	ldi r16, low(MESSAGE09 << 1)
	push r17
	push r16
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall encode_message
	pop r16
	pop r16
	pop r16
	pop r16

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
	; display the message three times
	;
	ldi r18, 3
main_loop:
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall flash_message
	dec r18
	tst r18
	brne main_loop


stop:
	rjmp stop
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION **** 
; ****************************************************


flash_message:
	.set PARAM_OFFSET = 4
	in YH, SPH
	in YL, SPL

	ldd ZL, Y + PARAM_OFFSET
	ldd ZH, Y + PARAM_OFFSET + 1
	
	;this loop flashes letters until 
	;it reaches the end of the message
	loop3:	
	ld r16, Z+
	tst r16
	breq skip3
	
	push r16
	push ZH
	push ZL
	rcall morse_flash
	rcall delay_long
	pop ZL
	pop ZH
	pop r16
	rjmp loop3
	
	
	
	skip3:

	rcall delay_long

	ret



morse_flash:

	cpi r16, 0xff	;check if the character is a space
	brne notSpace
	rcall delay_long
	rcall delay_long
	ldi r19, 0x01
	rjmp skip2
	
	notSpace:
	swap r16

	mov r17, r16
	andi r16, 0x0f
	mov r19, r16
	mov r20, r16
	ldi r16, 0x06 ;the number of leds to turn on

	cpi r20, 0x04
	breq loop2

	;this loop shifts the morse until the first
	;meaningful bit is in the most left position
	morse_shift:
	lsl r17
	inc r20
	cpi r20, 0x04
	brne morse_shift
	
	;this loop flashes the leds for each bit
	loop2:
		mov r21, r17
		andi r21, 0x80
		
		;checks if the most left bit is set
		cpi r21, 0x80	
		brne short
		
		;if the bit is set, there is a dash
		;so do a long flash
		long:
		rcall leds_on
		rcall delay_long
		rcall leds_off
		rcall delay_long
		rjmp skip2
		
		;short flash otherwise
		short:
		rcall leds_on
		rcall delay_short
		rcall leds_off
		rcall delay_long
		
		skip2:
		lsl r17
		dec r19
		brne loop2
		
	ret



leds_on:
	
	mov r22, r16
	ldi r23, 0
	ldi r24, 0
	ldi r25, 0
	
	;for the first 2 iterations through this loop
	;it changes the output to PORTL
	;for the next 4 it changes output to PORTB
	loop1:
		cpi r23, 0x02
		brlt skip1
		lsr r25
		lsr r25
		ori r25, 0b10000000
		
		skip1:
		lsl r24
		lsl r24
		ori r24, 0b00000010
		

		inc r23
		dec r22
		tst r22
		brne loop1
		
		sts S_PORTB, r24
		sts S_PORTL, r25
	ret



leds_off:
	ldi r23, 0
	sts S_PORTL, r23
	sts S_PORTB, r23
	ret



encode_message:
	.set PARAM_OFFSET = 4
	in YH, SPH
	in YL, SPL
	ldd XL, Y + PARAM_OFFSET
	ldd XH, Y + PARAM_OFFSET + 1
	ldd ZL, Y + PARAM_OFFSET + 2
	ldd ZH, Y + PARAM_OFFSET + 3

	;this loop loads a character, and if it is
	;not 0, converts it to morse, then stores
	;it in the buffer
	loop6:
		lpm r16, Z+
		cpi r16, 0x00
		breq skip6

		push XH
		push XL
		push YH
		push YL
		push ZH
		push ZL
		push r16
		rcall letter_to_code
		pop r16
		pop ZL
		pop ZH
		pop YL
		pop YH
		pop XL
		pop XH
		st X+, r0
		rjmp loop6
	skip6:
	ret	



letter_to_code:
	.set PARAM_OFFEST = 4
	in YH, SPH
	in YL, SPL
	ldi ZL, low(ITU_MORSE << 1)
	ldi ZH, high(ITU_MORSE << 1)
	
	ldd r16, Y + PARAM_OFFSET
	ldi r18, 0x00
	ldi r19, 0x00
	
	;checks if the character to encode is a space
	cpi r16, 0x20	
	brne loop4
	ldi r18, 0xff
	rjmp skip5
	
	;this loop iterates through the table of letters to morse
	;conversions until it reaches the correct character
	loop4:
		lpm r17, Z+
		cp r16, r17
		brne skip4
		
		;this loop adds the correct bit to the end
		;of the encoded byte and increments the size counter
		loop5:
			
			lpm r17, Z+
			cpi r17, 0x00
			breq skip5
			
			;shift left so the next 
			lsl r19

			cpi r17, '.'
			breq dot
			
			;if there is a dash
			ori r19, 0x01
			inc r18
			rjmp loop5
		
			;if there is a dot
			dot:
			inc r18
			rjmp loop5
		
		
		
	
		skip4:

		;move the Z pointer to the location of 
		;the next letter in the table
		adiw Z, 0x07
		rjmp loop4
	
	;make the first 4 bits of the encoded 
	;byte the length of the morse code
	skip5:
	swap r19
	or r19, r18
	swap r19

	;put the result in r0 as required
	mov r0, r19
	
	ret	 


; **********************************************
; **** END OF SECOND "STUDENT CODE" SECTION **** 
; **********************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

delay_long:
	rcall delay
	rcall delay
	rcall delay
	ret

delay_short:
	rcall delay
	ret

; When wanting about a 1/5th of second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit
	
	ldi r17, 0xff
delay_busywait_loop2:
	dec	r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret



;.org 0x1000

ITU_MORSE: .db "A", ".-", 0, 0, 0, 0, 0
	.db "B", "-...", 0, 0, 0
	.db "C", "-.-.", 0, 0, 0
	.db "D", "-..", 0, 0, 0, 0
	.db "E", ".", 0, 0, 0, 0, 0, 0
	.db "F", "..-.", 0, 0, 0
	.db "G", "--.", 0, 0, 0, 0
	.db "H", "....", 0, 0, 0
	.db "I", "..", 0, 0, 0, 0, 0
	.db "J", ".---", 0, 0, 0
	.db "K", "-.-.", 0, 0, 0
	.db "L", ".-..", 0, 0, 0
	.db "M", "--", 0, 0, 0, 0, 0
	.db "N", "-.", 0, 0, 0, 0, 0
	.db "O", "---", 0, 0, 0, 0
	.db "P", ".--.", 0, 0, 0
	.db "Q", "--.-", 0, 0, 0
	.db "R", ".-.", 0, 0, 0, 0
	.db "S", "...", 0, 0, 0, 0
	.db "T", "-", 0, 0, 0, 0, 0, 0
	.db "U", "..-", 0, 0, 0, 0
	.db "V", "...-", 0, 0, 0
	.db "W", ".--", 0, 0, 0, 0
	.db "X", "-..-", 0, 0, 0
	.db "Y", "-.--", 0, 0, 0
	.db "Z", "--..", 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0

MESSAGE01: .db "A A A", 0
MESSAGE02: .db "SOS", 0
MESSAGE03: .db "A BOX", 0
MESSAGE04: .db "DAIRY QUEEN", 0
MESSAGE05: .db "THE SHAPE OF WATER", 0, 0
MESSAGE06: .db "DARKEST HOUR", 0, 0
MESSAGE07: .db "THREE BILLBOARDS OUTSIDE EBBING MISSOURI", 0, 0
MESSAGE08: .db "OH CANADA OUR OWN AND NATIVE LAND", 0
MESSAGE09: .db "I CAN HAZ CHEEZBURGER", 0

; First message ever sent by Morse code (in 1844)
MESSAGE10: .db "WHAT GOD HATH WROUGHT", 0


.dseg
.org 0x200
BUFFER01: .byte 128
BUFFER02: .byte 128
TESTBUFFER: .byte 4

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================
