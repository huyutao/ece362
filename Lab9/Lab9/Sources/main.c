/*
***********************************************************************
 ECE 362 - Experiment 9 - Fall 2016
***********************************************************************
	 	   			 		  			 		  		
 Completed by: < Yutao Hu >
               < 8031-H >
               < your lab division >
               < 11/11/2016 >


 Academic Honesty Statement:  In entering my name above, I hereby certify
 that I am the individual who created this HC(S)12 source file and that I 
 have not copied the work of any other student (past or present) while 
 completing it. I understand that if I fail to honor this agreement, I will 
 receive a grade of ZERO and be subject to possible disciplinary action.
***********************************************************************

 The objective of this experiment is to implement an analog signal sampling
 and reconstruction application that allows the user to efficiently cycle
 through different input and output sampling frequencies.

 The following design kit resources will be used:

 - left pushbutton (PAD7): cycles through input sampling frequency choices
                           (5000 Hz, 10,000 Hz, and 20,000 Hz)

 - right pushbutton (PAD6): cycles through output sampling frequency choices
                           (23,529 Hz, 47,059 Hz, and 94,118 Hz)

 - LCD: displays current values of input and output sampling frequencies
 - Shift Register: performs SPI -> parallel conversion for LCD interface

***********************************************************************
*/
 
#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <mc9s12c32.h>

/* All funtions after main should be initialized here */
char inchar(void);
void outchar(char);
void fdisp(void);
void shiftout(char);
void lcdwait(void);
void send_byte(char);
void send_i(char);
void chgline(char);
void print_c(char);
void pmsglcd(char[]);


/*  Variable declarations */ 	   			 		  			 		       
char leftpb	= 0;  // left pushbutton flag
char rghtpb	= 0;  // right pushbutton flag
char prevpb	= 0;  // previous pushbutton state
int prevleft = 0;
int prevrght = 0;
int freq_in = 5000;
unsigned long freq_out = 23529;
int count = 0;

/* LCD COMMUNICATION BIT MASKS */
#define RS 0x04		// RS pin mask (PTT[2])
#define RW 0x08		// R/W pin mask (PTT[3])
#define LCDCLK 0x10	// LCD EN/CLK pin mask (PTT[4])

/* LCD INSTRUCTION CHARACTERS */
#define LCDON 0x0F	// LCD initialization command
#define LCDCLR 0x01	// LCD clear display command
#define TWOLINE 0x38	// LCD 2-line enable command
#define CURMOV 0xFE	// LCD cursor move instruction
#define LINE1 0x80	// LCD line 1 cursor position
#define LINE2 0xC0	// LCD line 2 cursor position

/*	 	   		
***********************************************************************
 Initializations
***********************************************************************
*/

