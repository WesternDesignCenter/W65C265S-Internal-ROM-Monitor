;FILE = R_DEBUG.ASM
;DATE = 1-06-94

	 STTL 'DEBUG ROUTINES, LOADS & DUMPS'
	 PAGE

	 CODE

;*    Routine:  XS28IN
;*
;*  This routine must be called using a JSL cmd!
;*
;* XS28IN Reads S28 formated data from the
;*   input selected by the CONTROL_INPUT routine
;*   and places it into memory.  This routine
;*   outputs a "." each time a record is transfered
;*   to memory with out error.  A "?" is returned
;*   if the checksum does not agree. After receiving
;*   the final record a Cy = 0  is returned if no
;*   errors had been encountered.  Likewise, if errors
;*   occurred, a Cy = 1  will be returned.
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMP0,TMP2,TMP4,TMP6,TMPC,ERRORS
;* Routines Called: GET_CHR,DADD,RDOB,BYTE 
;*                   
;* Returned Reg: NO registers are saved!
;*

XS28IN   EQU *


	 LDA <INPUT_XTRL
         AND #Bit0+Bit2+Bit3
	 BEQ XS28EEE	;NO INPUT SOURCE

         LDA #3
         JSL CLEAR_LCD_DISPLAY

         LDA #0
         LDX #S28_Loader
         JSL DISP_LCD_STRNG

         LDX #0         ;Record #
         LDA #03        ;on the LCD
         JSL POSITION_TEXT_CURSOR

         LDA #0
         LDX #RecordNo
         JSL DISP_LCD_STRNG

         JSL GET_CHR
         CMP #ESC
         BNE XS28A
XS28EEE  BRL XLS_BAD

XS28A    CMP #'S'       ;FIND NEXT RCD MARK (S)      
         BNE XS28IN

XS28ROM:
	 STZ <ERRORS
         LDX #0
	 STX <COUNT      ;GOOD RECORD COUNT

XLSS     EQU *          ;LOAD SINGLE S28 RECORD   
                        ;CHECKSUM USED, BUT      
                        ;REQUIRED SO THAT IT      
                        ;IS COMPATABLE      
	 INC <ERRORS
         JSL GET_CHR    ;GET S RECORD TYPE      
         PHA            ;SAVE S RECORD TYPE      
	 STZ <TMP4
	 STZ <TMP4+1     ;CLR CKSUM REG
         JSL GET_HEX    ;GET BYTE COUNT      
	 STA <TMPC       ;SAVE BYTE COUNT
         JSR DADD
	 DEC <TMPC       ;DEC FOR S28 ADDR
	 DEC <TMPC
	 DEC <TMPC
         PLA            ;GET RECORD TYPE      
         CMP #'2'       ;ONLY ALLOW S28 RECORDS
         BEQ XS28LA1
         CMP #'8'
         BNE XLSS0      ;UNKNOWN RECORD TYPE
         BRL XLSSDONE   ;ITS LAST LINE OF RECORD

XS28LA1  DEC <TMPC
         JSL GET_HEX    ;GET BANK ADDR
	 STA <TMP0+2     ;SAVE 3 BYTE ADDRESS
         JSR DADD       ;ADD TO CKSM      
         JSL GET_HEX    ;SA HO TO TMP0+1
	 STA <TMP0+1
         JSR DADD       ;ADD TO CKSM      
         JSL GET_HEX    ;SA LO TO TMP0      
	 STA <TMP0
         JSR DADD       ;ADD TO CHKSM      

	 LDA <TMPC       ;CK IF # OF BYTES ZERO
         BEQ XS28G2
XS28GD1  JSR BYTE       ;BYTE SUB/R DECRS LCNT
         BCC XS28G3
	 INC <ERRORS     ;DEC COUNTER & INC ADDR
	 INC <TMP4       ;MESS UP CKSUM SO WILL PRINT ERR
         JSR DADD       ;INCR CKSUM   
         JSR INCTMP0    ;GO INCR TMP0 ADR   
	 DEC <TMPC
                        ;BYTE ENDING TOO SOON      
XS28G3   BNE XS28GD1    ;ON EXIT 
XS28G2   JSL GET_HEX    ;CKSUM FROM HEX RCD>TMP0 
         JSR DADD
	 LDA <TMP4       ;GET CHKSUM

         CMP #$FF
         BNE XS28ERR	;BAD RECORD LOAD

XLSS0    DEC <ERRORS     ;A GOOD LOAD

XLSFIN   JSL GET_CHR    ;GET CR OR LF 
         CMP #C_RETURN        ;CR
         BEQ XLSFIN1
         CMP #L_FEED    ;LF/NEW LINE
         BNE XLSFIN
