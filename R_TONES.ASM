; FILE: R_TONES.ASM
; DATE: 12-17-94


	 STTL 'TONE GEN ROUTINES'
	 PAGE

	 CODE

CONTROL_TONES:   ;TURN TONES ON & OFF


;* WARNING: MUST use a 'JSL' to call this routine!
;
;  Enter with 8 Bit Areg containing the control info.
;    If Areg = 0  the tone generators will be turned off.
;    If Areg = 1  tone generator TG0 is turned on
;    If Areg = 2  tone generator TG1 is turned on.
;    If Areg = 3  both TG0 & TG1 are turned on.
;
;  Enter with 16 bit Xreg containing the TIMER 5 VALUE
;  Enter with 16 bit Yreg containing the TIMER 6 VALUE
;
;  IF Xreg or Yreg = 0, then use previously set timer value.
;  
         PHA
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         ORA #0
         BEQ ?0
         CMP #1
         BEQ ?1
         CMP #2
         BEQ ?2
         CMP #3
         BEQ ?3
         PLA                 ;NOT PROPER CALL PARAMETER
         SEC
         RTL


?0       LDA #Bit1+Bit2       ;DISABLE TG0 & TG1
         TRB BCR
         LDA #T5FLG+T6FLG     ;DISABLE TIMERS #5 & 6 ON 265
         TRB !TER
         BRA ?4
        
?1       CPX #0
	 BEQ ?1_5
         STX !T5CL
?1_5     LDA #T5FLG          ;ENABLE TIMER #5
         TSB !TER
         LDA #Bit1           ;ENABLE TG0 
         TSB BCR
         BRA ?4

?2       CPY #0
	 BEQ ?2_5
         STY !T6CL
?2_5     LDA #T6FLG          ;ENABLE TIMER #6
         TSB !TER
         LDA #Bit2           ;ENABLE TG1
         TSB BCR
         BRA ?4

?3       CPX #0
	 BEQ ?3_3
         STX !T5CL
?3_3     CPY #0
	 BEQ ?3_6
         STY !T6CL
?3_6     LDA #T5FLG+T6FLG    ;ENABLE TIMERS #5 & 6 ON 265
         TSB !TER
         LDA #Bit1+Bit2      ;ENABLE TG0 & TG1
         TSB BCR

?4	 PLB
	 PLD
         PLA
         CLC
         RTL

	 ENDS

	 APPEND R_CLOCK.ASM