void  initializations(void) {

/* Set the PLL speed (bus clock = 24 MHz) */
  CLKSEL = CLKSEL & 0x80; //; disengage PLL from system
  PLLCTL = PLLCTL | 0x40; //; turn on PLL
  SYNR = 0x02;            //; set PLL multiplier
  REFDV = 0;              //; set PLL divider
  while (!(CRGFLG & 0x08)){  }
  CLKSEL = CLKSEL | 0x80; //; engage PLL


/* Disable watchdog timer (COPCTL register) */
  COPCTL = 0x40   ; //COP off; RTI and COP stopped in BDM-mode

/* Initialize asynchronous serial port (SCI) for 9600 baud, no interrupts */
  SCIBDH =  0x00; //set baud rate to 9600
  SCIBDL =  0x9C; //24,000,000 / 16 / 156 = 9600 (approx)  
  SCICR1 =  0x00; //$9C = 156
  SCICR2 =  0x0C; //initialize SCI for program-driven operation
  DDRB   =  0x10; //set PB4 for output mode
  PORTB  =  0x10; //assert DTR pin on COM port

         
/* Add additional port pin initializations here */
   DDRT = 0xFF; 		// Port T I/O output
   DDRM = 0x30;     //port PM I/O output ,PM4 PM5


/* Initialize the SPI to 6 Mbs */
  //SPIBR = 0x01; 
  SPIBR = 0x10;    //BusClock / 4 
  SPICR1 = 0x50;   //0101 enable, master mode
  SPICR2 = 0x00;   // non-bidirectional mode


	 	   			 		  			 		  		
/* Initialize digital I/O port pins */
  DDRAD = 0; 		//program port PAD for input mode
  ATDDIEN = 0xC0; //program PAD7 and PAD6 pins as digital inputs



/* Initialize the LCD
     - pull LCDCLK high (idle)
     - pull R/W' low (write state)
     - turn on LCD (LCDON instruction)
     - enable two-line mode (TWOLINE instruction)
     - clear LCD (LCDCLR instruction)
     - wait for 2ms so that the LCD can wake up     
*/
  PTT_PTT4 = 1;
  PTT_PTT3 = 0;
  send_i(LCDON);
  send_i(TWOLINE);
  send_i(LCDCLR);
  lcdwait();     

/* Initialize RTI for 2.048 ms interrupt rate */
  CRGINT = 0x80;
  RTICTL = 0x1F;  	

/* Initialize TIM Ch 7 (TC7) for periodic interrupts every 1.000 ms
     - enable timer subsystem
     - set channel 7 for output compare
     - set appropriate pre-scale factor and enable counter reset after OC7
     - set up channel 7 to generate 1 ms interrupt rate
     - initially disable TIM Ch 7 interrupts      
*/
  TSCR1 = 0x80;   //enable
  TIOS = 0x80; //output compare mode
  TSCR2 = 0x0C;   // TCNT reset when OC7 occur  prescale 16
  TC7 = 300;
  TIE_C7I = 1;   //disable TIM ch7 interrupts

//initiallize ATD
  ATDCTL2 = 0x80;   //enable
 	ATDCTL3 = 0x10;  //00010000 bit 6-3 0010 2 conversion
 	ATDCTL4 = 0x85;   //  10000101 8 bit operation; 00 2ATD clock periods; 00101 2 MHZ  clock pre-scalar 
  ATDCTL5 = 0x10;   // sample multiple channels

// initialize PWM
  MODRR = 0x01;  // CH0  output use PT0
  PWME = 0x01; //CH0 output
  PWMPOL = 0x01; //CH0 active high
  PWMPER0 = 0xFF; //max 255 period
  PWMDTY0 = 0;     //initial duty 0
  PWMPRCLK = 0x02;  //bus clock/4 = 6MHz   6MHz/255 = 23529 Hz
  PWMCLK = 0x00;  //clock A
  PWMCTL = 0x00;   // no concatenate
  PWMCAE = 0x00;
  
	      
}

/*	 		  			 		  		
***********************************************************************
 Main
***********************************************************************
*/

void main(void) {
  	DisableInterrupts;
	initializations(); 		  			 		  		
	EnableInterrupts;
	fdisp();
	
  for(;;) {
  

  /* write your code here */
  if(leftpb){
    leftpb = 0;
    if(freq_in == 5000){
      TC7 = 150;
      freq_in = 10000;
    }else if(freq_in == 10000){
      TC7 = 75;
      freq_in = 20000;
    }else{
      TC7 = 300;
      freq_in = 5000;
    }
    fdisp();   
  }

  if(rghtpb){
    rghtpb = 0;
    if(freq_out == 23529){
      PWMPRCLK = 0x01;  //bus clock/2 = 12MHz   12MHz/255 = 47059 Hz
      freq_out = 47059;
    }else if(freq_out == 47059){
      PWMPRCLK = 0x00;  //bus clock = 24MHz   24MHz/255 = 94118 Hz
      freq_out = 94118;
    }else{
      PWMPRCLK = 0x02;  //bus clock/4 = 6MHz   6MHz/255 = 23529 Hz
      freq_out = 23529;
    }
    fdisp();

  }

 
  } /* loop forever */
   
}  /* do not leave main */




/*
***********************************************************************
 RTI interrupt service routine: RTI_ISR

  Initialized for 2.048 ms interrupt rate

  Samples state of pushbuttons (PAD7 = left, PAD6 = right)

  If change in state from "high" to "low" detected, set pushbutton flag
     leftpb (for PAD7 H -> L), rghtpb (for PAD6 H -> L)
     Recall that pushbuttons are momentary contact closures to ground
***********************************************************************
*/

interrupt 7 void RTI_ISR(void)
{
  	// clear RTI interrupt flag
  	CRGFLG = CRGFLG | 0x80;
  	if(PTAD_PTAD7==0 && prevleft == 1){
  	  leftpb = 1;
  	}
  	prevleft = PTAD_PTAD7;
  	
  	if(PTAD_PTAD6==0 && prevrght == 1){
  	  rghtpb = 1;
  	}
  	prevrght = PTAD_PTAD6; 

}