XLSFIN1  LDA #'.'       ;ACK
         JSL PUT_CHR
         SED
	 LONGA ON
         REP #M8
	 LDA <COUNT
         CLC
         ADC #1
	 STA <COUNT
         CLD
	 LONGA OFF
         SEP #M8

         LDX #10        ;Show a running count of good records
         LDA #03        ;on the LCD
         JSL POSITION_TEXT_CURSOR

	 LDA <COUNT+1
         JSR WRT2OUT
	 LDA <COUNT
         JSR WRT2OUT

XLSFN    JSL GET_CHR     ;GET END RECORD
         CMP #'S'      
         BNE XLSFN
	 BRL XLSS       ;REPEAT RECORD LOOP


XS28ERR  JSL GET_CHR    ;GET END OF RECORD
         CMP #ESC
         BEQ XLS_BAD    ;KICKED OUT!

         CMP #L_FEED    ;LF/NEW LINE
         BNE XS28ER1
         CMP #C_RETURN        ;CR
         BNE XS28ERR
XS28ER1  LDA #'?'       ;NAK
         JSL PUT_CHR
         BRA XLSFN

XLSSDONE 
         JSL GET_CHR    ;GET CR OR LF 
         CMP #C_RETURN        ;CR
         BEQ XLSSXIT
         CMP #L_FEED    ;LF
         BNE XLSSDONE

XLSSXIT  DEC <ERRORS     ;CORRECT FOR S8 RECORD

;         LDA SFLAG0
;         AND #$FF-ECHOFF
;         ORA <TMP6+1     ;RESTORE STATE OF ECHO OFF
;         STA SFLAG0
;         CLI

XLHDONE   LDA <ERRORS
          BNE XLS_BAD
          CLC
          RTL
 
XLS_BAD   SEC
          RTL


S28_Loader DC '   S28 LOADER '
RecordNo   DC 'Record # '


;* Routine:  BYTE_LONG
;*  READ AND STORE BYTE.
;*  NO STORE IF SPACE OR TMPC=0.
;* Reg Used: ACC,Y,X
;* Var Used: TMPC,TMP0
;* Routines Called: RDOB,DADD,INCTMP0
;* Returned Reg: NONE
;*

BYTE     EQU *
         JSL GET_HEX    ;CHAR IN A, CY=0 IF      
         BCS BY1        ;BAD DATA
         STA [TMP0]     ;STORE BYTE (DIRECT INDIRECT LONG)
         CMP [TMP0]     ;TEST FOR VALID WRITE      
         BEQ BY2
                        ;NOT A VALID WRITE
BY1      JSR INCTMP0    ;increment the address
	 DEC <TMPC
         SEC
         RTS


BY2      JSR DADD       ;INCR CKSUM   
         JSR INCTMP0    ;GO INCR TMP0 ADR   
	 DEC <TMPC
         CLC


         RTS

;*******************************************************
	 PAGE

;* Routine:  SET_Breakpoint
;*
;* SET_Breakpoint replaces the the byte at the
;*   given address with a BREAK instruction.
;* The BREAK address is requested by this routine.
;*
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMP2
;* Routines Called:  Get_S_Address
;*                 
;* Returned Reg: NONE
;*
;*

SET_Breakpoint:

	PHA
        PHX
  	PHY
        JSL Get_Address  ;break address 
 	BCS ?9


?2 	LDA #0
        STA [TMP2]

        STZ SB_SENTL


	CLC
?9	PLY
	PLX
	PLA
        RTL






;*******************************************************
	 PAGE

;* Routine:  FILL_Memory
;*
;* FILL_Memory takes a HEX byte and propogates it
;*   through a section of memory. First a starting
;*   address is requested then a ending address is
;*   requested and finally the HEX byte is requested.
;*
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMP0,TMP2,TMP4,TMPC,DIFF
;* Routines Called:  Get_S_Address, Get_E_Address
;*                   HEX2IN, POSITION_TEXT_CURSOR
;*                   DISP_LCD_STRNG, INCTMP0
;*                 
;* Returned Reg: NONE
;*
;*

FILL_Memory:

	PHA
        PHX
  	PHY
        JSL Get_S_Address  ;starting address 
 	BCS ?9

	LDX <TMP2       ;move start addr to TMP0
	STX <TMP0               ;

	LDA <TMP2+2             ;
	STA <TMP0+2             ;

        JSL Get_E_Address  ;ENDING address 
 	BCS ?9
        JSR DCMP       ;IS EA > SA
        BCC ?9         ;NO

        LDX #0
        LDA #06
        JSL SEND_CR
        JSL POSITION_TEXT_CURSOR

        LDA #0
        LDX #Enter_HEX
        JSL PUT_STR
        JSL GET_PUT_CHR
        BCS ?9
        JSR HEXIN
        BCS ?9
        ASL A
        ASL A
        ASL A
        ASL A
	STA <TEMP
        INY
        JSL GET_PUT_CHR
        BCS ?9
        JSR HEXIN
        BCS ?9
	ORA <TEMP
	STA <TEMP

?2      LDA <TEMP
        STA [TMP0]
        JSR DCMP       ;EA-SA (TMP2-TMP0) DIFF      
	BEQ ?8
        JSR INCTMP0    ;INC SA      
	BRA ?2

