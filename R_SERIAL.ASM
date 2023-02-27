;FILE  R_Serial.asm
;DATE: 12-17-1994

	 STTL 'ROM SERIAL I/O ROUTINES - UARTS'
	 PAGE

	 CODE

;* Routine:  IRQ_SERIAL_RCV0
;*
;* This is the interrupt routine that buffers characters
;*   received from the Keyboard.
;*
;* All REGISTERS are preserved!
;*
;* Returned Reg: NONE
;*
;*
;* Important Variables:
;*   SINEND0  index for last character removed from buffer
;*   SININDX0  index for last character placed in buffer
;*   SIN_BUF0  base location of keyboard input buffer
;*   SINCNT0   buffer size



                        ;CALLED BY IRQ ROUTINE      
IRQAR0 EQU *   ;QUEUE UP SERIAL BYTE 
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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #01	;CLEAR INTERRUPT
         STA UIFR       ;Flag Reg

	 LDA ARTD0      ;GET DATA CHAR
         PHA
         CMP #' '       ;USE SPACE TO CLEAR ALARM
         BNE RECV0_R8
       
         LDA #ALRMIRQ   ;HAS ALARM BEEN SET?
         BIT FLAGS
         BEQ RECV0_R8   ;NO

         LDA #ALRMRST   ;WILL CAUSE TIMERS TO RESET ALARM
         TSB FLAGS

RECV0_R8 LDY <SININDX0   ;CHECK FOR BUFFER FULL
         INY
	 CPY <SINCNT0    ;BUFFER SIZE
	 BNE RECV0_R9
	 LDY #0         ;OVER RAN END OF BUFFER
RECV0_R9 CPY <SINEND0
         BNE RECV0_R11	

	 LDA #$40	;Just overran the input buffer
	 TSB <STATUS_S0  ;SET the STATUS FLAG
	 LDX <SINEND0    ;THROW AWAY 1 CHAR..THE
         INX		;OUTPUT IS NOT KEEPING UP!
	 CPX <SINCNT0
         BNE RECV0_R10	
         LDX #0		;OVER-RAN END OF BUFFER
RECV0_R10 STX <SINEND0   ;SAVE OUTPUT POINTER
RECV0_R11 STY <SININDX0  ;SAVE INPUT PTR
	 PLA
	 STA (SIN_BUF0),Y ;STORE DATA

	 LDA #SFLG
	 TSB <SFLAG0     ;SET CHAR READY FLAG

	 INY		;SEE IF BUFFER NEARING FULL
         INY
	 INY
         INY
	 INY
	 CPY <SINCNT0    ;OUTPUT PTR
	 BCC RECV0_R12
	 SEC
	 SBC <SINCNT0
RECV0_R12 CPY <SINEND0
	 BEQ RECV0_R14	;OK  NOTE: It is not posible
	 BRL REC_DONE   ;to jump past the output ptr
			;because we check after each
			;char inputted.


RECV0_R14 LDA #BEEP     ;flag to computer for input overflow
	 TSB <SFLAG0
	 BRL REC_DONE
              
	 PAGE
;* Routine:  IRQAT0
;*
;* Var Used: SFLAG0,SOUTINDX0,SOUTEND0,SOUTCNT0
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SOUTENDO   index for last character STORED in buffer
;*   SOUTINDX0  index for last character REMOVED from buffer
;*   SOUT_BUF0  base location of keyboard output buffer
;*   SOUTCNT0   keyboard output buffer size

                           ;CALLED BY IRQ ROUTINE      
IRQAT0 EQU *               ;DEQUEUE SERIAL BYTE 
         PHA               ;FROM OUTPUT BUFFER      
         PHY               ;SEE OUTCH_PORTX ROUTINE      
         PHX
	 PHP
         PHD               ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD               ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000        ;SET DATA BANK TO 0
         PLB
         PLB
         SEP #M8           ;SET Acc SHORT
	 REP #X8           ;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #02           ;CLEAR INTERRUPT
         STA UIFR

         LDA ACSR0	   ;are we waiting for the serial reg
         AND #DISCH          ;to clear?
         BEQ TRAN0_2B      ;NO

         LDA PD4           ;DSR0 = P45
         AND #$20
         BNE TRAN0_3A	   ;DSR0 IS FALSE!

TRAN0_2B LDY <SOUTINDX0     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND0
         BNE TRAN0_3	   ;KEEP GOING

TRAN0_2C LDA ACSR0         ;DISABLE SERIAL XMIT      
         AND #DISCH          ;EVERYTHING IS OUT OF      
         BNE TRAN0_3A	   ;SERIAL XMIT REG
         LDA #00	   ;SEND NULL TO CLEAR INTERRUPT
         BRA TRAN0_1


TRAN0_1A BIT #SNDOVF	   ;DID WE HAVE AN OVERFLOW CONDITION?
         BEQ TRAN0_2B	   ;NO
         BRA TRAN0_3A	   ;YES

TRAN0_3  EQU *
         INY
	 CPY <SOUTCNT0      ;DID WE ROLL OVER IN THE BUFFER

         BCC TRAN0_0	   ;NO
	 LDY #0            ;YEP
TRAN0_0  STY <SOUTINDX0
         LDA (SOUTBUF0),Y    ;GET DATA FROM QUEUE      
TRAN0_1 EQU *
         STA ARTD0         ;SEND DATA   

