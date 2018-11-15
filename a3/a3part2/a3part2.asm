; a3part2.asm
; CSC 230: Spring 2018
;
; Student name:David Wiebe
; Student ID:V00875342
; Date of completed work:03/26/2018
;
; *******************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2018-Mar-08)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2, there are 
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
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler directives setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants we can use later in the
;     program
;
; (4) code for initial setup of the Analog Digital Converter (in the
;     same manner in which it was set up for Lab #4)
;     
; (5) code for setting up our three timers (timer1, timer3, timer4)
;
; After all this initial code, your own solution's code may start.
;

.cseg
.org 0
	jmp reset

; location in vector table for TIMER1 COMPA
;
.org 0x22
	jmp timer1

; location in vector table for TIMER4 COMPA
;
.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd_function_defs.inc"
.include "lcd_function_code.asm"

.cseg

; These two constants can help given what is required by the
; assignment.
;
#define MAX_PATTERN_LENGTH 10
#define BAR_LENGTH 6

; All of these delays are in seconds
;
#define DELAY1 0.5
#define DELAY3 0.1
#define DELAY4 0.01


; The following lines are executed at assembly time -- their
; whole purpose is to compute the counter values that will later
; be stored into the appropriate Output Compare registers during
; timer setup.
;

#define CLOCK 16.0e6 
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))

.if TOP1>65535
.error "TOP1 is out of range"
.endif

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif


reset:
	; initialize the ADC converter (which is neeeded
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer4 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16


	; timer1 is for the heartbeat -- i.e., part (1)
	;
    ldi r16, high(TOP1)
    sts OCR1AH, r16
    ldi r16, low(TOP1)
    sts OCR1AL, r16
    ldi r16, 0
    sts TCCR1A, r16
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, temp
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; timer3 is for the LCD display updates -- needed for all parts
	;
    ldi r16, high(TOP3)
    sts OCR3AH, r16
    ldi r16, low(TOP3)
    sts OCR3AL, r16
    ldi r16, 0
    sts TCCR3A, r16
    ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
    sts TCCR3B, temp

	; timer4 is for reading buttons at 10ms intervals -- i.e., part (2)
    ; and part (3)
	;
    ldi r16, high(TOP4)
    sts OCR4AH, r16
    ldi r16, low(TOP4)
    sts OCR4AL, r16
    ldi r16, 0
    sts TCCR4A, r16
    ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
    sts TCCR4B, temp
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

    ; flip the switch -- i.e., enable the interrupts
    sei

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; *********************************************
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; *********************************************

rcall lcd_init

start:
	
	

 	lds r16, TCNT3L
	lds r17, TCNT3H
	
	lds r18, OCR3AL
	lds r19, OCR3AH

	cp r16, r18
	cpc r17, r19
	brne start

	lds r16, PULSE
	andi r16, 0x01
	tst r16
	breq nobeat
	
	beat:
		ldi r16, 0
		ldi r17, 14
		push r16
		push r17
		rcall lcd_gotoxy
		pop r17
		pop r16
		ldi r16, '<'
		push r16
		rcall lcd_putchar
		pop r16

		ldi r16, 0
		ldi r17, 15
		push r16
		push r17
		rcall lcd_gotoxy
		pop r17
		pop r16
		ldi r16, '>'
		push r16
		rcall lcd_putchar
		pop r16
	
		rjmp show_count

	
	nobeat:
		ldi r16, 0
		ldi r17, 14
		push r16
		push r17
		rcall lcd_gotoxy
		pop r17
		pop r16
		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16

		ldi r16, 0
		ldi r17, 15
		push r16
		push r17
		rcall lcd_gotoxy
		pop r17
		pop r16
		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16
	
	show_count:
		
		lds r16, BUTTON_CURRENT
		lds r17, BUTTON_PREVIOUS
		tst r16
		breq showcount_skip
		cp r16, r17
		brne showcount_skip		

		lds r16, BUTTON_COUNT
		lds r17, BUTTON_COUNT + 1
		ldi r18, 0
		inc r16
		adc r17, r18
		st Z, r16
		sbiw Z, 1
		st Z, r17

		showcount_skip:
		lds r16, BUTTON_COUNT
		lds r17, BUTTON_COUNT + 1
		push r17
		push r16

	 	ldi r16, low(DISPLAY_TEXT)
		ldi r17, high(DISPLAY_TEXT)
		push r17
		push r16

		rcall to_decimal_text
		
		ldi r16, 5
		ldi r17, 11
		ldi ZL, low(DISPLAY_TEXT)
		ldi ZH, high(DISPLAY_TEXT)
		
		count_loop:
			ldi r18, 1
			push r18
			push r17
			rcall lcd_gotoxy
			pop r17
			pop r18
			ld r18, Z
			push r18
			rcall lcd_putchar
			pop r18
			
			adiw Z, 1
			inc r17
			dec r16
			brne count_loop

		rjmp start

stop:
    rjmp stop


timer1:

	push r16
	in r16, SREG
	push r16
	lds r16, PULSE
	inc r16
	sts PULSE, r16
	pop r16
	out SREG, r16
	pop r16
	reti


; Note there is no "timer3" interrupt handler as we must use this
; timer3 in a polling style within our main program.


timer4:
	push r16
	push r17
	push r18
	push r19
	push r20
	push ZH
	push ZL
	in r16, SREG
	push r16

	lds	r16, ADCSRA	

	ori r16, 0x40 
	sts	ADCSRA, r16

	wait:	
		lds r16, ADCSRA
		andi r16, 0x40
		brne wait
	
	lds r17, ADCL
	lds r18, ADCH

	ldi r19, LOW(900)
	ldi r20, HIGH(900)
		
	cp r17, r19
	cpc r18, r20
	brge not_pressed
	
	lds r16, BUTTON_CURRENT
	sts BUTTON_PREVIOUS, r16
	ldi r16, 1
	sts BUTTON_CURRENT, r16

	not_pressed:

	lds r16, BUTTON_CURRENT
	sts BUTTON_PREVIOUS, r16
	ldi r16, 0
	sts BUTTON_CURRENT, r16
	
	pop r16
	out SREG, r16
	pop ZL
	pop ZH
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
    reti

;The following code (the to_decimal_text function) is taken from Mike Zastre's work posted on Connex
to_decimal_text:
	 .equ MAX_POS = 5
	 .def countL=r18
	 .def countH=r19
	 .def factorL=r20
	 .def factorH=r21
	 .def multiple=r22
	 .def pos=r23
	 .def zero=r0
	 .def ascii_zero=r16
	 push countH
	 push countL
	 push factorH
	 push factorL
	 push multiple
	 push pos
	 push zero
	 push ascii_zero
	 push YH
	 push YL
	 push ZH
	 push ZL
	 in YH, SPH
	 in YL, SPL
	 ; fetch parameters from stack frame
	 ;
	 .set PARAM_OFFSET = 16
	 ldd countH, Y+PARAM_OFFSET+3
	 ldd countL, Y+PARAM_OFFSET+2
	 ; this is only designed for positive
	 ; signed integers; we force a negative
	 ; integer to be positive.
	 ;
	 andi countH, 0b01111111
	 clr zero
	 clr pos
	 ldi ascii_zero, '0'
	 ; The idea here is to build the text representation
	 ; digit by digit, starting from the left-most.
	 ; Since we need only concern ourselves with final
	 ; text strings having five characters (i.e., our
	 ; text of the decimal will never be more than
	 ; five characters in length), we begin we determining
	 ; how many times 10000 fits into countH:countL, and
	 ; use that to determine what character (from ’0’ to
	 ; ’9’) should appear in the left-most position
	 ; of the string.
	 ;
	 ; Then we do the same thing for 1000, then
	 ; for 100, then for 10, and finally for 1.
	 ;
	 ; Note that for *all* of these cases countH:countL is
	 ; modified. We never write these values back onto
	 ; that stack. This means the caller of the function
	 ; can assume call-by-value semantics for the argument
	 ; passed into the function.
	 ;
	to_decimal_next:
	clr multiple
	
	to_decimal_10000:
	cpi pos, 0
	brne to_decimal_1000
	ldi factorL, low(10000)
	ldi factorH, high(10000)
	rjmp to_decimal_loop
	
	to_decimal_1000:
	cpi pos, 1
	brne to_decimal_100
	ldi factorL, low(1000)
	ldi factorH, high(1000)
	rjmp to_decimal_loop
	
	to_decimal_100:
	cpi pos, 2
	brne to_decimal_10
	ldi factorL, low(100)
	ldi factorH, high(100)
	rjmp to_decimal_loop
	
	to_decimal_10:
	cpi pos, 3
	brne to_decimal_1
	ldi factorL, low(10)
	ldi factorH, high(10)
	rjmp to_decimal_loop
	
	to_decimal_1:
	mov multiple, countL
	rjmp to_decimal_write
	
	to_decimal_loop:
	inc multiple
	sub countL, factorL
	sbc countH, factorH
	brpl to_decimal_loop
	dec multiple
	add countL, factorL
	adc countH, factorH
	
	to_decimal_write:
	ldd ZH, Y+PARAM_OFFSET+1
	ldd ZL, Y+PARAM_OFFSET+0
	add ZL, pos
	adc ZH, zero
	add multiple, ascii_zero
	st Z, multiple
	inc pos
	cpi pos, MAX_POS
	breq to_decimal_exit
	rjmp to_decimal_next
	
	to_decimal_exit:
	pop ZL
	pop ZH
	pop YL
	pop YH
	pop ascii_zero
	pop zero
	pop pos
	pop multiple
	pop factorL
	pop factorH
	pop countL
	pop countH
	.undef countL
	.undef countH
	.undef factorL
	.undef factorH
	.undef multiple
	.undef pos
	.undef zero
	.undef ascii_zero
	ret

.dseg
.org 0x200
COUNTER_TEXT: .byte 6
COUNTER_VAL: .byte 2

; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The purpose of these locations in data memory are
; explained in the assignment description.
;

.dseg

PULSE: .byte 1
COUNTER: .byte 2
DISPLAY_TEXT: .byte 16
BUTTON_CURRENT: .byte 1
BUTTON_PREVIOUS: .byte 1
BUTTON_COUNT: .byte 2
BUTTON_LENGTH: .byte 1
DOTDASH_PATTERN: .byte MAX_PATTERN_LENGTH



; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################
