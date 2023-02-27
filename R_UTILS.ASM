;FILE = R_UTILS.ASM
;DATE = 12-29-94

	 STTL 'UTILITY ROUTINES'
	 PAGE

	 CODE

; READ HEX BYTE AND RETURN IN A, AND CY=0
; IF SPACE OR NON-HEX kCOMMA CY=1

;* Routine:  GET_HEX	 {no echo}
;*
;* Reg Used: ACC & X
;* Var Used: TEMP
;* Routines Called: GET_CHR,ASCBIN
;* Returned Reg: Acc  X & Y REGS are PRESERVED
;*

GET_HEX  PHX            ;SAVE X  
         JSL GET_CHR
         CMP #' '       ;SPACE?
         BNE ?3
	 PLX            ;IF SPACE IN FIRST ASCII, then
	 SEC            ;Cy = 1 and Areg = space
         RTL

?3       STA <TEMP       ;SAVE 1ST CHAR
         JSL GET_CHR    ;READ NEXT CHAR      

         JSR ASCBIN     ;CY = 1  IF BAD DATA
         BCS RDOERR
         PLX            ;RESTORE X 
         CLC
         RTL           

RDOERR   PLX            ;ON RETURN..CY =1 IF BAD DATA
         SEC            ;AND Areg = 0
	 LDA #0
         RTL




;*************************************************
;*   This routine inputs an ASCII chr, looks foa a
;* space. If its a space Cy is set true and the
;* space char is returned in the Areg.  If not
;* a space char, an attempt is made to this char
;* and the next char into a single HEX byte. If
;* no non-hex chars are received, the resulting
;* hex char is returned in the Areg and Cy is false.
;* If a non-hex	char is encountered, the Cy is
;* is set and a null is returned in the Areg.


;echos input chr


GET_BYTE:      ;INPUT ASCII - LOOK FOR SPACE

?1       PHX            ;SAVE X  
         JSL GET_CHR
         CMP #' '       ;SPACE?
         BEQ ?2
         CMP #ESC
         BEQ ?2
         CMP #C_RETURN
         BNE ?3

?2	 PLX
	 SEC
         RTL

?3       STA <TEMP       ;SAVE 1ST CHAR
         JSL PUT_CHR
         JSL GET_PUT_CHR    ;READ NEXT CHAR      

         JSR ASCBIN     ;CY = 1  IF BAD DATA
         PLX            ;RESTORE X 
         RTL            ;ON RETURN..CY =1 IF BAD DATA



;* Routine:  ASCBIN  ASCII TO BINARY
;*
;* Reg Used: ACC,X, and Y
;* Var Used: TMP6
;* Routines Called: HEXIN
;* Returned Reg: Acc
;*
ASCBIN   JSR HEXIN      ;ACC & X REG HAVE DATA
         BCS ASCERR     ;1ST CHAR IN TEMP (HIGH ORDER CHAR)
	 STA <TMP6       ;USE VAR TMP6
	 LDA <TEMP
         JSR HEXIN
         BCS ASCERR
         ASL A
         ASL A
         ASL A
         ASL A
	 ORA <TMP6
         CLC
         RTS

ASCERR   SEC
         RTS




;* Routine:  BINASC
;*
;* Reg Used: Acc & X
;* Var Used: NONE
;* Routines Called: ASCII
;* Returned Reg: Acc & TEMP+1           Y REG is PRESERVED
;*

BINASC   PHA            ;CONVERT BYTE TO 2
         LSR A          ;ASCII CHAR      

         LSR A
         LSR A
         LSR A
         JSR ASCII      ;CONVERT TO ASCII      
	 STA <TEMP+1
         PLA
         AND #LOWNIB
                        ;FALL THRU TO ASCII      
ASCII    CLC
         ADC #6
         ADC #HINIB
         BCC ASC1
         ADC #$06
ASC1     ADC #'9'+1     ;GT '9'  
         RTS


	 PAGE


;***************************************************************


;
;    CONVERTS ASCII HEX TO HEX
;


;* Routine:  HEXIN
;*
;*  Enter with ASCII char in the Areg.
;*  On Exit: Hex digit in Areg
;*   IF CARRY SET On RETURN, THEN NOT ASCII HEX
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: ISHEX
;* Returned Reg: Acc
;

	 global HEXIN

HEXIN    JSR ISHEX      ;IS IT HEX 
         BCS HEXNG      ;NO
         CMP #$3A
         PHP            ;SAVE STATUS      
         AND #$0F       ;STRIP OFF LO NIBBLE      
         PLP            ;GET STAT      
         BCC HEXXX      ;WAS NUMBER      
         ADC #$08       ;WAS ALPHA ADD 8+CY=9      
HEXXX    CLC
         RTS
 
HEXNG    SEC
         RTS

;* Routine:  ISHEX
;*   TESTS FOR VALID ASCII HEX DIGIT
;*   C=SET IF NOT HEX
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: UPPER_CASE
;* Returned Reg: Acc

	 global ISHEX

