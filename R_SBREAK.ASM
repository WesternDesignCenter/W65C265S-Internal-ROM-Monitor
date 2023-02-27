; FILE R_SBREAK	 ....... ROMULATOR INTERFACE
; DATE 12-17-94

	 STTL 'NMI & SOFTWARE BREAK'
	 PAGE

	 CODE

; ROM-U-CODE
; 

;  This is the code needed in a TARGET computer to
;interface with the COM LOG  Romutator.
;
; Include SBREAK as a vector for the BRK interrupt.
;
; Include NMIBRK  as a vector for the NMI interrupt vector


WRT_ERR EQU $FFB4

SBRK    EQU $01
NMIFLG  EQU $02




	global SBREAK,NMIBRK


SBREAK  PHA	       ;SOFTWARE BREAK INTERRUPT
	PHP	       ;SAVE  OLD Areg SIZE
        SEP #$20
	LONGA OFF

	LDA #SBRK
        TSB SB_SENTL
	BEQ NMIS
	PLP	       ;RESTORE Areg SIZE
	PLA	       ;WE ARE STILL WORKING ON A BRK!
	RTI




NMIBRK  PHA	       ;NMI INTERRUPT FROM HOST
	PHP
        SEP #$20
	LONGA OFF

	LDA #NMIFLG
        TSB SB_SENTL
        BNE NMIX       ;RE-ENTERED!  GET-OUT
        LDA #SBRK
        BIT SB_SENTL
	BEQ NMIS       ;SOFTWARE INTERRUPT NOT IN PROCESS
NMIX    PLP
	PLA
        RTI

JSL_RTL_IN:
	STA >ACC         ;SAVES 8 OR 16 BITS

	REP #$10	;NEED 16 BIT INDEX & 8 BIT Areg
	LONGI ON
        SEP #$20
	LONGA OFF

	XBA		;SAVE Breg IF Areg WAS 8 BITS
	STA >ACC+1       ; IF Areg WAS 16 BITS DOESNT MATTER
        PHP             ;GET FLAGS
        PLA
	STA >FLGS
        BRA NMIS_J      ;SAVE REGISTERS BUT NOT P.C.

		       ;SAVE ALL THE REGISTERS
NMIS	PLP
	PLA		;RESTORE Areg SIZE
	STA >ACC         ;SAVES 8 OR 16 BITS

	REP #$10	;NEED 16 BIT INDEX & 8 BIT Areg
	LONGI ON
        SEP #$20
	LONGA OFF

	XBA		;SAVE Breg IF Areg WAS 8 BITS
	STA >ACC+1       ; IF Areg WAS 16 BITS DOESNT MATTER

	PLA
	STA >FLGS        ;P REG
	PLA
	STA >PCL         ;PROGRAM COUNTER LO
	PLA
	STA >PCH         ;HI
	PLA 
	STA >TPBR        ;PROGRAM BANK REG

NMIS_J:
        STX XREG
	STY YREG
	
        TSX
	STX STK_PTR     ;STACK POINTER
	PHD
	PLX
	STX DIRREG      ;DIRECT PAGE
	PHB
	PLA
	STA >DBREG       ;DATA BANK

        CLI

	JSL DUMPREGS

	JMP ROM_START   ;GOTO MONITOR


GO_AGAIN:
        STZ SB_SENTL
	LDA >DBREG      ;RESTORE ALL REGISTERS
	PHA
	PLB
	LDX DIRREG
	PHX
	PLD
	LDX STK_PTR
        TXS
	LDA >TPBR
	PHA
	LDA >PCH
	PHA
	LDA >PCL
	PHA

	LDA >FLGS
	PHA
	LDY YREG
	LDX XREG

	LDA >ACC+1       ;RESUME PROCESSING
	XBA
	LDA >ACC

	RTI


	PAGE

;THIS ROUTINE FORMS AN OUTPUT LINE THAT
;DISPLAYS THE VARIOUS REGISTERS 
;FOR THE 65C816 IE A,X,Y,S,PC,DP ETC.
;  The format is:
;            

;* Routine:  DUMPREGS DISPLAY REG CMD'
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMPC,TMP0
;* Routines Called: WRPC16,SETR,SPAC,WROB
;* Returned Reg: NONE
;*

