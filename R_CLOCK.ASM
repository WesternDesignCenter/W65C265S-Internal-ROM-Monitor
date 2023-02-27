;FILE:  'R_CLOCK.ASM - Time of Day Clock Routines'
;DATE:   02-04-1995

	 STTL 'R_CLOCK.ASM - TIME OF DAY CLOCK ROUTINES'
	 PAGE

	 CODE

;*  ROUTINE:  SET_DATE
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character
;*       buffer that contains an update string.
;*
;*     The updating format  = MM-DD-YY(null).  The null termination
;*       is unnecessary.
;*
;*     The Carry Bit will be set upon return if a format error
;*       is found.
;*
 
SET_DATE:

         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         SEP #M8
	 LONGA OFF

         JSR CONVERT2ASCII
	 BEQ BAD_EXIT
         BCS BAD_EXIT
         CMP #13
         BCS BAD_EXIT
         STA !MONTH
         INX
         LDA !0,X
         CMP #'-'
         BEQ ?2
         CMP #'/'
         BNE BAD_EXIT
?2       INX
         JSR CONVERT2ASCII
	 BEQ BAD_EXIT
         BCS BAD_EXIT
         CMP #32
         BCS BAD_EXIT
         STA !DAY
         INX
         LDA !0,X
         CMP #'-'
         BEQ ?3
         CMP #'/'
         BNE BAD_EXIT
?3       INX
         JSR CONVERT2ASCII
         BCS BAD_EXIT
         CMP #100
         BCS BAD_EXIT
         STA !YR

GOOD_EXIT:
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY
         PLA
         CLC
         RTL

BAD_EXIT:
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY
         PLA
         SEC
         RTL


CONVERT2ASCII EQU *  ;CONVERT 2 ASCII CHARs TO HEX

         LDA !0,X
         CMP #'X'
         BEQ ?2
         CMP #'x'
         BEQ ?2
         JSR ISDECIMAL
         BCS ?1
         AND #LOWNIB
         ASL A        ;MULTIPLY BY 10
	 STA <TMP8
         ASL A
         ASL A
         CLC
	 ADC <TMP8
	 STA <TMP8
         INX
         LDA !0,X
         JSR ISDECIMAL
         BCS ?1
         AND #LOWNIB
         CLC
	 ADC <TMP8
?1       RTS

?2       INX
         CLC
         LDA #$FF
         RTS

;*  ROUTINE:  SET_TIME
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character
;*       buffer that contains an update string.
;*
;*     The updating format  = HH:MM:SS(null).  The null termination
;*       is unnecessary.
;*
;*     The Carry Bit will be set upon return if a format error
;*       is found.
;*
 
SET_TIME:

         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         SEP #M8
	 LONGA OFF

         JSR CONVERT2ASCII
         BCS ST_EXIT
         CMP #24
         BCS ST_EXIT
         STA !HR
         INX
         LDA !0,X
         CMP #':'
         BNE ST_EXIT
         INX
         JSR CONVERT2ASCII
         BCS BAD_EXIT
         CMP #60
         BCS ST_EXIT
         STA !MIN
         INX
         LDA !0,X
         CMP #':'
         BNE ST_EXIT
         INX
         JSR CONVERT2ASCII
         BCS BAD_EXIT
         CMP #60
         BCS ST_EXIT
         STA !SEC

	 BRL GOOD_EXIT


ST_EXIT  BRL BAD_EXIT

	 PAGE

;*  ROUTINE:  SET_ALARM
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character
;*       buffer that contains an update string.
;*
;*     The updating format  = HH:MM:SS(null).  The null termination
;*       is unnecessary.
;*
;*     The Carry Bit will be set upon return if a format error
;*       is found.
;*
 