?8	CLC
?9	PLY
	PLX
	PLA
        RTL


Enter_HEX DC 'Enter Byte in HEX '


;*******************************************************
	 PAGE

;* Routine:  Alter_Memory
;*
;* Alter_Memory prints 1 line of memory dump from an
;*   address thats inputted. The second line prints
;*   the same starting address and then allows the 
;*   programmer to input new data 1 byte at a time
;*
;* An ENTER key terminates the operation.  A SPACE
;*   character will allow the programmer to skip over
;*   a memory cell without changing it.
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMP0,TMP1,TMP2,TMP4,SFLAG0,TMPC,DIFF
;* Routines Called:  Dump_1_line_to_Screen
;*                 
;* Returned Reg: NONE
;*
;*


Alter_Memory EQU *


      ;First....show what we are changing!
         JSL Dump_1_line_to_Output
         BCC ?AM1
         BRL ?99

?AM1     LDA <OUTPUT_XTRL
         BIT #1         ;IS LCD ON?
         BEQ ?1         ;NO
         LDA #8         ;8 bytes displayed per line
         BRA ?2

?1       LDA #16        ;16 bytes displayed per line
?2       STA <TMPC

	 LDA <TMP1+2     ;WRITE LONG ADDRESS
         JSL SEND_HEX_OUT
         LDA #':'
         JSL PUT_CHR
	 LDA <TMP1+1
         JSL SEND_HEX_OUT
	 LDA <TMP1
         JSL SEND_HEX_OUT
?AM2     LDA #' '
         JSL PUT_CHR
?AM2_1   JSL GET_PUT_CHR   ;get a hex char
         BCS ?99
         CMP #C_RETURN
         BEQ ?90	   ;we are done
         CMP #BKSP
         BEQ ?70
         CMP #' '
	 BNE ?AM2_6
         LDA #BKSP	;BACKUP	backup again
         JSL PUT_CHR   
         LDA [TMP1]     ;GET OLD CHAR
         JSL SEND_HEX_OUT
	 BRA ?AM3

?AM2_6   JSR HEXIN
	 BCC ?AM2_7     ;its hex
	 JSR ?Q_IT	;not valid hex
	 BRA ?AM2_1     ;TRY AGAIN

?AM2_7   ASL A
         ASL A
         ASL A
         ASL A
	 STA <TEMP
?AM2_8   JSL GET_PUT_CHR   ;second char of hex byte
         BCS ?99
         CMP #C_RETURN
         BEQ ?90	   ;we are done
         CMP #BKSP
	 BEQ ?AM2_8
         JSR HEXIN
	 BCC ?AM2_9
	 JSR ?Q_IT	;Not valid hex
	 BRA ?AM2_8     ;TRY AGAIN

?AM2_9   ORA <TEMP
         STA [TMP1]     ;STORE BYTE (DIRECT INDIRECT LONG)
         CMP [TMP1]     ;TEST FOR VALID WRITE      
         BEQ ?AM3
         JSL BACKSPACE2 ;BACKUP 2nd char positionS
         LDA #'?'	;write a "?"
         JSL PUT_CHR
         LDA #'?'	;write a "?"
         JSL PUT_CHR
		
?AM3     JSR INCTMP1    ;GO INCR TMP0 ADR   
	 DEC <TMPC
         BNE ?AM2	;continue on same line
         LDA #C_RETURN
         JSL PUT_CHR
         BRL ?AM1	;start new line


?70      JSL BACKSPACE2
         JSR DECTMP1    ;BACKUP POINTER
	 BRL ?AM2_1

?90      CLC		;good exit
         RTL

?99      SEC		;bad exit
         RTL

?Q_IT    LDA #BKSP	;BACKUP 1 char position
         JSL PUT_CHR 
         LDA #'?'	;write a "?"
         JSL PUT_CHR
         LDA #BKSP	;BACKUP	backup again
         JSL PUT_CHR   
     	 RTS


;*******************************************************
	 PAGE

;* Routine:  DUMP_OUT
;*    Variations:
;*       DumpS28  ;S28 loader format
;*       Dump_to_Printer  formated dump to printer
;*       Dump_to_Screen   formated dump to screen
;*       Dump_1_line_to_Screen   single line dump
;*       Dump_to_Screen_ASCII   ASCII replaces HEX
;*	 Dump_to__Output  G.P. formated dump
;*       Dump_1_line_to_Output:
;*
;* Reg Used: ACC,Y,X
;* Var Used: TMP0,TMP1,TMP2,TMP4,SFLAG0,TMPC,DIFF
;* Routines Called: GET_STR,DISP_LCD_STRNG,WRTWO,DCMP,DADD
;*                   POSITION_TEXT_CURSOR,CKNOUT,WROB
;* Returned Reg: NONE
;*
;*     DUMP_FLGS (format control byte)
;*       Flag1 = output S28+byte-count
;*       Flag2 = Format for LCD
;*       Flag3 = add spaces between data bytes & HEADER
;*       Flag4 = add checksum
;*       Flag5 = 8 bytes not 16 bytes
;*       Flag6 = ONE LINE ONLY
;*       Flag7 = ASCII not Hex data


