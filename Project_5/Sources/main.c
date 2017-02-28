#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

unsigned int time;
int bcddec(int val);

void main(void) {
  /* put your own code here */

	time = ox8000;
	time = bcddec(time);
	
	

  	EnableInterrupts;


  for(;;) {
    _FEED_COP(); /* feeds the dog */
  } /* loop forever */
  /* please make sure that you never leave main */

    
}

int bcddec(int value){
  asm{
    
    puld
    exg a,b
    adca #$99
    daa
    exg a,b
    adca #$99
    daa
    pshd
  }
  return value;
}