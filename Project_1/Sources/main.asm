 org $800 ; location $800 is the beginning of SRAM
  ldaa #$00
  ldab #$01
  ldx #$900
  adda [d,x]
  
 org $901
  fcb 08
  fcb 00
  
 end 