;***************************************************************
;*
;*    Dump to printer switches the output control to Printer
;*    and then requests starting and ending addresses
;*    from the keyboard.  A formated output with header line
;*    is sent to the printer.  Every 60 lines a new page with
;*    a new header is started until the ending address is
;*    reached.  The origional output control is re-established
;*    before the routine returns to the caller.
;*    The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_to_Printer:

	       LDA <OUTPUT_XTRL
               PHA
 	       ORA #Bit1	;SET Printer on
	       STA <OUTPUT_XTRL
               JSL Dump_to_Output
               PLA
	       STA <OUTPUT_XTRL  ;RESTORE OUTPUT MODES
               RTL


;***************************************************************
;*
;*  Dump to output requests starting and ending addresses
;*    from any input.  A formated output with header line
;*    is sent to the printer.  Every 60 lines a new page with
;*    a new header is started until the ending address is
;*    reached. Then the routine returns to the caller.
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_to_Output:
               LDX #60
               LDA #Flag3
               BRL G_XS28OUT


;***************************************************************
;*
;*  Dump 1 line to output requests a starting addresses
;*    from any input.  A formated output with header line
;*    is sent to the general output. Only one line (16 HEX chrs)
;*    is sent. Then the routine returns to the caller.
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_1_line_to_Output:
               LDX #60
	       LDA <OUTPUT_XTRL
               BIT #1         ;IS LCD ON?
               BEQ ?1         ;NO
               LDA #Flag2+Flag3+Flag5+Flag6
               BRA ?2

?1             LDA #Flag3+Flag6

?2             JMP G_XS28OUT



;***************************************************************
;*
;*  Dump to Screen requests starting and ending addresses
;*    from any input.  A formated output with header line
;*    is sent to the LCD Screen.  Eight HEX characters per
;*    line are displayed.  Every 14 lines a new page with
;*    a new header is started until the ending address is
;*    reached. Then the routine returns to the caller.
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_to_Screen:
               LDX #12
               LDA #Flag2+Flag3+Flag5
               BRA L_XS28OUT



;***************************************************************
;*
;*  Dump to Screen requests starting and ending addresses
;*    from any input.  A formated output with header line
;*    is sent to the LCD Screen.  Sixteen ASCII characters
;*    per line are displayed.  Every 14 lines a new page with
;*    a new header is started until the ending address is
;*    reached. Then the routine returns to the caller.
;*    A non-printable ASCII is displayed as a ".".
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_to_Screen_ASCII:
               LDX #12
               LDA #Flag2+Flag7
               BRA L_XS28OUT


;***************************************************************
;*
;*  Dump 1 line to Screen requests a starting addresses
;*    from any input.  A formated output with header line
;*    is sent to the printer. Only one line (16 HEX chrs)
;*    is displayed. Then the routine returns to the caller.
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


Dump_1_line_to_Screen:
               LDX #12
               LDA #Flag2+Flag3+Flag5+Flag6
               BRA L_XS28OUT




;***************************************************************
;*
;*  DumpS28 requests starting and ending addresses from
;*    any input.  A Motorola S28 formated output is sent
;*    to the general output control. Each line contains
;*    a check sum. When the ending address is reached
;*    a S8 record is sent before this routine returns.
;*  The routine is aborted and a Cy=1 is returned if the
;*    address inputted has a hex conversion error.


DumpS28:
               LDX #0
               LDA #Flag1+Flag4
               BRL G_XS28OUT


;***************************************************************

G_XS28OUT:   ;Common input for some dump routines
	       STX <LINE_MAX
	       STA <DUMP_FLGS
               BRL XS28OUT


Print_Head  DC 'Address '

XSLSTLINE   DC 'S804000000FB'

XS28BN   EQU 20         ;16 + 3 FOR ADDR
                        ; + 1 FOR CKSUM


L_XS28OUT:

	 STX <LINE_MAX
	 STA <DUMP_FLGS
	 LDA <OUTPUT_XTRL
	 PHA
         AND #Bit0	;Leave only LCD on
	 STA <OUTPUT_XTRL
	 JSL XS28OUT
         PLA
	 STA <OUTPUT_XTRL  ;RESTORE OUTPUT MODES
         RTL



XS28OUT:

	 LDA <DUMP_FLGS
         BIT #Flag6      ;single line? 
	 BEQ ?S_E        ;no

         JSL Get_Address  ;starting address 
         BCS ?xx
	 BRA ?S0

?S_E     JSL Get_S_Address  ;starting address
         BCC ?S0

?xx      SEC            ;CANCELLING TO EXIT
         RTL

