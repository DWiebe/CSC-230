/* a4.c
 * CSC Spring 2018
 * 
 * Student name: David Wiebe
 * Student UVic ID: V00875342
 * Date of completed work: 04/02/2018
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2018-Mar-25)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

void led_state(uint8_t LED, uint8_t state) {
	
	DDRL = 0xff;
	
	//first switch for turning led on or off
	switch(state){
	case 0:	//turning leds off

		//second switch for which led to turn on or off
		switch(LED){
		
		case 0:	//led0
			PORTL &= 0x7f;
		
			break;
		case 1:	//led1
			PORTL &= 0xdf;
			break;
		case 2:	//led2
			PORTL &= 0xf7;
			break;
		case 3:	//led3
			PORTL &= 0xfd;
		}
		break;

	default:	//turning leds on
		switch(LED){
		case 0:
			PORTL |= 0x80;
			break;
		case 1:
			PORTL |= 0x20;
			break;
		case 2:
			PORTL |= 0x08;
			break;
		case 3:
			PORTL |= 0x02;
		}
		
	}
	
}



void SOS() {
    uint8_t light[] = {
        0x1, 0, 0x1, 0, 0x1, 0,
        0xf, 0, 0xf, 0, 0xf, 0,
        0x1, 0, 0x1, 0, 0x1, 0,
        0x0
    };

    int duration[] = {
        100, 250, 100, 250, 100, 500,
        250, 250, 250, 250, 250, 500,
        100, 250, 100, 250, 100, 250,
        250
    };

	int length = 19;
	

	//iterates through each dot/dash
	for(int i = 0; i < length; i++){

		//turns of all leds
		led_state(0,0);
		led_state(1,0);
		led_state(2,0);
		led_state(3,0);
	
		uint8_t x;	//contains values from light[]
		uint8_t l = 0x00;	//keeps track of what led we are working with
		
		//iterates once per led
		for(int n = 0; n < 4; n++){
			
			//the bit represeting the current led will
			//always be in the rightmost position of x
			x = light[i] >> n;

			//check if the bit is set
			switch(x & 0x01){
			
			case 0:	//not set so dont turn on led
				l++;
				break;
			
			default:	//bit is set so turn on led
				led_state(l++, 1);

			}	
			
		}
		
		_delay_ms(duration[i]);	//delay after turning on lights
	
	
	}
}


void glow(uint8_t LED, float brightness) {

	int threshold = PWM_PERIOD * brightness;
	
	//infinite loop
	for(;;){
		
		//led has not been on long enough yet
		if(count < threshold){
		
			led_state(LED, 1);	//led stays on

	
		//threshold < count < PWM_PERIOD
		//(the off portion of the cycle)
		} else if(count < PWM_PERIOD){
		
			led_state(LED, 0);	//led stays off
		
		//count > PWM_PERIOD at this point
		//(the cycle has ended)
		} else{
			
			//start a new cycle
			count = 0;
			led_state(LED, 1);			

		}
	
	} 

}



void pulse_glow(uint8_t LED) {
	
	int pulse_speed = 1;
	int threshold = PWM_PERIOD;
	int increasing = 0;

	//same cycle as glow with additional statements at the end
	for(;;){
		if(count < threshold){
		
			led_state(LED, 1);

		} else if(count < PWM_PERIOD){
		
			led_state(LED, 0);
		
		} else{
			
			count = 0;
			led_state(LED, 1);			

		}
		


		//the following statements only execute when slow_count > PWM_PERIOD / 100
		//(every 50 ms)
		
		//brightness increasing
		if(slow_count > PWM_PERIOD / 100 && threshold < PWM_PERIOD && increasing == 1){
		
			//increase brightness and reset slow_counter
			threshold = threshold + pulse_speed;
			slow_count = 0;

			//max brightness reached
			if(threshold >= PWM_PERIOD){

				increasing = 0;	//start decreasing
			}

		//brightness decreasing
		} else if(slow_count > PWM_PERIOD / 100 && threshold > 0 && increasing == 0){
		
			
			//decrease brightness and reset counter
			threshold = threshold - pulse_speed;	
			slow_count = 0;

			//min brightness reached
			if(threshold <= 0){

				increasing = 1;	//start increasing
			}
		
		}
		
		
	}
}


void light_show() {

}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

 //This code could be used to test your work for part A.
/*
	led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
 */
 //led_state(3,1);

 //This code could be used to test your work for part B.

	SOS();
 

 //This code could be used to test your work for part C.
	
	//led_state(3, 1);
	//_delay_ms(1000);
	//glow(3, .5);
 



// This code could be used to test your work for part D.

	pulse_glow(3);


/* This code could be used to test your work for the bonus part.

	light_show();
 */

/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
