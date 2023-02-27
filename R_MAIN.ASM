;File: R_MAIN.asm
;Date: 01-07-95

	 STTL 'MAIN ROUTINE'
	 PAGE

	 CODE

ROM_START:
	 REP #X8	;SET X & Y Long
         SEP #M8       ;SET Acc SHORT

	 LONGA OFF
	 LONGI ON


         JSL SEND_CR
         LDA #'>'       ;TYPE PROMPTING '>'      
         JSL PUT_CHR

S00      JSL GET_CHR
         CMP #$0A       ;IGNORE LINE FEED - LEFT OVER
         BEQ S00        ;FROM PREVIOUS CR
?00      JSL PUT_CHR
         BCS ?00

;
;        Raw character is in A.  May be wrong case, etc.  We will JSR to
;        alt. parsing if it exists at this point.  The alternate parser
;        will jump through the vector table to START if it completes the
;        command, and will do an RTS to the regular parser if it does not
;        have the command in its table.

S0:
	 REP #X8	;SET X & Y Long
         SEP #M8       ;SET Acc SHORT

	 LONGA OFF
	 LONGI ON

DFLTPRSR:
         JSR UPPER_CASE ;IN ACC/ MAKE SURE      
                        ;UPPERCASE      
         LDX #ADRS-CMDS-1     ;LENGTH OF CMD TABLE
S1       CMP !CMDS,X
         BEQ S2
         DEX
         BPL S1         ;LOOP FOR ALL CMDS      

         LDA #'?'       ;OPERATOR ERR, TYPE'?'      
         JSL PUT_CHR
         BRA RDY        ;GOTO READY

S2	 REP #M8
         LONGA ON

         TXA
         ASL A          ;X2      
         TAX

	 SEP #M8
         LONGA OFF

         JSL SEND_SPACE2
	 JSL IJMP
RDY      LDA #0
         LDX #Ready_Now
         JSL PUT_STR
	 BRA S00


Ready_Now BYTE $0D,'READY',$0D,'>',00


IJMP     JMP (ADRS,X)


	 STTL 'R_MAIN.ASM - Command Tables/pointers'
	 PAGE

;COMMANDS USED
;A,B,D,F,G,H,J,M,N
;R,S,T,U,W,X
;<,>, ,?,/,|


;COMMANDS NOT YET USED
;C,E,I,K,L,O,P,Q,V,Y,Z
;+,-,!,@,%,^,&,[,],\,{,},~,',",`




CMDS     BYTE 'A'      ;ALTER REGISTERS
	 BYTE 'M'      ;CHANGE A MEMORY LOC
	 BYTE '<'      ;DEC TO NXT MEMORY LOC
	 BYTE '>'      ;INC TO NXT MEMORY LOC
	 BYTE ' '      ;REDISPLAY OLD LOCATION

	 BYTE 'R'      ;DISPLAY REGISTERS
	 BYTE 'G'      ;GO/JML
	 BYTE 'J'      ;JSL
	 BYTE 'D'      ;DUMP MEMORY IN HEX
	 BYTE 'F'      ;FILL MEMORY

	 BYTE '?'      ;HELP MENU
	 BYTE 'H'      ;HELP MENU
	 BYTE 'T'      ;DISPLAY AND/OR MODIFY TIME
	 BYTE 'N'      ;DISPLAY AND/OR MODIFY DATE
	 BYTE 'S'      ;S28 LOADER FROM MONITOR

	 BYTE 'W'      ;S28 DUMPER
	 BYTE 'X'      ;POWER DOWN
	 BYTE '/'      ;QUICK ACCESS TO MEM FOR HOSTS
	 BYTE '|'      ;QUICK ACCESS TO REGISTERS FOR HOSTS
	 BYTE 'U'      ;USER COMMAND
	 BYTE 'B'      ;SET BREAKPOINT

	 BYTE '*'      ;returnto mensch computer