?S0      LDX <TMP2       ;move start addr to TMP0
	 STX <TMP0               ;
	 STX <TMP1       ;TMP1 IS USED IN ALTER MEM

	 LDA <TMP2+2             ;
	 STA <TMP0+2             ;
	 STA <TMP1+2

;     SETUP THE ENDING ADDRESS       in TMP2
	 LDA <DUMP_FLGS
         BIT #Flag6      ;single line? 
         BEQ ?E0        ;no
         BIT #5
         BNE ?S1
         LDA #16
         BRA ?S3

?S1      LDA #8
?S3      CLC
	 ADC <TMP0
	 STA <TMP2

	 LDA <TMP0+1
         ADC #0
	 STA <TMP2+1

	 LDA <TMP0+2
         ADC #0
	 STA <TMP2+2
         BRA ?E2


?E0   
         LDA #05
         JSL POSITION_TEXT_CURSOR

         JSL Get_E_Address
         BCS ?xx

?E2      LDA #3
         JSL CLEAR_LCD_DISPLAY

         LDX #0
	 STX <WRAP
	 STX <LINE_CNT

?0       JSL P_HEADER
         BCS ?xxx


	 LDA <DUMP_FLGS
	 BIT #Flag6	;single line
	 BNE ?3_1

         BIT #Flag1
         BEQ ?3         ;NOT S28 FORMAT

	 ;WRITE LAST LINE
?1       LDA #0
         LDX #XSLSTLINE
         JSL PUT_STR

?3       JSL GET_CHR
?3_1     CLC
         RTL

?xxx     JSL GET_CHR
         SEC
         RTL

;*********************************************************
	 PAGE

;*   ******  Dump_It  *******
;*  
;*   Enter here for custom dump routines. Have DUMP_FLGS
;*     in an 8 bit Areg and the number of lines per page
;*     to print/display in a 16 bit Xreg.
;*   The starting address must be in TMP0 (3bytes) and 
;*     the ending address must be in TMP2 (3bytes).
;*

Dump_It:
	 STX <LINE_MAX
	 STA <DUMP_FLGS

;The following subroutine makes each line of output until
;  all requested bytes are sent.

P_HEADER LDA <DUMP_FLGS
         BIT #Flag3        ;formated oputput
         BEQ XS28OUTA      ;NO Page HEADER
         
         LDX #Print_Head   ;"Address"
         LDA #0
         JSL PUT_STR
      ;now print address for columns
         LDX #16
	 LDA <DUMP_FLGS
         BIT #Flag2        ;LCD ?
         BEQ ?H0
         LDX #8         ;# of lines for LCD only
?H0      LDA <TMP0       ;LOW START ADDR
?H1      PHA
         PHX
         JSR BINASC
         JSL PUT_CHR
         LDA #' '
         JSL PUT_CHR
         JSL PUT_CHR
         PLX
         PLA
         DEX
         BEQ ?H2
         INC A
         BRA ?H1

?H2      LDA #C_RETURN
         JSL PUT_CHR
         JSL PUT_CHR

XS28OUTA LDA <WRAP
         BEQ XWH00
         SEC
         RTL

XWH00
	 STZ <TMP4
	 STZ <TMP4+1     ;CLEAR CKSUM
         LDA #XS28BN
	 STA <TMPC       ;TMPC = 16+4 FOR SHORT

	 LDA <DUMP_FLGS
         BIT #Flag5     ;LCD ?
         BEQ ?XH0
         LDA #12        ;LCD = 8+4
	 STA <TMPC

?XH0     LDA <DUMP_FLGS
         BIT #Flag1
         BEQ XWH1A      ;not S28 format

         LDA #'S'       ;      
         JSL PUT_CHR
         LDA #'2'       ;OUTPUT S2
         JSL PUT_CHR

         JSR DCMP       ;EA-SA (TMP2-TMP0) DIFF      
	 LDA <DIFF+2     ;IN LOC DIFF+2 (IE BANK) OF
         BNE XWH10      ;DIFF  GT 65536    
	 LDA <DIFF+1
         BNE XWH10      ;DIFF > 256
	 LDA <DIFF
         CMP #15
         BCS XWH10      ;DIFF > 16      
         CLC            ;ADD 3 FOR ADDR      
         ADC #$05       ;ADD 1 FOR CKSUM      
	 STA <TMPC       ;ADD 1 FOR BYTE CNT

XWH10    LDA <TMPC       ;OUTPUT BYTE COUNT
         JSR CKNOUT     ;RCC CNT IN A      

XWH1A    DEC <TMPC       ;BACK OUT FOR ADDRESS
	 DEC <TMPC       ;AND BYTE COUNT
	 DEC <TMPC
	 DEC <TMPC

	 LDA <TMP0+2     ;output the address
         JSR CKNOUT     ;ADD BANK TO CKSM
	 LDA <DUMP_FLGS
         BIT #Flag1
         BNE XWH1b      ;no colon after bank addr
         LDA #':'
         JSL PUT_CHR