TRAN0_2  LDA <SFLAG0
         BIT #SNDOVF
         BNE TRAN0_3A	   ;WE'RE THROUGH

	 LDY <SOUTINDX0
	 CPY <SOUTEND0      ;IS BUFF EMPTY
         BEQ TRAN0_3B	   ;YES  START SHUTDOWN
         LDA #DISCH
         TRB ACSR0
         LDA #SON	   ;TURN OFF DISCHARE MODE
         TSB ACSR0	   ;AND SET TRANS IRQ'S
         BRL TRANS_DONE

TRAN0_3A EQU *		   ;SHUT DOWN UART OUTPUT
         LDA #Bit1         ;set the output high to prevent
         TSB PD6           ;FALSING when we shut it off.
         LDA #SON+DISCH
         TRB ACSR0
         BRL TRANS_DONE

TRAN0_3B EQU *		   ;START SHUTDOWN
         LDA #SON+DISCH      ;TURN ON XMIT & DISCHARGE
         TSB ACSR0
         BRL TRANS_DONE

	 PAGE


;REAL TIME INPUT PORT 1	--- PRINTER


;* Routine:  IRQAR1
;*
;* This routine is called by the interrrupt vector
;*   and puts characters from the printer into the
;*   printer input buffer.  XON/XOFF protocal is used
;*   to control data flow to the printer.
;*
;* Reg Used: ACC 
;*
;* Var Used: SFLAG1,SININDX1,SINEND1,SINCNT1
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SINEND1   index for last character STORED in buffer
;*   SININDX1  index for last character REMOVED from buffer
;*   SIN_BUF1  base location of printer output buffer
;*   SINCNT1   printer output buffer size


IRQAR1 EQU *   ;QUEUE UP SERIAL BYTE 
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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #04	;CLEAR INTERRUPT
         STA UIFR

	 CLC		;Clear C
	 LDA ARTD1      ;GET DATA CHAR
         PHA	  
	 LDA <SFLAG1     ;CHECK FOR XON/XOFF OPERATION
         BIT #XONOFLG
	 BEQ RECV1_R8	;NOT XON/XOFF PROTOCALL
	 PLA
	 PHA
	 CMP #XOFF
         BEQ RECV1_XOFF
         CMP #XON
         BEQ RECV1_XON
RECV1_R8 LDY <SININDX1   ;CHECK FOR BUFFER FULL
         INY
	 CPY <SINCNT1    ;BUFFER SIZE
	 BNE RECV1_R9
	 LDY #0         ;OVER RAN END OF BUFFER
RECV1_R9 CPY <SINEND1
         BNE RECV1_R11	

	 LDA #$40	;Just overran the input buffer
	 TSB <STATUS_S1  ;SET the STATUS FLAG
	 LDX <SINEND1    ;THROW AWAY 1 CHAR..THE
         INX		;OUTPUT IS NOT KEEPING UP!
	 CPX <SINCNT1
         BNE RECV1_R10	
         LDX #0		;OVER-RAN END OF BUFFER
RECV1_R10 STX <SINEND1   ;SAVE OUTPUT POINTER
RECV1_R11 STY <SININDX1  ;SAVE INPUT PTR
	 PLA
	 STA (SIN_BUF1),Y ;STORE DATA

	 LDA #SFLG
	 TSB <SFLAG1     ;SET CHAR READY FLAG

	 INY		;SEE IF BUFFER NEARING FULL
         INY
	 INY
         INY
	 INY
	 CPY <SINCNT1    ;OUTPUT PTR
	 BCC RECV1_R12
	 SEC
	 SBC <SINCNT1
RECV1_R12 CPY <SINEND1
	 BEQ RECV1_R14	;OK  NOTE: It is not posible
	 BRL REC_DONE   ;to jump past the output ptr
			;because we check after each
			;char inputted.


RECV1_R14 LDA <SFLAG1    ;CHECK PROTOCAL
	 BIT #XONOFLG
	 BEQ RECV1_DTR
	 LDA #LASTXONOF
	 TRB <SFLAG1
	 BNE RECV1_R15
	 BRL REC_DONE	;XOFF ALREADY SENT

RECV1_R15 LDA #SXOFFLG
	 TSB <SFLAG1
	 BRA REC1_DONET

RECV1_XOFF PLA		;ADJUST STACK PTR
         LDA #SNDOVF
	 TSB <SFLAG1     ;MAKE INPUT STOP
	 BRA REC1_DONET


RECV1_XON PLA
	 LDA #SNDOVF
	 TRB <SFLAG1     ;START UP INPUT AGAIN
REC1_DONET LDA #3
	 TSB ACSR1	;START UP OUTPUT
         BRL REC_DONE


RECV1_DTR LDA #4
	 TSB PD5	;SET DTR HI
	 BRL REC_DONE


	 PAGE

;* Routine:  IRQAT1    REAL-TIME PRINTER OUTPUT
;*
;*  This routine takes data from the printer output
;*    buffer and sends it out the UART port. It is
;*    called by a hardware interrupt vector.
;*
;* Var Used: SFLAG1,SOUTINDX1,SOUTEND1,SOUTCNT1
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SOUTEND1   index for last character STORED in buffer
;*   SOUTINDX1  index for last character REMOVED from buffer
;*   SOUT_BUF1  base location of printer output buffer
;*   SOUTCNT1   PRINTER output buffer size
;*
;*
                        ;CALLED BY IRQ ROUTINE      