ISHEX    JSR UPPER_CASE ;IF NOT MAKE UPPER CASE 
         CMP #'A'       ;LESS THAN 'A'      
         BCC ISDECIMAL  ;YES,TRY NUMBER CHECK      
         CMP #'G'       ;F+1      
                        ;IF CY SET THEN GREATER THAN F      
         RTS            ;IF CY CLR THEN OK


;* Routine:  ISDECIMAL
;*   CHECKs FOR VALID ASCII Digit.
;*   If C set upon return..NOT Valid!
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: NONE
;* Returned Reg: Acc


	 global ISDECIMAL

ISDECIMAL CMP #'0'       ;IS LESS THAN '0'  
         BCC ISN1       ;YES,NG      
         CMP #'9'+1     ;IE >9      
                        ;IF CY SET THEN NG
         RTS            ;IF CY CLR THEN OK

ISN1     SEC            ;BAD GUYS EXIT  
         RTS


;* Routine:  IFASC
;*   CHECK FOR VALID ASCII
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: ISHEX
;* Returned Reg: Acc


	 global IFASC

IFASC    CMP #' '       ;IS LESS THAN SPACE  
         BCC ISN1       ;YES SO NOT ASCII       
         CMP #$7F       ;GT TILDA       
                        ;IF CY SET THEN SO NOT ASCII       
         RTS            ;IF CY CLR THEN OK



;* Routine:  UPPER_CASE
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: NONE
;* Returned Reg: Acc


	 global UPPER_CASE

UPPER_CASE CMP #'a'     ;CONVERT TO UPPER CASE
         BCC NIBBIN1    ;NOT an upper case char
         CMP #'z'+1     ;IS IT GT A 'z'      
         BCS NIBBIN1    ;NOT an upper case char
         SEC
         SBC #$20       ;MAKE IT UPPER CASE      
NIBBIN1  RTS



;* Routine:  BIN2DEC
;*    ENTER with binary number in an 8 bit Areg.
;*
;* Reg Used: Acc
;* Var Used: NONE
;* Routines Called: NONE
;* Returned Reg: Acc


	 global BIN2DEC

BIN2DEC  PHX             ;convert Acc to packed decimal (MAX 99)
         PHY
         PHP
         PHA     ;input byte
	 SEP #X8

	 LONGI OFF

	 LSR A
         LSR A
         LSR A
         LSR A
         TAY    ;Hi nibble is in Yreg
         PLA
         AND #LOWNIB
         TAX    ;Low nibble is in Xreg
         SED    ;DECIMAL ADD NEEDED!
         LDA BINDECH,Y
         CLC
	 ADC >BINDECL,X
         CLD

	 LONGI ON

	 PLP
         PLY
         PLX
         RTS






;* Routine:  DADD
;*           CALCULATE CHECKSUM
;* Reg Used: NONE
;* Var Used: TMP4
;* Routines Called: NONE
;* Returned Reg: NONE
;*
                        ;CALCULATE CHECKSUM
DADD     PHA            ;SAVE A  
         CLC
	 ADC <TMP4
	 STA <TMP4
	 LDA <TMP4+1
         ADC #0
	 STA <TMP4+1
         PLA            ;RESTORE A      
         RTS



;**********************
;MODIFIED FOR 816 CODE
;**********************

;* Routine:  INCTMP0
;*
;* Reg Used: NONE
;* Var Used: TMP0
;* Routines Called: NONE
;* Returned Reg: NONE
;*

INCTMP0  PHA            ;Increment TMP0 by 1
	 INC <TMP0       ;LO BYTE
         BNE INCT0
	 INC <TMP0+1
         BNE INCT0
	 INC <TMP0+2     ;BANK
         BNE INCT0
	 INC <WRAP
INCT0    PLA
         RTS





;* Routine:  INCTMP1 Increment TMP1 by 1
;*
;* Reg Used: NONE
;* Var Used: TMP1
;* Routines Called: NONE
;* Returned Reg: NONE
;*

INCTMP1  PHA            ;INC STRING POINTER      
	 INC <TMP1       ;LO BYTE
         BNE INCT1
	 INC <TMP1+1
         BNE INCT1
	 INC <TMP1+2     ;BANK
         BNE INCT1
	 INC <WRAP
INCT1    PLA  
         RTS

;* Routine:  DECTMP0 Decrement TMP1 by 1
;*
;* Reg Used: NONE
;* Var Used: TMP0
;* Routines Called: NONE
;* Returned Reg: NONE
;*


DECTMP0  PHA
	 LDA <TMP0
         SEC
         SBC #1
	 STA <TMP0
	 LDA <TMP0+1
         SBC #0
	 STA <TMP0+1
	 LDA <TMP0+2
         SBC #0
	 STA <TMP0+2
         PLA
         RTS



;* Routine:  DECTMP1 Decrement TMP1 by 1
;*
;* Reg Used: NONE
;* Var Used: TMP1
;* Routines Called: NONE
;* Returned Reg: NONE
;*


DECTMP1  PHA
	 LDA <TMP1
         SEC
         SBC #1
	 STA <TMP1
	 LDA <TMP1+1
         SBC #0
	 STA <TMP1+1
	 LDA <TMP1+2
         SBC #0
	 STA <TMP1+2
         PLA
         RTS

	 ENDS

	 APPEND ROM_IO.ASM