XWH1b    LDA <TMP0+1
         JSR CKNOUT     ;ADD HIGH ADDRESS BYTE TO CKSM      
	 LDA <TMP0
         JSR CKNOUT     ;ADD LOW ADDRESS BYTE TO CKSM      
	 LDA <DUMP_FLGS
         BIT #Flag1
         BNE XWH2       ;no space after ADDR
         LDA #' '
         JSL PUT_CHR

XWH2     LDA <DUMP_FLGS
         BIT #Flag7
         BEQ XWH2C      ;not ASCII
         LDA [TMP0]     ;WRITE OUT DATA BYTES      
         CMP #$7F       ;as ASCII characters
         BCS XWH2A      ;non ASCII
         CMP #$20
         BCS XWH2B
XWH2A    LDA #'`'       ;non ASCII
XWH2B    JSL PUT_CHR
         BRA XWH3

XWH2C    LDA [TMP0]     ;WRITE OUT DATA BYTES      
         JSR CKNOUT     ;INC CKSUM, PRESERVES Areg      

XWH3     LDA <DUMP_FLGS
         BIT #Flag3
         BEQ XWH3a       ;no formating spaces
         LDA #' '
         JSL PUT_CHR

XWH3a    JSR INCTMP0    ;INC SA      
	 DEC <TMPC       ;REMAINING BYTE COUNT
         BNE XWH2       ;LOOP FOR 8 OR 16 BYTES      
	 LDA <DUMP_FLGS
         BIT #Flag4
         BEQ XWH3b       ;no checksum out

	 LDA <TMP4
         EOR #$FF       ;we want 1's complement
         JSL SEND_HEX_OUT       ;WRITE CKSUM      

XWH3b    JSL SEND_CR
         JSR DCMP
         BCC XWH7       ;safety play  SA is > EA

XWH5     LDX <LINE_CNT
	 INX
	 STX <LINE_CNT

	 CPX <LINE_MAX
         BEQ XWH6
         BRL XS28OUTA   ;LOOP WHILE EA >= SA

XWH6     LDX #0         ;end of page
	 STX <LINE_CNT
	 LDA <DUMP_FLGS
         BIT #Flag2        ;LCD ?
         BEQ XWH8          ;no
         JSL GET_CHR     ;yes
         LDA #3
         JSL CLEAR_LCD_DISPLAY
         BRL P_HEADER

XWH7     CLC            ;ALL DONE
         RTL            ;RETURN TO XS28OUT

XWH8     LDA <DUMP_FLGS
         BIT #Flag3     ;Header
         BEQ XWH9
         LDA #$0C       ;FORM FEED
         JSL PUT_CHR
XWH9     BRL P_HEADER



;**********************************************************
; This routine calculates the difference between where we
;   are and the end address. Athree byte value is stored
;   in DIFF(0,1,2).  The Z flag will show zero upon return.

DCMP    SEC            ;TMP2-TMP0 DBL SUBTRACT      
	LDA <TMP2       ;SUBTRACT LOW ADDRESS
	SBC <TMP0
	STA <DIFF

	LDA <TMP2+1
	SBC <TMP0+1
	STA <DIFF+1     ;OR LO FOR EQU TEST

	LDA <TMP2+2     ;NOW DO BANK REGISTER
	SBC <TMP0+2
	STA <DIFF+2     ;SAVE DIFFERENCE IN BANK SIZES
	ORA <DIFF       ;OR LO FOR EQU TEST
	ORA <DIFF+1
	RTS

    
	PAGE
;*************************************************
;*        
;*        The Slash (/) command is to allow host computers quick access
;*        to memory locations.  It has many forms:
;*
;*
;*        /<c_return> returns the current value of the address
;*                   pointer.
;*
;*        /<SPACE> returns DATA at current memory location and
;*                   increments address pointer.
;*
;*        /YY<SPACE> writes YY at current memory location pointer,
;*                   re-reads the location and returns the DATA
;*                   at that location (as a check for writeable mem)
;*                   then increments the memory location pointer.
;*
;*        /XXXX<SPACE> changes the address pointer to 00:XXXX and returns
;*                   the DATA at that location (as a check for writeable
;*                   mem) then increments the memory location pointer.
;*
;*        /bb:XXXX<SPACE> changes the address pointer to bb:XXXX and returns
;*                   the DATA at that location (as a check for writeable
;*                   mem) then increments the memory location pointer.
;*
;*        /XXXXYY<SPACE> changes the address pointer to 00:XXXX and
;*                   writes YY at current memory location pointer,
;*                   re-reads the location and returns the DATA
;*                   at that location (as a check for writeable mem)
;*                   then increments the memory location pointer.
;*
;*        /bb:XXXXYY<SPACE> changes the address pointer to bb:XXXX and
;*                   writes YY at current memory location pointer,
;*                   re-reads the location and returns the DATA
;*                   at that location (as a check for writeable mem)
;*                   then increments the memory location pointer.
;*
;*       Any error in input format will result in a NAK return
;*