IRQAT1 EQU *   ;DEQUEUE SERIAL BYTE 
         PHA            ;FROM OUTPUT BUFFER      
         PHY            ;SEE OUTCH_PORTX ROUTINE      
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #08	;CLEAR INTERRUPT
         STA UIFR

	 LDA <SFLAG1     ;CK IF WE ARE OVERFLOWING
         AND #SXOFFLG+SXONFLG
         BEQ TRAN1_0A       ;QUICK CK FOR CNTRL FLGS      
         CMP #SXOFFLG+SXONFLG
         BEQ TRAN1_ERR
         BIT #SXOFFLG
         BNE TRAN1_XOFF    ;SEND XOFF      

TRAN1_XON EQU *
         LDA #SXONFLG      ;Turn off XON FLG & send XON
	 TRB <SFLAG1
         LDA #XON
         BRA TRAN1_1


TRAN1_XOFF  EQU *     	   ;Turn off XOFF FLG + LASTXON FLG
			   ;and send XON
         LDA #SXOFFLG+LASTXONOF
	 TRB <SFLAG1
         LDA #XOFF
         BRA TRAN1_1

TRAN1_ERR EQU *            ;both XON & XOFF FLGs are set..they
                           ;cancel one another!
         LDA #SXONFLG+SXOFFLG
	 TRB <SFLAG1

TRAN1_0A EQU *
         LDA ACSR1         ;Are we waiting for the serial reg
         BIT #DISCH          ;to clear?.
         BEQ TRAN1_2B      ;NO

TRAN1_1B LDA <SFLAG1        ;XON/ XOFF PROTOCALL?
         BIT #XONOFLG
         BNE TRAN1_1A      ;YES
                           ;CHECK IF WE HAVE HRDW HS & DSR1 IS LOW
         LDA PD5           ;DSR1 = P53
         AND #Bit3         
         BNE TRAN1_3A      ;DSR1 IS FALSE

TRAN1_2B LDY <SOUTINDX1     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND1
         BNE TRAN1_3       ;KEEP GOING
         LDA ACSR1         ;DISABLE SERIAL XMIT      
         AND #DISCH          ;EVERYTHING IS OUT OF      
         BNE TRAN1_3A      ;THE SERIAL XMIT REG
         LDA #00           ;SEND NULL TO CLEAR INTERRUPT
         BRA TRAN1_1

TRAN1_1A BIT #SNDOVF       ;DID WE HAVE AN OVERFLOW CONDITION?
         BEQ TRAN1_2B      ;NO
         BRA TRAN1_3A      ;YES

TRAN1_3  EQU *
         INY
	 CPY <SOUTCNT1     ;DID WE ROLL OVER IN THE BUFFER

         BCC TRAN1_0       ;NO
	 LDY #0            ;YEP
TRAN1_0  STY <SOUTINDX1

         LDA (SOUTBUF1),Y    ;GET DATA FROM QUEUE      
TRAN1_1  EQU *
         STA ARTD1         ;SEND DATA   

	 LDA <SFLAG1        ;CHECK PROTOCALL
         BIT #XONOFLG
         BNE TRAN1_2       ;XON/XOFF

         LDA PD5           ;DTR PROTOCALL
         AND #Bit3         ;CHECK DSR LEAD FOR DTR IN
         BNE TRAN1_3A      ;P53 HI   --STOP!

TRAN1_2  LDA <SFLAG1
         BIT #SNDOVF
         BNE TRAN1_3A      ;WE'RE THROUGH  DISCHARGE IS DONE

	 LDY <SOUTINDX1
	 CPY <SOUTEND1      ;IS BUFF EMPTY
         BEQ TRAN1_3B      ;YES - START SHUTDOWN
         LDA #DISCH
         TRB ACSR1
         LDA #SON
         TSB ACSR1
         BRL TRANS_DONE

TRAN1_3A EQU *             ;SHUT DOWN UART OUTPUT
         LDA #Bit3         ;set the output high to prevent falsing
         TSB PD6           ;when we shut it off.
         LDA #SON+DISCH
         TRB ACSR1    
         BRL TRANS_DONE

TRAN1_3B EQU *             ;START SHUTDOWN
         LDA #SON+DISCH      ;TURN ON XMIT & DISCHARGE
         TSB ACSR1
         BRL TRANS_DONE


	 PAGE

;REAL TIME INPUT PORT 2	--- MODEM


;* Routine:  IRQAR2
;*
;* This routine is called by the interrrupt vector
;*   and places characters from the MODEM into the
;*   MODEM input buffer.  XON/XOFF protocal is used
;*   to control data flow to & from the MODEM.
;*
;* Reg Used: ACC 
;*
;* Var Used: SFLAG2,SININDX2,SINEND2,SINCNT2
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SINEND2;REAL TIME INPUT PORT 1	--- MODEM
;*   SININDX2  index for last character REMOVED from buffer
;*   SIN_BUF2  base location of MODEM input buffer
;*   SINCNT2   equate of MODEM input buffer size


;REAL TIME INPUT PORT 2	   MODEM computer

IRQAR2 EQU *   ;QUEUE UP SERIAL BYTE 
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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #$10	;CLEAR INTERRUPT
         STA UIFR

	 LDA ARTD2      ;GET DATA CHAR
         PHA
	 LDA <SFLAG2     ;CHECK FOR XON/XOFF OPERATION
         BIT #XONOFLG
	 BEQ RECV2_R8	;NOT XON/XOFF PROTOCALL
	 PLA
	 PHA
	 CMP #XOFF
         BEQ RECV2_XOFF
         CMP #XON
         BEQ RECV2_XON
