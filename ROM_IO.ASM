; FILE: ROM_IO.ASM
; DATE: 12-17-94

	 STTL 'ROM I/O ROUTINES'
	 PAGE

	 CODE

SET_GET_PUT_CHR:        ;ROUTINE FOR ROM SETUP
 
        LDX #ROM_GET_CHR
	STX <GET_CHR_JMP
	LDX #GET_PUT_PC_CHR
	STX <GET_PUT_CHR_JMP
        LDX #ROM_PUT_CHR
	STX <PUT_CHR_JMP
        RTS


GET_CHR:        ;ROM ROUTINE

        JMP (GET_CHR_JMP)

ROM_GET_CHR:

?1      JSL GET_BYTE_FROM_PC
        BCS ?1
        RTL

;******************************           

PUT_CHR:

        JMP (PUT_CHR_JMP)


ROM_PUT_CHR:

?1      JSL SEND_BYTE_TO_PC  ;WAIT FOR BUFFER READY
        BCS ?1
        RTL


;*******************************

GET_PUT_CHR:
 
	JMP (GET_PUT_CHR_JMP)


GET_PUT_PC_CHR:

?1      JSL GET_BYTE_FROM_PC
        BCS ?1
?2      JSL SEND_BYTE_TO_PC
        BCS ?2
        RTL

;*******************************


SEND_CR:

        LDA #C_RETURN
	JMP PUT_CHR

SEND_SPACE2:
        JSL SEND_SPACE
SEND_SPACE:

        LDA #' '
        JMP PUT_CHR



BACKSPACE2:
         LDA #BKSP	;BACKUP 1 char position
         JSL PUT_CHR 
BACKSPACE:
         LDA #BKSP	;BACKUP 2nd char position
         JSL PUT_CHR 
         RTL




CLEAR_LCD_DISPLAY:
        JSL SEND_CR
        LDA #3
	JMP (CLR_LCD_JMP)


DISP_LCD_STRNG:
        JMP (DISP_LCD_JMP)


POSITION_TEXT_CURSOR:
        JMP (TXT_CUR_JMP)


SEND_BEEP:
        JMP (SND_BEEP_JMP)




RTL_EXIT:
        RTL

;*****************************************************
	 PAGE

;*
;*   This routine asks for a 3 byte address,
;*     checks it and leaves it in TMP2.
;*
;*   If an error is encounterd, a Cy=1 is returned.
;*
;*




Get_Address:

         LDA #3
         JSL CLEAR_LCD_DISPLAY

;     SETUP THE STARTING ADDRESS    in TMP0
         LDX #0
         LDA #04
         JSL POSITION_TEXT_CURSOR

         LDA #0
         LDX #Enter_ADDR
	 BRA GET_A_OUT


Enter_ADDR DC 'Enter Address  BB:AAAA '
Enter_SA  DC 'Enter Lowest Address   BB:AAAA '
Enter_EA  DC 'Enter Highest Address  BB:AAAA '


;*****************************************************
	 PAGE

;*
;*   This routine asks for a 3 byte starting address,
;*     checks it and leaves it in TMP2.
;*
;*   If an error is encounterd, a Cy=1 is returned.
;*
;*




Get_S_Address:

         LDA #3
         JSL CLEAR_LCD_DISPLAY

;     SETUP THE STARTING ADDRESS    in TMP0
         LDX #0
         LDA #04
         JSL POSITION_TEXT_CURSOR

         LDA #0
         LDX #Enter_SA
GET_A_OUT:
         JSL PUT_STR
         JSL GET_3BYTE_ADDR
	 RTL


;*****************************************************

;*
;*   This routine asks for a 3 byte ending address,
;*     checks it and leaves it in TMP2.
;*
;*   If an error is encounterd, a Cy=1 is returned.
;*
;*




Get_E_Address:


;     SETUP THE ENDING ADDRESS    in TMP0
         JSL SEND_CR
         LDX #0
         LDA #05
         JSL POSITION_TEXT_CURSOR

         LDA #0
         LDX #Enter_EA
	 BRA GET_A_OUT



