  org $800
  ldaa #$79
  psha
  ldaa #$99
  psha
  
  ldaa 0,sp
  adda #1
  daa
  ldx #value
  staa 1,x
  bcc exit
carry_set
  ldaa -1,sp
  adda #1
  daa
  staa 0,x
exit 
  
value rmb 2

  end