RECV2_R8 LDY <SININDX2   ;CHECK FOR BUFFER FULL
         INY
	 CPY <SINCNT2    ;BUFFER SIZE
	 BNE RECV2_R9
	 LDY #0         ;OVER RAN END OF BUFFER
RECV2_R9 CPY <SINEND2
         BNE RECV2_R11	

	 LDA #$40	;Just overran the input buffer
	 TSB <STATUS_S2  ;SET the STATUS FLAG
	 LDX <SINEND2    ;THROW AWAY 1 CHAR..THE
         INX		;OUTPUT IS NOT KEEPING UP!
	 CPX <SINCNT2
         BNE RECV2_R10	
	 LDY #0         ;OVER-RAN END OF BUFFER
RECV2_R10 STX <SINEND2   ;SAVE OUTPUT POINTER
RECV2_R11 STY <SININDX2  ;SAVE INPUT PTR
	 PLA
	 STA (SIN_BUF2),Y ;STORE DATA

	 LDA #SFLG
	 TSB <SFLAG2     ;SET CHAR READY FLAG

	 INY		;SEE IF BUFFER NEARING FULL
         INY
	 INY
         INY
	 INY
	 CPY <SINCNT2    ;OUTPUT PTR
	 BCC RECV2_R12
	 SEC
	 SBC <SINCNT2
RECV2_R12 CPY <SINEND2
	 BEQ RECV2_R14	;OK  NOTE: It is not posible
	 BRL REC_DONE   ;to jump past the output ptr
			;because we check after each
			;char inputted.


RECV2_R14 LDA <SFLAG2    ;CHECK PROTOCAL
	 BIT #XONOFLG
	 BEQ RECV2_DTR
	 LDA #LASTXONOF
	 TRB <SFLAG2
	 BNE RECV2_R15
	 BRL REC_DONE	;XOFF ALREADY SENT

RECV2_R15 LDA #SXOFFLG
	 TSB <SFLAG2
	 BRA REC2_DONET

RECV2_XOFF PLA		;ADJUST STACK PTR
         LDA #SNDOVF
	 TSB <SFLAG2     ;MAKE INPUT STOP
	 BRA REC2_DONET


RECV2_XON PLA
	 LDA #SNDOVF
	 TRB <SFLAG2     ;START UP INPUT AGAIN
REC2_DONET LDA #3
	 TSB ACSR2	;START UP OUTPUT
         BRL REC_DONE


RECV2_DTR LDA #$10
	 TSB PD5	;SET DTR HI
	 BRL REC_DONE


	 PAGE


;* Routine:  IRQAT2    REAL-TIME MODEM OUTPUT
;*
;* This routine removes charaters from the MODEM
;*   output buffer and sends them out PORT 2.
;*   XON/XOFF protocal is used to control data flow.
;*
;* Var Used: SFLAG2,SOUTINDX2,SOUTEND2,SOUTCNT2
;*
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SOUTEND2   index for last character STORED in buffer
;*   SOUTINDX2  index for last character REMOVED from buffer
;*   SOUT_BUF2  base location of MODEM output buffer
;*   SOUTCNT2   equate of MODEM output buffer size
;*
;*
;* Returned Reg: NONE
;*
                        ;CALLED BY IRQ ROUTINE      
IRQAT2 EQU *   ;DEQUEUE SERIAL BYTE 
         PHA            ;FROM OUTPUT BUFFER      
         PHY            ;SEE OUTCH_PORTX ROUTINE      
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #$20	;CLEAR INTERRUPT
         STA UIFR

	 LDA <SFLAG2     ;CK IF WE ARE OVERFLOWING
         AND #SXOFFLG+SXONFLG
         BEQ TRAN2_0A       ;QUICK CK FOR CNTRL FLGS      
         CMP #SXOFFLG+SXONFLG
         BEQ TRAN2_ERR
         BIT #SXOFFLG
         BNE TRAN2_XOFF    ;SEND XOFF      

TRAN2_XON EQU *
         LDA #SXONFLG
	 TRB <SFLAG2
         LDA #XON
         BRA TRAN2_1


TRAN2_XOFF  EQU *

         LDA #SXOFFLG+LASTXONOF
	 TRB <SFLAG2
         LDA #XOFF
         BRA TRAN2_1

TRAN2_ERR EQU *

         LDA #SXONFLG+SXOFFLG
	 TRB <SFLAG2

TRAN2_0A EQU *
         LDA ACSR2
         AND #DISCH          ;XMIT IRQ ON
         BEQ TRAN2_2B

TRAN2_1B LDA <SFLAG2
         BIT #XONOFLG    
         BNE TRAN2_1A      ;XON/OFF PROTOCALL
                           ;DO WE HAVE HRDW HS & DSR2 IS LOW
         LDA PD5           ;DSR2 = NOT AVAILABLE
         AND #Bit5         ;DSR* ON PD5-5
         BNE TRAN2_3A

TRAN2_2B LDY <SOUTINDX2     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND2
         BNE TRAN2_3       ;DATA BUFFER NOT EMPTY
         LDA ACSR2         ;INITIATE SERIAL XMIT SHUTDOWN     
         AND #DISCH          ;HAVE WE INITIATED SHUTDOWN?
         BNE TRAN2_3A      ;YES
         LDA #00           ;NO..LETS START
         BRA TRAN2_1       ;FILL WITH NULL CHAR


TRAN2_1A BIT #SNDOVF       ;ARE WE IN XOFF STOP MODE?
         BEQ TRAN2_2B      ;NO
         BRA TRAN2_3A      ;YES SHUTDOWN AND EXIT

