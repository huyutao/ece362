// ***********************************************************************
//  ECE 362 - Experiment 7 - Fall 2016
//
// Dual-channel LED bar graph display                    
// ***********************************************************************
//	 	   			 		  			 		  		
// Completed by: < Yutao Hu >
//               < 8031H >
//               < your lab division >
//               < 10/27/2016 >
//
//
// Academic Honesty Statement:  In entering my name above, I hereby certify
// that I am the individual who created this HC(S)12 source file and that I 
// have not copied the work of any other student (past or present) while 
// completing it. I understand that if I fail to honor this agreement, I will 
// receive a grade of ZERO and be subject to possible disciplinary action.
//
// ***********************************************************************

#include <hidef.h>           /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <mc9s12c32.h>

// All funtions after main should be initialized here

// Note: inchar and outchar can be used for debugging purposes

char inchar(void);
void outchar(char x);
			 		  		
//  Variable declarations  	   			 		  			 		       
int tenthsec = 0;  // one-tenth second flag
int leftpb = 0;    // left pushbutton flag
int rghtpb = 0;    // right pushbutton flag
int runstp = 0;    // run/stop flag                         
int rticnt = 0;    // RTICNT (variable)
int prevpb = 0;    // previous state of pushbuttons (variable)
unsigned char result0;
unsigned char result1;
#define THRESH1 1   //+42
#define THRESH2 2   //+43
#define THRESH3 3  //+42
#define THRESH4 4  //+43
#define THRESH5 5  //+43
int THRESH[5] = {THRESH1,THRESH2,THRESH3,THRESH4,THRESH5};
int i;
  
	 	   		
// Initializations
 
void  initializations(void) {

// Set the PLL speed (bus clock = 24 MHz)

  		CLKSEL = CLKSEL & 0x80; // disengage PLL from system
  		PLLCTL = PLLCTL | 0x40; // turn on PLL
  		SYNR = 0x02;            // set PLL multiplier
  		REFDV = 0;              // set PLL divider
  		while (!(CRGFLG & 0x08)){  }
  		CLKSEL = CLKSEL | 0x80; // engage PLL
  
// Disable watchdog timer (COPCTL register)

      COPCTL = 0x40;    //COP off - RTI and COP stopped in BDM-mode

// Initialize asynchronous serial port (SCI) for 9600 baud, no interrupts

      SCIBDH =  0x00; //set baud rate to 9600
      SCIBDL =  0x9C; //24,000,000 / 16 / 156 = 9600 (approx)  
      SCICR1 =  0x00; //$9C = 156
      SCICR2 =  0x0C; //initialize SCI for program-driven operation
         
//  Initialize Port AD pins 7 and 6 for use as digital inputs

	    DDRAD = 0; 		//program port AD for input mode
      ATDDIEN = 0xC0; //program PAD7 and PAD6 pins as digital inputs
         
//  Add additional port pin initializations here  (e.g., Other DDRs, Ports) 
	    DDRT = 0xFF; 		// Port T I/O output

//  Define bar graph segment thresholds (THRESH1..THRESH5)
//  NOTE: These are binary fractions

      

//  Add RTI/interrupt initializations here
    CRGINT = 0x80;
    RTICTL = 0x61;  // M=2,N=15 Period = 8.192, RTICNT = 12
    ATDCTL2 = 0x80;   //enable
	 	ATDCTL3 = 0x10;  //00010000 bit 6-3 0010 2 conversion
	 	ATDCTL4 = 0x85;   //  10000101 8 bit operation; 00 2ATD clock periods; 00101 2 MHZ  clock pre-scalar 


}
	 		  			 		  		
 
// Main (non-terminating loop)
 