SET_ALARM:

         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         SEP #M8
	 LONGA OFF

         JSR CONVERT2ASCII
         BCS SA_EXIT
         CMP #24
         BCS SA_EXIT
         STA !AHR
         INX
         LDA !0,X
         CMP #':'
         BNE SA_EXIT
         INX
         JSR CONVERT2ASCII
         BCS SA_EXIT
         CMP #60
         BCS SA_EXIT
         STA !AMIN
         INX
         LDA !0,X
         CMP #':'
         BNE SA_EXIT
         INX
         JSR CONVERT2ASCII
         BCS SA_EXIT
         CMP #60
         BCS SA_EXIT
         STA !ASEC

	 LDA #ALRMENAB	 ;TURN ON ALARM CHECK
         TSB FLAGS

	 BRL GOOD_EXIT

SA_EXIT:
	 BRL BAD_EXIT




;*  ROUTINE:  RESET_ALARM
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Entering this routine causes the ALARM to be disabled.
;*   
;*
 
RESET_ALARM:

         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         SEP #M8
	 LONGA OFF

	 
	 LDA #ALRMENAB+ALRMIRQ	 ;TURN OFF ALARM CHECK
         TRB FLAGS

  	 LDA #$FF
         LDX #0
?1       STA !ADAYWK,X
         INX
         CPX #7
         BNE ?1

	 BRL GOOD_EXIT


;*  ROUTINE:  GET_ALARM_STATUS
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*  
;*     This routine returns with the results in the Areg and the
;*	   Carry bit.  If Cy = 1 then the ALARM has been triggered.
;*         If the Areg = 0  the ALARM hasn not been set. 
;*
;*     This routine will reset any ALARM that has been triggered.
;*  
;*
 
GET_ALARM_STATUS:


         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         SEP #M8
	 LONGA OFF

	 LDA #ALRMIRQ
         TRB FLAGS
         BNE ALARM_SET

	 LDA #ALRMENAB	 ;TURN ON ALARM CHECK
         BIT FLAGS
	 BNE ?1
	 LDA #0

?1       PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY
         CLC
         ORA #0         ;RESTORE Areg FLAGS
         RTL


ALARM_SET PLB           ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY
         SEC
         RTL




;*  ROUTINE:  READ_ALARM
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character buffer.
;*
;*     The returned format  = HH:MM:SS(null).  The null termination
;*       is for the C programmers.
;*
;*
;*
 
READ_ALARM:


         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         LDA !AHR
         CMP #$FF
         BEQ ?1         ;ALARM DONT CARE CODE

         JSR B_DCONV

         LDA #':'
         STA !2,X
         STA !5,X
         BRA ?2

?1       LDA #'x'
         STA !0,X
         STA !1,X

?2       INX
         INX
         INX
         LDA !AMIN
         CMP #$FF
         BEQ ?3         ;ALARM DONT CARE CODE

         JSR B_DCONV
         BRA ?4

?3       LDA #'x'
         STA !0,X
         STA !1,X

?4       INX
         INX
         INX 
         LDA !ASEC
         CMP #$FF
         BEQ ?5         ;ALARM DONT CARE CODE

         JSR B_DCONV
         BRA ?6

?5       LDA #'x'
         STA !0,X
         STA !1,X


?6       LDA #0
         STA !2,X

	 BRL GOOD_EXIT

	 PAGE

CLOCK_CK_SUM EQU *

	 GLOBAL CLOCK_CK_SUM

         PHA
         PHX
	 PHP
         REP #X8
	 LONGI ON

         LDX #DFLTSEND-DFLTS-1 ;LOAD TOD CHECKSUM
         LDA #00
         CLC
?1_0     ADC !DAYWK-1,X
         DEX
	 BNE ?1_0
         ADC T4LL       ;USE TIMER #4 CLK
         ADC T4LH       ;FOR CALCULATING TODCKS
         EOR #$FF       ;USED IN LOW POWER MODE
         STA !TODCKS

	 PLP
         PLX
         PLA
         RTS


         STTL 'R_CLOCK.ASM - Time of day clock IRQ routine'
	 PAGE