TRAN2_3 EQU *              ;SEND CHAR FROM BUFFER
         INY
	 CPY <SOUTCNT2     ;CHECK FOR POINTER ROLL-OVER

         BCC TRAN2_0       ;OK
	 LDY #0            ;ROLL AROUND TO BUFFER START
TRAN2_0  STY <SOUTINDX2

         LDA (SOUTBUF2),Y    ;GET DATA FROM QUEUE      
TRAN2_1 EQU *
         STA ARTD2         ;SEND DATA   

	 LDA <SFLAG2        ;CHECK PROTOCALL
         BIT #XONOFLG
         BNE TRAN2_2       ;XON/XOFF

         LDA PD5           ;DTR PROTOCALL
         AND #Bit5         ;CHECK DSR LEAD FOR DTR IN
         BNE TRAN2_3A      ;P55 HI   --STOP!

TRAN2_2  LDA <SFLAG2
         BIT #SNDOVF
         BNE TRAN2_3A      ;WE'RE THROUGH  DISCHARGE IS DONE

	 LDY <SOUTINDX2     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND2
         BEQ TRAN2_3B      ;START SHUTDOWN
         LDA #DISCH          ;TURN OFF SHUTDOWN MODE
         TRB ACSR2         ;IN CASE IT WAS ON
         LDA #SON
         TSB ACSR2
         BRL TRANS_DONE    ;EXIT


TRAN2_3A EQU *             ;*** TURN OFF UART ****
         LDA #Bit5         ;set the output high to prevent falsing
         TSB PD6           ;when we shut it off.
         LDA #SON+DISCH
         TRB ACSR2    
         BRL TRANS_DONE

TRAN2_3B EQU *             ;** START SHUTDOWN MODE **
         LDA #SON+DISCH      ;TURN ON SERIAL CLR INTR.
         TSB ACSR2
         BRL TRANS_DONE

	 PAGE
	 PAGE

;* Routine:  GET_BYTE_FROM_PC
;*
;* This routine returns a character in the "A" reg
;*  from the HOST input buffer. If the buffer
;*  is empty, a null char is returned and the "C"
;*  flag is set.
;*
;* This routine MUST be called using a JSL command!
;*
;* Routines Called: OUTCH3
;*
;* Returned Reg: Acc  
;* Returned Flags   If c is set no DATA is returned.
;*   Instead an error code is returned in the A Reg. 
;*   ERROR CODES:
;*   $00 on Return indicates NO DATA available.
;*   $80 on Return indicates ^C or ESCape received.
;*
;* Important Variables:
;*   SINEND2  index for last character removed from buffer
;*   SININDX2  index for last character placed in buffer
;*   SIN_BUF2  base location of HOST input buffer
;*   SINCNT2   HOST input buffer size



GET_BYTE_FROM_PC   EQU *


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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 CLC		  ;CLEAR C
	 LDA <SFLAG3       ;GET SERIAL BYTE
         AND #SFLG        ;FROM INPUT QUEUE      
         BNE P3_GETSD5

	 STZ <SDATA_SI3    ;No data RETURN A NULL
         BRA P3_RD_CH1

P3_GETSD5 SEI             ;PUT THERE BY RECSBYTE      
	 LDY <SINEND3      ;CK IF CURRENT QUEUE POS
         INY              ;POINT TO NXT DATA
	 CPY <SINCNT3     ;DO WE WRAP
         BCC P3_GETSD4
	 LDY #0           ;WE WRAPPED

P3_GETSD4 EQU *
	 STY <SINEND3
         LDA (SIN_BUF3),Y  ;GET DATA      
	 STA <SDATA_SI3
         CLI
	 CPY <SININDX3     ;IS SAME AS END OF QUEUE
         BNE P3_GETSD3

	 LDA <SFLAG3       ;CK IF XON/XOFF
         BIT #XONOFLG     ;OR HARDWARE HS      
         BEQ P3_GETSD1

         BIT #LASTXONOF   ;HAS XON ALREADY BEEN SENT?      
         BNE P3_GETSD2

         LDA #SXONFLG+LASTXONOF 
	 TSB <SFLAG3

         LDA ACSR3
         BIT #SON
         BNE P3_GETSD2
         LDA #SON+DISCH
         TSB ACSR3
         BRA P3_GETSD2

P3_GETSD1 EQU *           ;HANDLE HARDWARE HS
         LDA #$80         ;DTR LOW, OK FOR      
         TRB PD5          ;OTHER GUY TO SEND      
P3_GETSD2 EQU *
         LDA #SFLG        ;NO MORE SERIAL CHARS
	 TRB <SFLAG3

P3_GETSD3 LDA <SFLAG3      ;CHK IF ECHO
         AND #ECHOFF
         BEQ P3_RD_CH0
	 LDA <SDATA_SI3
         JSL SEND_BYTE_TO_PC  ;ECHO BACK INPUT      

P3_RD_CH0 EQU *

         LDX #POWER_DOWN_COUNT
         STX PD_TIMER

         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY     
         CLC   
	 LDA <SDATA_SI3
         RTL

P3_RD_CH1 EQU *
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY     
         SEC            ;NO DATA - return a NULL
	 LDA #0         ;with C flag set
         RTL




	 PAGE


;REAL TIME INPUT PORT 3	--- PC


