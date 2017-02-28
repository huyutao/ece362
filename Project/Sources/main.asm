; Generic assembly source file for testing code segments
 org $800 ; location $800 is the beginning of SRAM
 ldaa opand1 ; load first operand
 oraa opand2 ; instruction(s) being tested (with second operand)
 staa result ; store result
 stop ; SET BREAKPOINT HERE

 org $900 ; place operand data at location $900
opand1 fcb $CC ; test data
opand2 fcb $55 ; test data
result fcb 0 ; place to store result (initially cleared)
 end 