;* Routine:  TODIRQ
;*
;* Reg Used: ACC,Y,X
;* Var Used: SEC,MIN,HR,DAY,MONTH,YR,DAYWK,DAYLIT
;*           ASEC,AMIN,AHR,ADAY,AMONTH,AYR,ADAYWK
;* Routines Called: NONE
;* Returned Reg: NONE
;*

	 global TODIRQ

TODIRQ   EQU *          ;MONITOR TIME OF DAY IRQ
         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DATA BANK REG TO PAGE 0
         PEA #$0000
         PLB            ;SET BANK TO ZERO
         PLB
         SEP #M8+X8     ;SET X & Acc SHORT

	 LONGA OFF
	 LONGI OFF

         LDA #T1FLG     ;RESET TIMER 1 IRQ
         STA  TIFR

TOD_AGIN:
         INC !SEC        ;INCREMENT SECONDS      
         LDA !SEC
         CMP #60
         BEQ ?CL1
         CMP #55
         BCS EXITOCT
         LDA #RES_COMP
         TRB FLAGS
         BEQ EXITOCT
         INC !SEC        ;INCREMENT SECONDS      
         INC !SEC        ;INCREMENT SECONDS      
         INC !SEC        ;3 SEC'S TOTAL!
         BRA EXITOCT
 
?CL1     STZ !SEC        ;ROLLED OVER      

         INC !MIN        ;INCREMENT MINUTES
         LDA #60
         CMP !MIN
         BNE EXITOCT
         STZ !MIN        ;ROLLED OVER      

         INC !HR         ;INCREMENT HOUR
         LDA #DATE_CHK
         TSB FORMAT_FLAGS ;FOR DISPLAY UPDATE
         LDA !HR
         CMP #1
         BNE TODINT8
OCTOBER  LDA #DAYLITFLG ;IS DAYLIGHT SAVINGS ON
         BIT !DAYLIT
         BEQ EXITOCT
         LDA !MONTH
         CMP #10        ;IS IT OCTOBER      
         BNE EXITOCT
         LDA !DAYWK      ;IS IT SUNDAY      
         CMP #$01
         BNE EXITOCT    ;NO      
         LDA !DAY        ;IS IT LAST SUNDAY      
         CMP #25
         BCC EXITOCT
         LDA #DAYLPROG  ;CK IF ALREADY SET BACK      
         TRB !DAYLIT
         BNE EXITOCT
         TSB !DAYLIT
         STZ !HR
EXITOCT  BRA T1EXIT


TODINT8  EQU *
         CMP #24
         BCC EXITA6
         STZ !HR         ;ROLLED OVER      
EXITA6   LDA !HR
         BEQ TODINT9
         BRA T1EXIT

TODINT9  INC !DAYWK
         LDA !DAYWK
         CMP #7
         BCC INCDAY
         LDA #1
         STA !DAYWK      ;ROLLED OVER      

INCDAY   INC !DAY
         LDA #DAYLITFLG ;IS DAY LIGHT SAVINGS ON      
         BIT !DAYLIT
         BEQ INCADAY    ;NO      
         LDA !MONTH
         CMP #4         ;IS IT APRIL      
         BNE INCADAY
         BRL APRIL

INCADAY  LDA !DAY        ;INCREMENT DAYS
         LDX !MONTH
         CMP !LASTDY-1,X
         BCC T1EXIT

         CPX #2         ;INCREMENT MONTH      
         BNE INCMTH     ;NOT FEBRUARY      
         LDA !YR
	 AND <%00000011  ;IS IT LEAP YR
         BNE INCMTH

         LDA !DAY        ;ITS FEB AND LEAP YR      
         CMP #29
         BEQ T1EXIT
	 JSL SEND_BEEP