;* Routine:  IRQAR3
;*
;* This routine is called by the interrrupt vector
;*   and puts characters from the printer into the
;*   PC input buffer.  XON/XOFF protocal is used
;*   to control data flow through the PC.
;*
;*
;* Var Used: SFLAG3,SOUTINDX3,SOUTEND3,SOUTCNT3
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SINEND3 index for last character stored in buffer
;*   SININDX3  index for last character REMOVED from buffer
;*   SIN_BUF3  base location of P.C. output buffer
;*   SINCNT3   P.C. output buffer size


;REAL TIME INPUT PORT 3	  PC

IRQAR3 EQU *   ;QUEUE UP SERIAL BYTE 
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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #$40	;CLEAR INTERRUPT
         STA UIFR

	 LDA ARTD3      ;GET DATA CHAR
         PHA
	 LDA <SFLAG3     ;CHECK FOR XON/XOFF OPERATION
         BIT #XONOFLG
	 BEQ RECV3_R8	;NOT XON/XOFF PROTOCALL
	 PLA
	 PHA
	 CMP #XOFF
         BEQ RECV3_XOFF
         CMP #XON
         BEQ RECV3_XON
RECV3_R8 LDY <SININDX3   ;CHECK FOR BUFFER FULL
         INY
	 CPY <SINCNT3    ;BUFFER SIZE
	 BNE RECV3_R9
	 LDY #0         ;OVER RAN END OF BUFFER
RECV3_R9 CPY <SINEND3
         BNE RECV3_R11	

	 LDA #$40	;Just overran the input buffer
	 TSB <STATUS_S3  ;SET the STATUS FLAG
	 LDX <SINEND3    ;THROW AWAY 1 CHAR..THE
         INX		;OUTPUT IS NOT KEEPING UP!
	 CPX <SINCNT3
         BNE RECV3_R10	
         LDX #0		;OVER-RAN END OF BUFFER
RECV3_R10 STX <SINEND3   ;SAVE OUTPUT POINTER
RECV3_R11 STY <SININDX3  ;SAVE INPUT PTR
	 PLA
	 STA (SIN_BUF3),Y ;STORE DATA

	 LDA #SFLG
	 TSB <SFLAG3     ;SET CHAR READY FLAG

	 INY		;SEE IF BUFFER NEARING FULL
         INY
	 INY
         INY
	 INY
	 CPY <SINCNT3    ;OUTPUT PTR
	 BCC RECV3_R12
	 SEC
	 SBC <SINCNT3
RECV3_R12 CPY RECV3_R14	;OK  NOTE: It is not posible
	 BRL REC_DONE   ;to jump past the output ptr
			;because we check after each
			;char inputted.


RECV3_R14 LDA <SFLAG3    ;CHECK PROTOCAL
	 BIT #XONOFLG
	 BEQ RECV3_DTR
	 LDA #LASTXONOF
	 TRB <SFLAG3
	 BNE RECV3_R15
	 BRL REC_DONE	;XOFF ALREADY SENT

RECV3_R15 LDA #SXOFFLG
	 TSB <SFLAG3
	 BRA RECV3_DONET

RECV3_XOFF PLA		;ADJUST STACK PTR
         LDA #SNDOVF
	 TSB <SFLAG3     ;MAKE INPUT STOP
	 BRA RECV3_DONET


RECV3_XON PLA
	 LDA #SNDOVF
	 TRB <SFLAG3     ;START UP INPUT AGAIN
RECV3_DONET LDA #3
	 TSB ACSR3	;START UP OUTPUT
         BRL REC_DONE


RECV3_DTR LDA #$80
	 TSB PD5	;SET DTR HI

                        ;CALLED BY IRQ ROUTINE      


	 PAGE

;* Routine:  IRQAT3    REAL-TIME PC OUTPUT
;*
;* This routine removes charaters from the PC
;*   output buffer and sends them out PORT 3.
;*   XON/XOFF protocal is used to control data flow.
;*
;* Var Used: SFLAG3,SOUTINDX3,SOUTEND3,SOUTCNT3
;*
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SOUTEND2   index for last character STORED in buffer
;*   SOUTINDX2  index for last character REMOVED from buffer
;*   SOUT_BUF2  base location of HOST output buffer
;*   SOUTCNT2   HOST output buffer size
;*
;*
;* Returned Reg: NONE
;*
 

;REAL TIME OUTPUT PORT 3  PC

                        ;CALLED BY IRQ ROUTINE      

                        ;CALLED BY IRQ ROUTINE      
IRQAT3 EQU *   ;DEQUEUE SERIAL BYTE 
         PHA            ;FROM OUTPUT BUFFER      
         PHY            ;SEE OUTCH_PORTX ROUTINE      
         PHX
	 PHP
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG

	 LONGA OFF
	 LONGI ON

	 LDA #$80	;CLEAR INTERRUPT
         STA UIFR

	 LDA  <SFLAG3     ;CK IF WE ARE OVERFLOWING
         AND #SXOFFLG+SXONFLG
         BEQ TRAN3_0A       ;QUICK CK FOR CNTRL FLGS      
         CMP #SXOFFLG+SXONFLG
         BEQ TRAN3_ERR
         BIT #SXOFFLG
         BNE TRAN3_XOFF    ;SEND XOFF      

TRAN3_XON EQU *
         LDA #SXONFLG
	 TRB <SFLAG3
         LDA #XON
         BRA TRAN3_1


TRAN3_XOFF  EQU *

         LDA #SXOFFLG+LASTXONOF
	 TRB <SFLAG3
         LDA #XOFF
         BRA TRAN3_1