;**********************************************************
;*
;*   GET_3BYTE_ADDR    Asks for input bytes to form a 
;*                     24 bit address. Characters are
;*                       received from any input device
;*                       selected by the CONTROL INPUT 
;*                       routine.
;*
;*    Must enter with a JSL command!  Areg = 8 bits.
;*
;*   This Routine inserts a ':' after the bank address.
;*
;*    INPUT FORMAT =  BB:AAAA
;*
;*    3 Byte result returned in TMP2, +1, +2 (address order)
;*
;*    A Cy = 1 will be returned for the following reasons:
;*
;*	   1) No input device selected.
;*	   2) An ESC or ENTER received before 6 chars.
;*	   3) One of the 6 chars inputted is non-hex.
;*
;*


GET_3BYTE_ADDR  EQU *

         PHY
         PHX
         LDY #0
?2	 JSL GET_PUT_CHR
         BCS ?5
	 CMP #ESC
	 BEQ ?4
         CMP #C_RETURN
         BEQ ?4
         CMP #BKSP
         BEQ ?88
         JSR ISHEX      ;IS IT HEX 
	 BCS ?8
	 STA |STR_BUF,Y
         INY
         CPY #7
         BEQ ?3        ;DONE
         CPY #2
         BNE ?2
         LDA #':'      ;ADD COLON AFTER BANK ADR
	 STA |STR_BUF,Y
         JSL PUT_CHR
         INY
         BRA ?2

?3       LDA #0
         LDX #STR_BUF
         JSL ADDR_IN    ;IF Cy IS SET OK FOR ERROR
         BRA ?5

?4       SEC
?5       PLX
         PLY
         RTL


?8       LDA #BKSP
	 JSL PUT_CHR


?88      CPY #0
         BEQ ?2
         DEY
         CPY #2
         BNE ?2
         LDA #BKSP
	 JSL PUT_CHR
         DEY
         BRA ?2



	 PAGE
;**********************************************************

;*    ADDR_IN     CONVERTS AN ASCII STRING TO AN ADDR
;*
;*    Must enter with a JSL command!  Areg = 8 bits.
;*
;*    INPUT FORMAT =  BB:AAAA
;*
;*    Address of the string:  Areg = Bank  Xreg = 16 Bit addr
;*
;*    3 Byte result returned in TMP2, +1, +2
;*

ADDR_IN	 PHY
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

	 STX <TMPRY_PTR
         LDY #0
	 JSR HEX2IN
	 BCS ?xx
	 STA <TMP2+2     ;BANK FINISHED
         INY
         LDA (TMPRY_PTR),Y
         CMP #':'
         BNE ?xx
         INY
	 JSR HEX2IN
	 BCS ?xx
	 STA <TMP2+1
         INY
         JSR HEX2IN
         BCS ?xx
	 STA <TMP2       ;ADDR LOW FINISHED
	 CLC
	 BRA ?XXE

?xx      SEC
?XXE	 PLB
         PLD
	 PLY
	 RTL


HEX2IN   LDA (TMPRY_PTR),Y  ;TWO ASCII TO 1 HEX
         JSR HEXIN
         BCS ?xxx
         ASL A
         ASL A
         ASL A
         ASL A
	 STA <TEMP
         INY
         LDA (TMPRY_PTR),Y
         JSR HEXIN
         BCS ?xxx
	 ORA <TEMP
	 CLC
	 RTS

?xxx     SEC
         RTS

;******************************************
	 PAGE

;*  This routine is used to write a 3 byte
;*    address to the selected outputs in
;*    ASCII-Hex.  The address to be sent
;*    out must be loaded into TMP0.
;*

WR_3_ADDRESS:  ;WRITE OUT A 3 BYTE ADDRESS
         LDA >TMP0+2    
         JSL SEND_HEX_OUT
         LDA #':'
         JSL PUT_CHR
         LDA >TMP0+1
         JSL SEND_HEX_OUT
         LDA >TMP0
         JSL SEND_HEX_OUT
         RTL


;*******************************************
;*
;*    SEND_HEX_OUT
;*
;*    This routine takes a HEX value from an
;*  eight bit Areg, converts it to two ASCII
;*  characters and outputs them to the selected
;*  outputs. 
;*
;*    Must call with a JSL command
;*
;*  Routine calls BINASC, PUT_CHR