/*
***********************************************************************
  TIM interrupt service routine
  used to initiate ATD samples (on Ch 0 and Ch 1)	 		  			 		  		
***********************************************************************
*/

interrupt 15 void TIM_ISR(void)
{

    
        // clear TIM CH 7 interrupt flag 
   	TFLG1 = TFLG1 | 0x80;
   	ATDCTL5 = 0x10;
    while(ATDSTAT0); //wait for completion
    TC7 = ATDDR0H;
    if(count > 255){
      count = 0;
    }
     
    PWMDTY0 = (count++) * ATDDR1H/ 255;
       	

}

/*
***********************************************************************
  fdisp: Display "ISF = NNNNN Hz" on the first line of the LCD and display 
         and "OSF = MMMMM Hz" on the second line of the LCD (where NNNNN and
         MMMMM are the input and output sampling frequencies, respectively         
***********************************************************************
*/

void fdisp()
{
  send_i(LCDCLR);
  chgline(LINE1);
  pmsglcd("ISF: ");

  if(freq_in == 5000){
      pmsglcd(" 5000");
    }else if(freq_in == 10000){
      pmsglcd("10000");
    }else{
      pmsglcd("20000");
    }  
  pmsglcd(" Hz");
  
  chgline(LINE2);
  pmsglcd("OSF: ");
  if(freq_out == 23529){
      pmsglcd("23529");
    }else if(freq_out == 47059){
      pmsglcd("47059");
    }else{
      pmsglcd("94118");
    }
  pmsglcd(" Hz");  

}


  

/*
***********************************************************************
  shiftout: Transmits the character x to external shift 
            register using the SPI.  It should shift MSB first.  
             
            MISO = PM[4]
            SCK  = PM[5]
***********************************************************************
*/
 
void shiftout(char x)

{
  int i;
  while(SPISR_SPTEF == 0){}
  SPIDR = x;
  for(i=0;i<30;i++){}  // wait 
  // read the SPTEF bit, continue if bit is 1
  // write data to SPI data register
  // wait for 30 cycles for SPI data to shift out 

}

/*
***********************************************************************
  lcdwait: Delay for approx 2 ms
***********************************************************************
*/

void lcdwait()
{
  int i;
  for(i=0;i<5000;i++){
  }
 
}

/*
*********************************************************************** 
  send_byte: writes character x to the LCD
***********************************************************************
*/

void send_byte(char x)
{
     // shift out character
     // pulse LCD clock line low->high->low
     // wait 2 ms for LCD to process data
     shiftout(x);
     PTT_PTT4 = 0;
     PTT_PTT4 = 1;
     PTT_PTT4 = 0;
     lcdwait();
}

/*
***********************************************************************
  send_i: Sends instruction byte x to LCD  
***********************************************************************
*/

void send_i(char x)
{
      // set the register select line low (instruction data)
      // send byte
      PTT_PTT2 = 0;
      send_byte(x);    
}

/*
***********************************************************************
  chgline: Move LCD cursor to position x
  NOTE: Cursor positions are encoded in the LINE1/LINE2 variables
***********************************************************************
*/

void chgline(char x)
{
    send_i(CURMOV);
    send_i(x);
  
}

/*
***********************************************************************
  print_c: Print (single) character x on LCD            
***********************************************************************
*/
 
void print_c(char x)
{
  PTT_PTT2 = 1;
  send_byte(x); 
}

/*
***********************************************************************
  pmsglcd: print character string str[] on LCD
***********************************************************************
*/

void pmsglcd(char str[])
{
  int i =0;
  while(str[i] != '\0'){
    print_c(str[i]);
    i++;
  }
}


/*
***********************************************************************
 Character I/O Library Routines for 9S12C32 (for debugging only)
***********************************************************************
 Name:         inchar
 Description:  inputs ASCII character from SCI serial port and returns it
 Example:      char ch1 = inchar();
***********************************************************************
*/

char inchar(void) {
  /* receives character from the terminal channel */
        while (!(SCISR1 & 0x20)); /* wait for input */
    return SCIDRL;
}

/*
***********************************************************************
 Name:         outchar
 Description:  outputs ASCII character x to SCI serial port
 Example:      outchar('x');
***********************************************************************
*/

void outchar(char x) {
  /* sends a character to the terminal channel */
    while (!(SCISR1 & 0x80));  /* wait for output buffer empty */
    SCIDRL = x;
}