TRAN3_ERR EQU *

         LDA #SXONFLG+SXOFFLG
	 TRB <SFLAG3

TRAN3_0A EQU *
         LDA ACSR3
         AND #DISCH          ;XMIT IRQ ON
         BEQ TRAN3_2B

TRAN3_1B LDA <SFLAG3
         BIT #XONOFLG    
         BNE TRAN3_1A      ;XON/OFF PROTOCALL
                           ;DO WE HAVE HRDW HS & DSR2 IS LOW
         LDA PD5           ;DSR2 = PD5-7
         AND #Bit7
         BNE TRAN3_1

TRAN3_2B LDY <SOUTINDX3     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND3
         BNE TRAN3_3       ;DATA BUFFER NOT EMPTY
         LDA ACSR3         ;INITIATE SERIAL XMIT SHUTDOWN     
         AND #DISCH          ;HAVE WE INITIATED SHUTDOWN?
         BNE TRAN3_3A      ;YES
         LDA #00           ;NO..LETS START
         STA ARTD3         ;FILL WITH NULL CHAR
         BRA TRAN3_3B      ;START SHUTDOWN & EXIT


TRAN3_1A BIT #SNDOVF       ;ARE WE IN XOFF STOP MODE?
         BEQ TRAN3_2B      ;NO
         BRA TRAN3_3A      ;YES SHUTDOWN AND EXIT

TRAN3_3 EQU *              ;SEND CHAR FROM BUFFER
         INY
	 CPY <SOUTCNT3     ;CHECK FOR POINTER ROLL-OVER

         BCC TRAN3_0       ;OK
	 LDY #0            ;ROLL AROUND TO BUFFER START
TRAN3_0  STY <SOUTINDX3

	 LDA (SOUTBUF3),Y    ;GET DATA FROM QUEUE
TRAN3_1 EQU *
         STA ARTD3         ;SEND DATA   

	 LDA <SFLAG3        ;CHECK PROTOCALL
         BIT #XONOFLG
         BNE TRAN3_2       ;XON/XOFF

         LDA PD5           ;DTR PROTOCALL
         AND #Bit7         ;CHECK DSR LEAD FOR DTR IN
         BNE TRAN3_3A      ;PD5-7 HI   --STOP!

TRAN3_2  LDA <SFLAG3
         BIT #SNDOVF
         BNE TRAN3_3A      ;WE'RE THROUGH  DISCHARGE IS DONE

	 LDY <SOUTINDX3     ;IS BUFFER NOW EMPTY
	 CPY <SOUTEND3
         BEQ TRAN3_3B      ;START SHUTDOWN
         LDA #DISCH        ;TURN OFF SHUTDOWN MODE
         TRB ACSR3         ;IN CASE IT WAS ON
         LDA #SON
         TSB ACSR3
         BRA TRANS_DONE    ;EXIT


TRAN3_3A EQU *             ;*** TURN OFF UART ****
         LDA #Bit7         ;set the output high to prevent falsing
         TSB PD6           ;when we shut it off.
         LDA #SON+DISCH
         TRB ACSR3    
         BRA TRANS_DONE

TRAN3_3B EQU *             ;** START SHUTDOWN MODE **
         LDA #SON+DISCH    ;TURN ON SERIAL CLR INTR.
         TSB ACSR3


REC_DONE EQU *

TRANS_DONE EQU *
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY            ;IRQ IS DONE!
         PLA
         RTI

	 PAGE


;* Routine:  SEND_BYTE_TO_PC
;*
;* This routine buffers a character to be sent through
;*   the PC.  The ACC must contain the character to
;*   be transmitted.
;*
;* This routine MUST be called using a JSL command!
;*
;* Reg Used: ACC
;* Var Used: SFLAG3,SOUTINDX3,SOUTEND3,SOUTCNT3
;* 
;* Returned Reg: NONE
;*
;* Important Variables:
;*   SOUTEND3   index for last character STORED in buffer
;*   SOUTINDX3  index for last character REMOVED from buffer
;*   SOUT_BUF3  base location of HOST output buffer
;*   SOUTCNT3   HOST of keyboard output buffer size




SEND_BYTE_TO_PC   EQU *

         PHA            ;FROM OUTPUT BUFFER      
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
         SEP #M8        ;SET Acc SHORT
	 REP #X8	;SET X & Y LONG
         PHA            ;DATA BYTE

	 LONGA OFF
	 LONGI ON

         LDX #POWER_DOWN_COUNT
         STX PD_TIMER

OUTCH31  LDY <SOUTEND3   ;CK IF CURRENT QUEUE POS
         INY            ;POINT TO NXT DATA
	 CPY <SOUTCNT3  ;DO WE WRAP
         BCC OUTCH3D2   ;NO      
	 LDY #0         ;WE WRAPPED
OUTCH3D2 EQU *
	 CPY <SOUTINDX3  ;DID WE OVERRUN QUEUE
         BEQ OUTCH33    ;YES, So set C and return

         SEI

	 STY <SOUTEND3
         PLA            ;GET DATA      
         STA (SOUTBUF3),Y ;PUT DATA IN QUEUE      
	 LDA <SFLAG3     ;CK IF HWHS OR SOFTWARE HS
         BIT #XONOFLG
         BNE OUTCH3_A1  ;XON/OFF SW IS ON      
         LDA ACSR3      ;HARDWARE HANDSHAKE PROTOCALL
         BIT #SON       ;IS SERIAL IRQ ON      
         BEQ OUTCH31A   ;NO      
         BIT #DISCH       ;ARE WE IN NORMAL SERIAL      
         BEQ OUTCH32    ;MODE--YES      
         LDA #DISCH        ;GOTO NORMAL SERIAL MODE      
         TRB ACSR3
         BRA OUTCH32

