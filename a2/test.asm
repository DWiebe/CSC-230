.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0

	ldi r16, 0x30
	mov r20, r16
	swap r20
	andi r20, 0x0f
	mov r21, r16
	loop2:
		mov r22, r21
		andi r22, 0x01
		tst r22
		breq short
		
		long:
		call leds_on
		call delay_long
		call leds_off
		call delay_long
		rjmp skip2
		
		rjmp skip2
		
		

		short:
		call leds_on
		call delay_short
		call leds_off
		call delay_long
		rjmp skip2
		


		skip2:
		lsr r21
		dec r20
		brne loop2
	

stop: rjmp stop