ADRS     WORD ALTER_REGS     ;CHANGE CURRENT REGS
	 WORD Alter_Memory   ;ALTER MEMORY LOCATIONS
	 WORD DSPLYDEC       ;DEC ADDR & DISPLAY
	 WORD DSPLYINC       ;INC ADDR & DISPLAY
	 WORD DSPLYOLD       ;DISPLAY CURRENT ADDR

	 WORD DUMPREGS       ;DISPLAY REGS
	 WORD GO_JML         ;GO/JML
	 WORD GO_JSL         ;JSL
	 WORD Dump_to_Output ;DUMP MEMORY IN HEX
	 WORD FILL_Memory    ;FILL MEMORY WITH A CONSTANT

	 WORD HELP           ;HELP MENU
	 WORD HELP           ;HELP MENU
	 WORD DTIME          ;DISPLAY TIME OF DAY
	 WORD DDATE          ;DISPLAY DATE
	 WORD XS28ROM        ;MOTOROLA S28 LOADER FROM MONITOR

	 WORD DumpS28        ;MOTOROLA S28 DUMP
	 WORD ENTER_LOW_POWER_MODE
	 WORD SLASH          ;HOST MEMORY ACCESS
	 WORD PIPE           ;HOST REGISTER ACCESS
	 WORD USER_CMD       ;USER COMMAND
	 WORD SET_Breakpoint

	 WORD RET_TO_MENSCH


	 STTL 'DBGSPCL.ASM - 65C816 Display All Registers'
	 PAGE



;        8 bits        
; ____________________ 
; |                  | 
; |  Data Bank Reg   | 
; |      (DBR)       | 
; |__________________| 


;                                8 bits                  8 bits
;                          ___________________     ____________________
;                          |                 |     |                  |
;                          |    X Reg High   |     |     X Reg Low    |
;                          |       (XH)      |     |        (XL)      |
;                          |_________________|     |__________________|


;                          ___________________     ____________________
;                          |                 |     |                  |
;                          |    Y Reg High   |     |     Y Reg Low    |
;                          |       (YH)      |     |        (YL)      |
;                          |_________________|     |__________________|


; ____________________     ___________________     ____________________
; |                  |     |                 |     |                  |
; |                  |     | Stack Reg High  |     |  Stack Reg Low   |
; |        00        |     |       (SH)      |     |       (SL)       |
; |__________________|     |_________________|     |__________________|


;                          ___________________     ____________________
;                          |                 |     |                  |
;                          |   Accumulator   |     |    Accumulator   |
;                          |      (B)        |     |       (A)        |
;                          |_________________|     |__________________|



; ____________________     ___________________     ____________________
; |                  |     |                 |     |                  |
; | Program Bank Reg |     | Program Cntr Hi |     | Program Cntr Low |
; |      (PBR)       |     |      (PCH)      |     |       (PCL)      |
; |__________________|     |_________________|     |__________________|

                             
; ____________________     ___________________     ____________________
; |                  |     |                 |     |                  |
; |                  |     | Direct Reg High |     |  Direct Reg Low  |
; |        00        |     |       (DH)      |     |        (DL)      |
; |__________________|     |_________________|     |__________________|


; ____________________  
; |                  | 
; |    Status Reg    |
; |      (FLAGS)     |     
; |__________________|     

;  N  V  M  X  D  I  Z  C
;  |  |  |  |  |  |  |  |_Carry             1 = True
;  |  |  |  |  |  |  |____Zero              1 = Result Zero
;  |  |  |  |  |  |_______IRQ Disable       1 = Disable
;  |  |  |  |  |__________Decimal Mode      1 = True
;  |  |  |  |_____________Index Reg Select  1 = 8 bit  0 = 16 bit mode
;  |  |  |________________Memory Select     1 = 8 bit  0 = 16 bit mode
;  |  |___________________Overflow          1 = True
;  |______________________Negative          1 = Negative