OUTCH3_A1 EQU *
         BIT #SNDOVF    ;CHK FOR SW HS
         BNE OUTCH32    ;HAVE A XOFF SO DONT XMIT      

OUTCH31A LDA #SON       ;SERIAL IRQ SINGLE CHR MODE
         TSB ACSR3
OUTCH32  CLI
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY            ;RECEIVE IRQ DONE
         PLA
         CLC
         RTL


OUTCH33	 LDA #$80	;Overran output buffer
	 TSB <STATUS_S3  ;SET STATUS FLAG
         PLA            ;RESTORE STK ON CNTRL 'C'
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         PLX
         PLY            ;RECEIVE IRQ DONE
         PLA
         SEC
         RTL


	 STTL 'SERIAL PORT INITIALIZATION'
	 PAGE

;* Routine:  SELECT_COMMON_BAUD
;*
;*   ENTER using a JSL Command
;*
;* This routine sets the Baud Rate for the ALL UARTS
;*   except UART 2 (MODEM port).
;*   Enter the routine with a table index value
;*   (0-D) for the Baud Rate. Use an 8-Bit Areg.
;*
;* Reg Used: ACC,Y,X  All registers are saved!
;*
;* Returned Reg: NONE  a C flag indicats error.
;*                 
;      Baud Rates  
;                  
;0    110 BAUD     
;1    150 BAUD     
;2    300 BAUD     
;3    600 BAUD     
;4   1200 BAUD     
;5   1800 BAUD     
;6   2400 BAUD     
;7   4800 BAUD     
;8   9600 BAUD     
;9  14400 BAUD
;A  19200 BAUD     
;B  38400 BAUD     
;C  57600 BAUD     
;D 115000 BAUD     


SELECT_COMMON_BAUD_RATE  EQU *   ;A=BAUD

         
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
	 SEP #X8	;SET X & Y SHORT
	 LONGA OFF
	 LONGI OFF

         SEI            ;DISABLE ANY IRQ'S      

;       BAUD RATE is in Areg        
         CMP #$0C       ;IS ACC VALID 75-38400      
         BCS ACI_ERR
         ASL A          ;X2     
	 STA <STEMP_Sx
         LDY SPEED      ;MULT BY 11 FOR MAIN XTAL      
         LDA !BAUDOFFSET,Y
         CLC
	 ADC <STEMP_Sx
         TAX
         LDA !ACIBAUD,X  ;SETUP BAUD RATE COUNTER      
         STA T4LL
         LDA !ACIBAUD+1,X
         STA T4CH       ;LOADS THE LATCH & COUNTER
         LDA #Bit2      ;8 BIT DATA
         TSB ACSR0
         TSB ACSR1
         TSB ACSR3
         LDA #Bit4
         TRB TIER       ;NO TIMER IRQ
         TSB TER        ;ENABLE COUNTER
         PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         CLC

ACI_OUT  PLX
         PLY            ;RECEIVE IRQ DONE
         PLA
         RTL


ACI_ERR  PLB            ;RESTORE BANK
         PLD            ;RESTORE DIRECT REG
	 PLP
         SEC            ;Show ERROR!
         BRA ACI_OUT



SIOPORTS EQU *     ;GENERAL SETUP OF ALL UART PORTS


;               ACSRx DEFINITIONS
          ;BIT 0-XMIT PORT ENABLE
          ;BIT 1-XMIT DISCHARGE IRQ
          ;BIT 2-7/8 BIT DATA
          ;BIT 3-PARITY ENABLE
          ;BIT 4-ODD/EVEN PARITY
          ;BIT 5-RECV ENABLE
          ;BIT 6-SOFTWARE SEMIPHORE
          ;BIT 7-RECV ERROR FLG

         LDA #$FF       ;START WITH ALL OUTPUTS
         STA PDD6

                        ;SET TXD0,TXD1,TXD2,TXD3 TO DEFAULT MARK  (P61,P63,P65,P67)
         TSB PD6        ;FORCE RXD INPUTS TO MARK (BUS HOLDING DEVICES)
         
                        ;SETUP DATA DIRECTION REG INPUT = 0, OUTPUT = 1
         LDA #$55
         TRB PDD6       ;SET RXD0,RXD1,RXD2,RXD3 AS INPUTs (P60,P62,P64,P66)

                        ;PD5 - B1,B3,B5 & B7  ARE INPUTS  [DSRs]
         STA PDD5       ;PD5 - B0,B2,B4 & B6  ARE OUTPUTS [DTRs]
                        ;MAKE  DTR0-3 LOW      
	 TRB PD5        ;TO ENABLE SERIAL DATA

	 LDA #$B0       ;UARTs 0,1,3  will use TIMER #4
	 TSB TCR

	 LDA ARTD3      ;CLEAR INPUT REGISTER

;    Start Timers

	 LDA #T3FLG+T4FLG ;ENABLE TIMER 3 & 4
	 TSB TER
         RTS

	 ENDS

DELASTBYTE EQU *

	 IFTRUE   DELASTBYTE.UGT.$00FEA0
	 EXIT  "It won't fit in the ROM!!!!"
	 ENDIF

	 APPEND TABLES.ASM