INCMTH   LDY #1         ;ROLLED OVER
         STY !DAY
         INC !MONTH
         LDA !MONTH
         CMP #13
         BCC T1EXIT
         STY !MONTH      ;MONTH 1= JAN      

         INC !YR


T1EXIT   EQU *
         LDA #TIME_CHK  ;FOR DISPLAY UPDATE
         TSB FORMAT_FLAGS
   
         LDA !FLAGS      ;CK IF ALARM ENABLED      
         BIT #ALRMENAB
         BEQ EXITA
                        ;CHK IF WE HAVE AN ALARM      
         LDX #0
CKALARM  LDA !AHR,X
         CMP #$FF
         BEQ CKAL1
         CMP !HR,X
         BNE EXITA

CKAL1    INX
         CPX #3
         BNE CKALARM
         LDA #ALRMIRQ   ;SET ALARM FLAG      
         TSB FLAGS
	 STZ <T_TIME
	 STZ <T_TIME+1

EXITA:
         JSR CLOCK_CK_SUM   ;DO CLOCK CHKSUM

         REP #X8
         LONGI ON
   
         LDX PD_TIMER
         BEQ ?66
         DEX
         STX PD_TIMER
         BNE ?66


	 LDX #20000
?XA      DEX
         BNE ?XA

         JSL ENTER_LOW_POWER_MODE

?66      PLB            ;RESTORE SIZE OF Acc & X/Y REGS
         PLD
	 PLP
         PLX
         PLY
         PLA
         RTI



APRIL    LDA !DAYWK      ;IS IT SUNDAY 
         CMP #$01
         BNE APR0       ;NO      
         LDA !DAY        ;IS IT 1ST SUNDAY      
         CMP #8
         BCC APR1
APR0     BRL INCADAY


APR1     LDA #1
         STA !HR
         BRA T1EXIT



	 PAGE

;*  ROUTINE:  READ_DATE
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character buffer.
;*
;*     The returned format  = MM-DD-YY(null).  The null termination
;*       is for the C programmers.
;*
;*
;*
 
READ_DATE:


         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         LDA !MONTH
         JSR B_DCONV

         LDA #'-'
         STA !2,X
         STA !5,X

         INX
         INX
         INX
         LDA !DAY
         JSR B_DCONV

         INX
         INX
         INX
         LDA !YR
         JSR B_DCONV

         LDA #0
         STA !2,X

	 BRL GOOD_EXIT


;*  ROUTINE:  READ_TIME
;*
;*     WARNING  This routine must be entered with a JSL command.
;*
;*     Enter with a 16 bit Xreg pointing to a nine character buffer.
;*
;*     The returned format  = HH:MM:SS(null).  The null termination
;*       is for the C programmers.
;*
;*
;*
 
READ_TIME:

         PHA
         PHY
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

         LDA !HR
         JSR B_DCONV

         LDA #':'
         STA !2,X
         STA !5,X

         INX
         INX
         INX
         LDA !MIN
         JSR B_DCONV

         INX
         INX
         INX
         LDA !SEC
         JSR B_DCONV

         LDA #0
         STA !2,X

	 BRL GOOD_EXIT

B_DCONV EQU *   ;CONVERT BINARY NUMBER TO DUODECIMAL

         PHX
         PHA
         AND #LOWNIB
         XBA
         LDA #0
         XBA
         TAX
         LDA !BINDECL,X
	 STA <TMP8
         PLA
         LSR A
         LSR A
         LSR A
         LSR A
         TAX
         LDA !BINDECH,X
         CLC
         SED
	 ADC <TMP8
         CLD
         PLX

         PHA            ;OUTPUT DATA TO BUFFER VIA Xreg
         AND #LOWNIB
         ORA #$30
         STA !1,X
         PLA
         LSR A
         LSR A
         LSR A
         LSR A
         ORA #$30
         STA !0,X

         RTS         

	 ENDS

	 APPEND R_SERIAL.ASM