DUMPREGS:
         PHA
         PHX
         PHY
         PHP                  ;SAVE CPU MODES
         SEP #M8              ;SET Acc SHORT
         REP #X8

	 LONGA OFF
	 LONGI ON

         LDA #3
         JSL CLEAR_LCD_DISPLAY

         JSR DISP_REGS        ;PRINT OUT REGISTERS
                              ;Acc,X,Y,S,D,B, & P
         JSR DISP_FLAGS
         JSL SEND_CR

         PLP                  ;RESTORE CPU MODES
         PLY
         PLX
         PLA            
         RTL



                              ;PRINT OUT REGISTERS
                              ;Acc,X,Y,S,D,B, & P
DISP_REGS:
         JSR REGTTL1    ;PRINT OUT HEADER FOR REGISTERS
         JSR WR_PC      ;WRITE Program Counter
         JSL SEND_SPACE2
         JSL SEND_SPACE

         LDX #ACC       ;SET TO ACCESS REGS      
	 STX <TMP2
         LDA #DIRREG-ACC
	 STA <TMPC       ;SAVE BYTE COUNT IE LENGTH OF REG TBL
	 STZ <TMPC+1
         JSR REG_OUT


         JSR REGTTL2    ;PRINT OUT HEADER FOR MORE REGISTERS
         LDX #DIRREG       ;SET TO ACCESS REGS      
	 STX <TMP2
         LDA #EBIT-DIRREG
	 STA <TMPC       ;SAVE BYTE COUNT IE LENGTH OF REG TBL
	 STZ <TMPC+1
         JSR REG_OUT
         RTS


REG_OUT:
         LDY #0
?1       LDA (TMP2),Y   ;GET ADDR OF NXT REG
         PHA            ;SAVE LSB ON STACK
         INY
         LDA (TMP2),Y   ;GET ADDR OF NXT REG
         JSL SEND_HEX_OUT       ;OUTPUT BYTE STRING (2 ASCII CHAR)
         INY
         JSL SEND_SPACE
         PLA            ;GET LSB OFF OF STACK
         JSL SEND_HEX_OUT       ;OUTPUT BYTE STRING (2 ASCII CHAR)
         JSL SEND_SPACE2
	 CPY <TMPC
         BLT ?1
	 JSL SEND_CR
         RTS


DISP_FLAGS:
	 STZ <TMP0+2           ;SAVE BANK OF STRING
         LDA #0
         LDX #ACCCCTBL
         JSL PUT_STR
                              ;NOW GET STATUS REGISTER BITS
	 LDA >FLGS             ;GET ORIG STATUS REG
         PHA
         LDY #8
DMP_FLGS PLA
         ASL A
         PHA
         BCS DMP_FLG1
         LDA #'0'
         BRA DMP_FLGX

DMP_FLG1 LDA #'1'       
DMP_FLGX JSL PUT_CHR
         JSL SEND_SPACE2
         DEY
         BNE DMP_FLGS
         PLA
         RTS


REGTTL1:
	 STZ <TMP0+2     ;BANK OF STRING
         LDA #0         ;PRINT OUT REG INFO HEADER
         LDX #REGTBL1
         JSL PUT_STR
         RTS

REGTTL2:
	 STZ <TMP0+2     ;BANK OF STRING
         LDA #0         ;PRINT OUT REG INFO HEADER
         LDX #REGTBL2
         JSL PUT_STR
         RTS




WR_PC:  ;WRITE OUT PC AS A 3 BYTE ADDRESS
	 LDA >TPBR
	 STA <TMP0+2
	 LDA >PCH
	 STA <TMP0+1
	 LDA >PCL
	 STA <TMP0
         JSL WR_3_ADDRESS
         RTS

	 PAGE
;*********************************************************


ACCCCTBL:
	 BYTE C_RETURN
	 BYTE C_RETURN,'Status Reg',C_RETURN
	 BYTE 'N  V  M  X  D  I  Z  C'
	 DC C_RETURN
ACCCCEND:


;*****************************************************************
REGTBL1:
	 BYTE C_RETURN
	 BYTE 'PCntr     Acc    Xreg   Yreg   Stack'
	 BYTE C_RETURN,0

REGTBL2:
	 BYTE C_RETURN
	 BYTE '  DirRg  F  DBk'
	 BYTE C_RETURN,'  ',0

;*****************************************************************

	 PAGE