SLASH:
         SEI            ;First, kill the echo! 
	 LDA <SFLAG3
         AND #ECHOFF
	 STA <TMPC       ;SAVE CURRENT STATE OF ECHO OFF
         LDA #ECHOFF    ;SET ECHO OFF      
	 TRB <SFLAG3
         CLI

         LDA #0
	 STA <TMP6+2

         JSL GET_CHR

         CMP #ESC
	 BNE ?2
	 BRL SLASH_OUT

?2       CMP #C_RETURN  ;CR...RETURN CURRENT ADDRESS POINTER
	 BNE ?3
         JSR RETURN_ADDR ;return 24 bit address pointer
	 BRL SLASH_END

?3       CMP #' '       ;SPACE...RETURN A BYTE!
	 BNE ?4
         BRL RETURN_BYTE  ;just send byte @ pointer location

?4       JSR DO_HEX
	 BCC ?5
	 BRL SLASH_OUT           ;NOT HEX

?5       LDA <TMPC+1    ;might be hi byte of 16 bits
	 STA <TMP6+1

         JSL GET_CHR
         CMP #' '
         BEQ WRITE_BYTE	;first byte was a DATA byte
         CMP #':'
         BNE NO_BANK	;just a 16 bit address

	 LDA <TMPC+1     ;ITS A BANK ADDRESS
	 STA <TMP6+2     ;save Bank address
         JSL GET_CHR	;get  hi byte of addr
         JSR DO_HEX
	 BCC ?8
	 BRL SLASH_OUT           ;NOT HEX

?8       LDA <TMPC+1     ;save hi byte of 24 bit address
	 STA <TMP6+1

?9       JSL GET_CHR	;now get low byte of address

NO_BANK CMP #ESC
	 BEQ SLASH_OUT
         JSR DO_HEX	;2 ASCII = low byte of address
	 BCS SLASH_OUT           ;NOT HEX
	 LDA <TMPC+1
	 STA <TMP6       ;save low byte for pointer

	 LDX <TMP6          ;SET ADDRESS POINTER
	 STX <TMP0          ;TO NEW VALUE
	 LDA <TMP6+2
	 STA <TMP0+2

?gc      JSL GET_CHR	;do we have more data
         CMP #' '
         BEQ RETURN_BYTE  ;send back byte at new address

         CMP #ESC
	 BEQ SLASH_OUT
         JSR DO_HEX
	 BCS SLASH_OUT           ;NOT HEX
		   ;now write this byte at the new address

WRITE_BYTE:            ;WRITE data byte
	 LDA <TMPC+1
         STA [TMP0]
         LDA #0        ;DUMMY WRITE to clear data buss and
         STA $E005     ;prevent a read-back echo from no-select.

RETURN_BYTE:           ;READ data byte
         LDA [TMP0]
         JSR WRT2OUT   ;send byte back as 2 ASCII
         JSR INCTMP0   ;Increment TMP0 by 1

SLASH_END:
	 LDA <TMPC      ;good return
	 TSB <SFLAG3    ;restore echo mode
         CLC
         RTL

SLASH_OUT:   ;error exit
	 LDA #NAK      ;SEND NAK
	 JSL PUT_CHR   
	 LDA <TMPC      ;restore echo mode
	 TSB <SFLAG3
         SEC
         RTL


RETURN_ADDR:
	 LDA <TMP0+2
         JSR WRT2OUT
	 LDA #':'
         JSL PUT_CHR
	 LDA <TMP0+1
         JSR WRT2OUT
	 LDA <TMP0
	 JSR WRT2OUT
         RTS

DO_HEX:
         JSR HEXIN
         BCS ?ERR                ;NOT HEX
         ASL A
         ASL A
         ASL A
         ASL A
	 STA <TMPC+1
?GP      JSL GET_CHR
         JSR HEXIN
         BCS ?ERR                ;NOT HEX
	 ORA <TMPC+1
	 STA <TMPC+1
         CLC
?ERR:
         RTS


	 PAGE