void main(void) {
	initializations(); 		  			 		  		
	EnableInterrupts;


  for(;;) {


// Main program loop (state machine)
// Start of main program-driven polling loop

	 	 if(tenthsec == 1){
	 	  tenthsec = 0;
//  If the "tenth second" flag is set, then
//    - clear the "tenth second" flag
//    - if "run/stop" flag is set, then
	 	  if(runstp){  
//       - initiate ATD coversion sequence	 	    
	 	    ATDCTL5 = 0x10;
	 	    while(!ATDSTAT0_SCF){} //wait for completion 
	 	    result0 = ATDDR0H;
	 	    result1 = ATDDR1H;
//       - apply thresholds to converted values
        for(i=0;i<5;i++){
          PTT_PTT2 = 0;          //clock 0 
          if(result0 > THRESH[i]){
            PTT_PTT3 = 1;           //shift 1 
          }else{
            PTT_PTT3 = 0;           //shift 0 
          }
          PTT_PTT2 = 1;    //clock in
        }
        for(i=0;i<5;i++){
          PTT_PTT2 = 0;          //clock 0 
          if(result1 > THRESH[i]){
            PTT_PTT3 = 1;           //shift 1 
          }else{
            PTT_PTT3 = 0;           //shift 0 
          }
          PTT_PTT2 = 1;    //clock in
        }
	 	  }
	 	 }
//       - determine 5-bit bar graph bit settings for each input channel
//       - transmit 10-bit data to external shift register
//    - endif
//  Endif

	 	   	if(leftpb == 1){
	 	   	  leftpb = 0;
	 	   	  runstp = 0;
	 	   	  PTT_PTT0 = 0;   //left on (sinking current)
	 	   	  PTT_PTT1 = 1;   //right
	 	   	}
//  If the left pushbutton ("stop BGD") flag is set, then:
//    - clear the left pushbutton flag
//    - clear the "run/stop" flag (and "freeze" BGD)
//    - turn on left LED/turn off right LED (on docking module)
//  Endif


	 	   	if(rghtpb == 1){
	 	   	  rghtpb = 0;
	 	   	  runstp = 1;
	 	   	  PTT_PTT0 = 1;   //left 
	 	   	  PTT_PTT1 = 0;   //right on (sinking current)
	 	   	}
   			 		  			 		  		
//  If the right pushbutton ("start BGD") flag is set, then
//    - clear the right pushbutton flag
//    - set the "run/stop" flag (enable BGD updates)
//    - turn off left LED/turn on right LED (on docking module)
//  Endif
	 	   			 		  			 		  		

  } /* loop forever */
  
}  /* make sure that you never leave main */



// ***********************************************************************                       
// RTI interrupt service routine: rti_isr
//
//  Initialized for 5-10 ms (approx.) interrupt rate - note: you need to
//    add code above to do this
//
//  Samples state of pushbuttons (PAD7 = left, PAD6 = right)
//
//  If change in state from "high" to "low" detected, set pushbutton flag
//     leftpb (for PAD7 H -> L), rghtpb (for PAD6 H -> L)
//     Recall that pushbuttons are momentary contact closures to ground
//
//  Also, keeps track of when one-tenth of a second's worth of RTI interrupts
//     accumulate, and sets the "tenth second" flag         	   			 		  			 		  		
 
interrupt 7 void RTI_ISR( void)
{
 // set CRGFLG bit to clear RTI device flag
  	CRGFLG = CRGFLG | 0x80;
  	if (runstp){  	  
    	rticnt = rticnt + 1;
    	if (rticnt == 12){
    	  rticnt = 0;
    	  tenthsec = 1;
    	}
  	}
  	if (PORTAD0_PTAD7 == 0){
  	  leftpb = 1;
  	}
  	
  	if (PORTAD0_PTAD6 == 0){
  	  rghtpb = 1;
  	}
  	
	

}


// ***********************************************************************
// Character I/O Library Routines for 9S12C32 (for debugging only)
// ***********************************************************************
// Name:         inchar
// Description:  inputs ASCII character from SCI serial port and returns it
// ***********************************************************************
char  inchar(void) {
  /* receives character from the terminal channel */
        while (!(SCISR1 & 0x20)); /* wait for RDR input */
    return SCIDRL;
 
}

// ***********************************************************************
// Name:         outchar
// Description:  outputs ASCII character passed in outchar()
//                  to the SCI serial port
// ***********************************************************************/
void outchar(char ch) {
  /* transmits a character to the terminal channel */
    while (!(SCISR1 & 0x80));  /* wait for TDR empty */
    SCIDRL = ch;
}