;THIS ROUTINE FORMS AN OUTPUT LINE THAT
;DISPLAYS THE VARIOUS REGISTERS 
;FOR THE 65C816 IE A,X,Y,S,PC,DP ETC.
; AND THEN ALLOWS THE ABILITY TO CHANGE
;ANY REGISTER.

;* Routine:  ALTER_REGS 
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMPC,TMP0
;* Routines Called: WRPC16,SETR,SPAC,WROB
;* Returned Reg: NONE
;*

ALTER_REGS:

         JSR REGTTL1    ;PRINT OUT HEADER FOR REGISTERS
         JSR WR_PC      ;WRITE Program Counter
         JSL SEND_SPACE2
         JSL SEND_SPACE
         LDX #ACC       ;SET TO ACCESS REGS      
	 STX <TMP2
         LDA #DIRREG-ACC
	 STA <TMPC       ;SAVE BYTE COUNT IE LENGTH OF REG TBL
	 STZ <TMPC+1
         JSR REG_OUT	;Print out current values of reg's


PC_CNTR_IN:    ;get new value for pc counter
	 
	 JSL GET_BYTE
         BCC ?4
         CMP #' '
         BEQ ?3           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?3       LDA >TPBR
         JSR WRT2OUT
	 BRA ?5

?4       STA >TPBR
?5	 LDA #':'
         JSL PUT_CHR    

	 JSL GET_BYTE
         BCC ?7
         CMP #' '
         BEQ ?6           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?6       LDA >PCH
         JSR WRT2OUT
	 BRA ?8

?7       STA >PCH

?8       JSL GET_BYTE
         BCC ?A
         CMP #' '
         BEQ ?9           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?9       LDA >PCL
         JSR WRT2OUT
	 BRA ?B

?A       STA >PCL

?B       JSL SEND_SPACE2
	 JSL SEND_SPACE

REG_IN:

         LDY #0
	 
?1	 INY		  ;POINT TO MOST SIGNIFICANT BYTE
	 JSL GET_BYTE     ;DO 1ST BYTE
         BCC ?4
         CMP #' '
         BEQ ?3           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?3	 LDA (TMP2),Y	  ;REPEAT ORIGIONAL BYTE
         JSR WRT2OUT
	 BRA ?5

?4       STA (TMP2),Y
?5	 JSL SEND_SPACE
         DEY		  ;POINT TO LEAST SIGNIFICANT BYTE

	 JSL GET_BYTE     ;DO 2ND BYTE
         BCC ?7
         CMP #' '
         BEQ ?6           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?6	 LDA (TMP2),Y
	 JSR WRT2OUT
	 BRA ?8

?7       STA (TMP2),Y

?8       INY
         INY            ;POINT TO NEXT REG
         JSL SEND_SPACE2
	 CPY <TMPC
         BLT ?1

REG_IN_II:

	 STZ <TMP0+2     ;BANK OF STRING
         LDA #0         ;PRINT OUT REG INFO HEADER
         LDX #REGTBL2
         JSL PUT_STR

         LDX #DIRREG       ;SET TO ACCESS REGS      
	 STX <TMP2
         LDA #EBIT-DIRREG
	 STA <TMPC       ;SAVE BYTE COUNT IE LENGTH OF REG TBL
	 STZ <TMPC+1
         JSR REG_OUT

	 JSL SEND_SPACE2
         LDY #0
	 
?1	 INY		  ;POINT TO MOST SIGNIFICANT BYTE
	 JSL GET_BYTE     ;DO 1ST BYTE
         BCC ?4
         CMP #' '
         BEQ ?3           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?3	 LDA (TMP2),Y	  ;REPEAT ORIGIONAL BYTE
         JSR WRT2OUT
	 BRA ?5

?4       STA (TMP2),Y
?5	 JSL SEND_SPACE
         DEY		  ;POINT TO LEAST SIGNIFICANT BYTE

	 JSL GET_BYTE     ;DO 2ND BYTE
         BCC ?7
         CMP #' '
         BEQ ?6           ;MUST BE A SPACE
	 BRL ALTER_ERR    ;NON HEX

?6	 LDA (TMP2),Y
	 JSR WRT2OUT
	 BRA ?8

?7       STA (TMP2),Y

?8       INY
         INY            ;POINT TO NEXT REG
         JSL SEND_SPACE2
	 CPY <TMPC
         BLT ?1

	 CLC
	 RTL

ALTER_ERR:
         SEC
         RTL

	 ENDS

	 APPEND R_DEBUG.ASM