;*************************************************
;*        
;*        The Pipe (|) command is to allow host computers quick access
;*        to REGISTER locations.  It has many forms:
;*        
;*        
;*        |<SPACE>  returns the current value of ALL the
;*                   REGISTERS. Each register sent is separated
;*                   by a space. The order is:
;*        
;*                       1) Program Counter
;*                       2) A reg (16 bits)
;*                       3) X reg (16 bits)
;*                       4) Y reg (16 bits)
;*                       5) Stack Pointer (16 bits)
;*                       6) Direct Page (16 bits)
;*                       7) Flag reg (8 bits)
;*                       8) Bank reg (8 bits)
;*        
;*        
;*
;*        |Pbb:xxxx   Replaces the program counter with bb:xxxx.
;*
;*        |AXXXX      Replaces the contents of the Areg with xxxx.
;*
;*        |Xxxxx      Replaces the contents of the Xreg with xxxx.
;*
;*        |Yxxxx      Replaces the contents of the Yreg with xxxx.
;*
;*        |Sxxxx      Replaces the contents of the Stack Ptr with xxxx.
;*
;*        |Dxxxx      Replaces the contents of the Dircet Page register
;*                      with xxxx.
;*
;*        |Fxx        Replaces the contents of the Flag reg with xx.
;*
;*        |Bxx        Replaces the contents of the Data Bank register
;*                      with xx.
;*    NOTES:
;*        If the Areg in an eight bit mode all 16 bits will be changed
;*          the mode will remain 8 bits.
;*        If the Xreg and Yreg are in 8 bit modes only the low order
;*          8 bits will be changed.            
;*        These values are written to memory locations and are entered
;*          into the registers only on the return from software break.
;*        Echo mode (if on) will be turned off for the duration of
;*          this command. It will be restored upon completion.
;*
;*        The monitor will return a ACK upon satisfactory completion
;*
;*        Any error in input format will result in a NAK return
;*

PIPE:
         SEI            ;First, kill the echo! 
	 LDA <SFLAG3
         AND #ECHOFF
	 STA <TMPC       ;SAVE CURRENT STATE OF ECHO OFF
         LDA #ECHOFF    ;SET ECHO OFF      
	 TRB <SFLAG3
         CLI

?1       JSL GET_CHR    ;get the register ID
         LDY #0
?2       CMP Reg_ID,Y
         BEQ ?3
         INY
         CPY #9
         BNE ?2
	 BRL PIPE_ERR

?3       LDX #0
	 STX <TMP6

         LDA Reg_Size,Y
         ASL A  ;X2
         TAX
         JMP (Reg_Strt,X)


THREE_BY:
?1       JSL GET_CHR	;get BANK byte
         JSR DO_HEX
	 BCC ?2
	 BRL PIPE_ERR   ;NOT HEX

?2       LDA <TMPC+1     ;save hi byte of 24 bit address
	 STA <TMP6+2

?3       JSL GET_CHR
         CMP #':'       ;MUST HAVE BANK SEPARATOR
	 BEQ TWO_BY
	 BRL PIPE_ERR

TWO_BY:
?1       JSL GET_CHR	;get HI byte
         JSR DO_HEX
	 BCC ?2
	 BRL PIPE_ERR   ;NOT HEX

?2       LDA <TMPC+1     ;save hi byte
	 STA <TMP6+1

ONE_BY:
?1       JSL GET_CHR	;get  LOW byte
         JSR DO_HEX
	 BCC ?2
	 BRL PIPE_ERR   ;NOT HEX

?2       LDA <TMPC+1     ;save hi byte of 24 bit address
	 STA <TMP6

         LDA Reg_Addr,Y
	 STA <TMP1       ;LOW ORDER REG ADDR
         LDA #$DF
	 STA <TMP1+1     ;HI ORDER REG ADDR

         LDA Reg_Size,Y
         TAY
         DEY 

?3       LDA TMP6,Y
         STA (TMP1),Y
         DEY
         CPY #$FFFF
         BNE ?3
         LDA #ACK
         JSL PUT_CHR

PIPE_END:
	 LDA <TMPC      ;good return
	 TSB <SFLAG3    ;restore echo mode
         CLC
         RTL

PIPE_ERR   ;error exit
	 LDA #NAK      ;SEND NAK
	 JSL PUT_CHR   
	 LDA <TMPC      ;restore echo mode
	 TSB <SFLAG3
         SEC
         RTL


RET_REGS:
         LDA #$DF
	 STA <TMP1+1
         LDX #1

?2       LDA >Reg_Addr,X
	 STA <TMP1

	 LDA >Reg_Size,X
         TAY
         DEY
?3       LDA (TMP1),Y 
	 JSR WRT2OUT
         DEY
         CPY #2
         BNE ?4
         LDA #':'
         JSL PUT_CHR
?4       CPY #$FFFF
         BNE ?3
         JSL SEND_SPACE
         INX
         CPX #9
         BNE ?2
	 BRA PIPE_END



Reg_ID   .BYTE ' PAXYSDFB'
Reg_Size .BYTE 0,3,2,2,2,2,2,1,1
Reg_Addr .BYTE 0,<PCL,<ACC,<XREG,<YREG,<STK_PTR,<DIRREG,<FLGS,<DBREG
Reg_Strt .WORD RET_REGS,ONE_BY,TWO_BY,THREE_BY

	 PAGE
;******************************************

DSPLYDEC:
         JSR DECTMP0
         BRA DSPLYOLD

DSPLYINC:
         JSR INCTMP0
DSPLYOLD:
         JSR RETURN_ADDR
         JSL SEND_SPACE
         LDA [TMP0]
         JSR WRT2OUT
         RTL

	 ENDS

	 APPEND R_UTILS.ASM