SEND_HEX_OUT: 

         PHX            ;WRITE BYTE AS 2 HEX CHAR  
         JSR BINASC     ;UNPACK BYTE DATA INTO      
                        ;TWO ASCII CHARS.      
                        ;LOW in Areg, HI in TEMP+1

         PHA            ;WRITE 2 CHARS
         LDA >TEMP+1     ;WRITE HI BYTE FIRST      
         JSL PUT_CHR
         PLA            ;LOW BYTE
         JSL PUT_CHR
         PLX
         RTL


;*******************************************************

CKNOUT   JSR DADD       ;CALCULATE CHECKSUM
	 JSL SEND_HEX_OUT
	 RTS

WRT2OUT  PHX            ;WRITE BYTE AS 2 HEX CHAR  
         JSR BINASC     ;UNPACK BYTE DATA INTO      

         PHA            ;WRITE 2 CHARS-X,A=CHARS
         LDA >TEMP+1    ;WRITE HI BYTE FIRST      
         JSL PUT_CHR
         PLA
         JSL PUT_CHR
         PLX
         CLC
         RTS





;**********************************************
	 PAGE


;*  PUT_STR  =  SUBROUTINE TO OUTPUT AN ASCII STRING.
;*
;*  This routine must called with a JSL command!
;*
;*   This routine OUTPUTS a string to each of the output
;*      PORTS selected by the CONTROL_OUTPUT routine.
;*
;*   C flag = 1 is returned if no output ports have been
;*      enabled via the CONTROL_OUTPUT routine!
;*
;*  Enter with a 8 bit Areg containing bank address and
;*    a 16 bit Xreg containing 16 bit address pointing to
;*    the string buffer to be used. The maximum string 
;*    size is limited to 640 characters.
;*
;*   The string must be terminated with a NULL or have
;*    Bit 7 of the last character equal to a 1.
;*
;*
;*   All registers are saved!
;*

PUT_STR:    ;OUTPUT A STRING

	 PHA
	 PHX
         PHY
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

	 STA <TMP4+2
	 STX <TMP4
	 LDY #0
1?	 LDA [TMP4],Y
         BEQ 2?
         PHP
         AND #$7F
3?       JSL PUT_CHR
         BCS 3?
	 PLP
         BMI 2?
         INY
         CPY #640
         BNE 1?
2?       CLC
	 BRA 5?

4?       PLP
         SEC
5?	 PLB
         PLD
	 PLY
         PLX
	 PLA
	 RTL

**********************************************

	 PAGE

;*  GET_STR
;*
;*  GET_STR  USES GET_PUT_CHR TO RECEIVE CHARACTERS AND
;*    PUTS THEM INTO STR_BUF. THE STRING IS TERMINATED
;*    WHEN AN ENTER OR AN ESC IS RECEIVED.  THE COMPLETED
;*    STRING IS TERMINATED WITH A NULL CHR.
;*
;*  Enter with a 8 bit Areg containing bank address and
;*    a 16 bit Xreg containing 16 bit address pointing to
;*    the string buffer to be used.
;*
;*  IF TERMINATED WITH AN ESC, Cy WILL BE SET UPON RETURN.
;*   
;*  A NULL STRING is returned if no input sources have
;*    been enabled using the CONTROL_INPUT routine!
;*
;*
;* WARNING: MUST use a 'JSL' to call this routine!
;*


GET_STR:
         PHA
         PHX
         PHY
         PHD            ;SAVE DIRECT REG
         PHB
         PEA #$0000
         PLD            ;SET DIRECT PAGE REG TO PAGE 0
         PEA #$0000     ;SET DATA BANK TO 0
         PLB
         PLB	

	 STX <TMPRY_PTR
	 STA <TMPRY_PTR+2
         LDY #0
1?       STY STR_BUF_PTR
2?       JSL GET_PUT_CHR
         BCS 4?
         CMP #BKSP
         BNE 3?
         LDY STR_BUF_PTR
         BEQ 2?
         DEY
         STY STR_BUF_PTR
         BRA 2?
       
3?       CMP #ESC
         BEQ 5?
         LDY STR_BUF_PTR
	 STA [TMPRY_PTR],Y
         INY
         STY STR_BUF_PTR
         CMP #C_RETURN
         BNE 1?
4?       LDA #0         ;ADD END OF STRNG
	 STA [TMPRY_PTR],Y
         CLC
	 BRA 6?

5?     	 SEC
6?       PLB
         PLD
         PLY
         PLX
         PLA
         RTL

;**********************************************

	 ENDS

	 APPEND R_TONES.ASM