;*******************
;*
;NEW FORM
;     
;     PCntr   Acc    X      Y      S      Dir    F   B
;     00:8000 00 EA  00 01  00 00  01 FD  00 00  4F  00
;     Status Reg
;     N  V  M  X  D  I  Z  C
;     0  1  0  0  1  1  1  1


	 STTL 'R_MAIN .. HELP LIST'
	 PAGE



HELP:

          LDA #0        ;BANK
          LDX #HELPMENU
          JSL PUT_STR   ;WILL RETURN TO DISPATCHER
          JSL SEND_CR
          RTL



HELPMENU BYTE $0D
	 BYTE 'M      Alter memory',$0D
	 BYTE 'SPACE  Display memory address',$0D
	 BYTE '<,>    Decrement, Increment memory address',$0D
	 BYTE 'D      Dump memory',$0D
	 BYTE 'R      Display registers',$0D
	 BYTE 'B      SET Breakpoint',$0D
	 BYTE 'G,J    JML, JSL, to PC [location]',$0D
	 BYTE 'F      Block Fill',$0D
	 BYTE 'S,W    S28 Input, Output',$0D
	 BYTE '?,H    HELP',$0D
	 BYTE 'T      Display & Change Time',$0D
	 BYTE 'N      Display & Change Date',$0D
	 BYTE 'X      EXIT to Low Power Mode',$0D,$0D
	 BYTE '/      Host memory access',$0D
	 BYTE '|      Host register access',$0D
	 BYTE 'U      USER command',$0D
	 BYTE $0      ;string termination



	 STTL 'R_MAIN .. COMMANDS
	 PAGE

GO_JSL:                 ;LEAVE RETURN ON STACK
        JSR GET_SAVE_PC
        BCC ?G 
        RTL

?G      PLX     ;POP STACK
        PLA
        LDA #0  ;SETUP RETURN TO BREAK SOFTWARE
        PHA
	LDY #JSL_RTL_IN-1
        PHY
        TSX
	STX STK_PTR
        BRA go8

GO_JML:
        JSR GET_SAVE_PC
        BCC go8 

  	CMP #C_RETURN	;ENTER KEY
        BEQ go8
        RTL

go8     JMP GO_AGAIN	;RESTART FROM OLD PC VALUE



GET_SAVE_PC:
        JSL Get_Address  ;starting address 
 	BCS ?X
	LDX <TMP2
        STX PCL
	LDA <TMP2+2
	STA >TPBR
?X      RTS

ENTR_TIME BYTE $0D,'ENTER NEW TIME  ',$0D,0
ENTR_DATE BYTE $0D,'ENTER NEW DATE  ',$0D,0


DTIME:
        JSL SEND_CR
        LDX #OUTBUF
        JSL READ_TIME
        LDA #0
        LDX #OUTBUF
        JSL PUT_STR
	LDA #0
        LDX #ENTR_TIME	
        JSL PUT_STR
	LDA #0
        LDX #STR_BUF
        JSL GET_STR
        BCS ?X
	JSL SET_TIME

?X      RTL


DDATE:
        JSL SEND_CR
        LDX #OUTBUF
        JSL READ_DATE
        LDA #0
        LDX #OUTBUF
        JSL PUT_STR
	LDA #0
        LDX #ENTR_DATE	
        JSL PUT_STR
	LDA #0
        LDX #STR_BUF
        JSL GET_STR
        BCS ?X
	JSL SET_DATE

?X      RTL

;***************************************************8
;*      Version returns pointers to 
;*          1) a 4 ASCII chr version # in the Xreg
;*             ie  "2.01"
;*
;*          2) a formated ASCII string of the last
;*        assembly date in Yreg.
;*             ie  "SAT DEC  3 12:16:05 1994"
;*
;*      The Areg is set to 0 upon return.
;*



VERSION:
         LDA #0
         LDX #MONVRS
         LDY #MONDATE
         RTL

	 ENDS

	 APPEND R_PWRDWN.ASM
