         .STTL 'R_RAM.ASM - MENSCH RAM ASSIGNMENTS FOR ROM MONITOR
         .PAGE
         ;01-07-1995
         ;MODIFIED FOR MENSCH II




	DATA
        ORG   $00:0000

********************************************
*   THIS IS THE SERIAL I/O Xtrol FOR THE   *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************

SININDX0  DS 2         ;SERIAL 0 IN INPUT PTR
SINEND0   DS 2         ;SERIAL 0 IN OUTPUT PTR
SIN_BUF0  DS 2         ;SERIAL 0 IN BUFFER
SINCNT0   DS 2         ;SERIAL 0 BUFFER SIZE

SININDX1  DS 2         ;SERIAL 1 IN INPUT PTR
SINEND1   DS 2         ;SERIAL 1 IN OUTPUT PTR
SIN_BUF1  DS 2         ;SERIAL 1 IN BUFFER
SINCNT1   DS 2         ;SERIAL 1 BUFFER SIZE

SININDX2  DS 2         ;SERIAL 2 IN INPUT PTR
SINEND2   DS 2         ;SERIAL 2 IN OUTPUT PTR
SIN_BUF2  DS 2         ;SERIAL 2 IN BUFFER
SINCNT2   DS 2         ;SERIAL 2 BUFFER SIZE

SININDX3  DS 2         ;SERIAL 3 IN INPUT PTR
SINEND3   DS 2         ;SERIAL 3 IN OUTPUT PTR
SIN_BUF3  DS 2         ;SERIAL 3 IN BUFFER
SINCNT3   DS 2         ;SERIAL 3 BUFFER SIZE


SOUTINDX0 DS 2         ;SERIAL 0 OUT INPUT PTR
SOUTEND0  DS 2         ;SERIAL 0 OUT OUTPUT PTR
SOUTBUF0  DS 2         ;SERIAL 0 OUT BUFFER
SOUTCNT0  DS 2         ;SERIAL 0 OUT BUFFER SIZE

SOUTINDX1 DS 2         ;SERIAL 1 OUT INPUT PTR
SOUTEND1  DS 2         ;SERIAL 1 OUT OUTPUT PTR
SOUTBUF1  DS 2         ;SERIAL 1 OUT BUFFER
SOUTCNT1  DS 2         ;SERIAL 1 OUT BUFFER SIZE

SOUTINDX2 DS 2         ;SERIAL 2 OUT INPUT PTR
SOUTEND2  DS 2         ;SERIAL 2 OUT OUTPUT PTR
SOUTBUF2  DS 2         ;SERIAL 2 OUT BUFFER
SOUTCNT2  DS 2         ;SERIAL 2 OUT BUFFER SIZE
SOUTINDX3 DS 2         ;SERIAL 3 OUT INPUT PTR
SOUTEND3  DS 2         ;SERIAL 3 OUT OUTPUT PTR
SOUTBUF3  DS 2         ;SERIAL 3 OUT BUFFER
SOUTCNT3  DS 2         ;SERIAL 3 OUT BUFFER SIZE


SFLAG0    DS 1         ;SERIAL CONTROL FLAGS
		       ;BIT 6-BEEP  SFLAG0 only
SFLAG1    DS 1
SFLAG2    DS 1
SFLAG3    DS 1
		       ;BIT 0-SERIAL INPUT QUEUE DATA
		       ;BIT 1-CONTROL 'C' RECEIVED, FLUSH QUEUE
		       ;BIT 2-XON/XOFF CONTROL USED=1
		       ;BIT 3-XON/XOFF OR HDW HS SEND OVERFLOW
		       ;BIT 4-LAST CNTRL CHAR WAS XON=1 XOFF=0
		       ;BIT 5-ECHO ON/OFF FLAG OFF=1
		       ;BIT 6-OUTPUT XOFF
		       ;BIT 7-OUTPUT XON
SFLG      EQU $01
CFLG      EQU $02
XONOFLG   EQU $04
SNDOVF    EQU $08
LASTXONOF EQU $10
ECHOFF    EQU $20
SXOFFLG   EQU $40
SXONFLG   EQU $80

BEEP      EQU $40      ;SFLAG0  only

SDATA_SI0 DS 1
SDATA_SI1 DS 1
SDATA_SI2 DS 1
SDATA_SI3 DS 1

STATUS_S0 DS 1
STATUS_S1 DS 1
STATUS_S2 DS 1
STATUS_S3 DS 1
STEMP_Sx  DS 1

INPUT_XTRL  DS 1       ;INPUT PORT FLAGS
OUTPUT_XTRL DS 1       ;OUTPUT PORT FLAGS
IOTEMP      DS 1       ;OUTPUT TEMP FOR CHAR



	 PAGE
********************************************
*                                          *
*     THIS IS THE DISPLAY MAP FOR THE      *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************

DISP_PTR  DS 3         ;INDIRECT POINTER FOR LCD


DISPTYP   DS 1         ;DISPLAY TYPE AND IF
		       ;TOD DISPLAY IS ON
		       ;BIT 0-2 TYPE OF DISPLAY
		       ;BIT 3-
		       ;BIT 4-A MENSCH PLATFORM
		       ;BIT 5-POWER UP IN PROGRESS FLG
		       ;BIT 6-DISPLAY NOT WORKING
		       ;BIT 7-TOD ON DISPLAY FLG
DTYPMSK   EQU $0F      ;UP TO 8 TYPES OF DISPLAYS    >7=Default
A_MENSCH  EQU $10
PUFLG     EQU $20      ;POWER UP
NO_DISPLAY   EQU $40   ;DISPLAY NOT WORKING
DISP_TOD_FLG EQU $80   ;DISPLAY TOD


********************************************
*                                          *
*     THIS IS THE TEMP RAM MAP FOR THE     *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************

TMPRY_PTR DS 3         ;G.P. TEMPORARY POINTER

TMPC      DS 2         ;COUNT DOWN CTR FOR S28


WRAP      DS 1         ;$FF:FFFF WRAP AROUND

DIFF      DS 3         ;EA-SA = DIFF (3 BYTES)
TMP0      DS 3         ;START ADDR (3 BYTES)
TMP1      DS 3
TMP2      DS 3
TMP4      DS 3
TMP6      DS 3
TMP8      DS 3         ;USED IN REAL-TIME CLOCK DISPLAY

ERRORS    DS 1         ;S28 DOWNLOAD ERROR COUNT
TEMP      DS 2

R_TYPE    DS 1         ;USED IN LOADERS


		       ;JUMPS FOR ROM I/O
GET_CHR_JMP     DS 2
PUT_CHR_JMP     DS 2
GET_PUT_CHR_JMP DS 2
CLR_LCD_JMP     DS 2
DISP_LCD_JMP    DS 2
TXT_CUR_JMP     DS 2
SND_BEEP_JMP    DS 2
LO_PWR_JMP      DS 2


********************************************
*                                          *
*     THIS IS THE DTMF GENERATION FOR OUT  *
*           DIALING MAP FOR THE            *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************



DTMF      EQU $06      ;DTMF CONTROL TG0 & TG1
SNGL      EQU $02      ;SINGLE TONE CONTROL TG0

ATG       EQU $0       ;AUDIBLE TONE GENERATOR
T_TIME    DS 2         ;tone duration timer

INTKNT1   DS 1

	 PAGE
********************************************
*                                          *
*   THIS IS THE OTHER FEATURES MAP FOR THE *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************

DUMP_FLGS DS 1         ;(format control byte)
Flag1     EQU Bit0     ; output S28+byte-count
Flag2     EQU Bit1     ;add space after address
Flag3     EQU Bit2     ;add spaces between data bytes
Flag4     EQU Bit3     ;add checksum
Flag5     EQU Bit4     ;add : after bank addr
Flag6     EQU Bit5     ;add printer page header
Flag7     EQU Bit6     ;ASCII not Hex data

;    Working Variable Locations & Definitions

OUTBUF    DS 40        ;A STRING OUTPUT BUFFER

LINE_CNT  DS 2         ;LINE COUNT FOR OUTPUT DEVICE
LINE_MAX  DS 2         ;MAX LINES PER PAGE OR SCREEN

;         *******************                   

	 PAGE
;         **** Misc **************

COUNT     DS 2         ;RECORD COUNTER IN DUMP
CARD      DS 1         ;1 = HI   0 = LO

OUTPUT_TMP   DS 1      ;TEMPORARY OUTPUT SOURCE REG
INPUT_SRC    DS 1      ;LAST INPUT SOURCE IN GET_CHR

source     DS 4
dest       DS 4


PZLASTBYTE EQU *

PZSPACE EQU $00FF-PZLASTBYTE     ;gives space left in Page 0


	 STTL 'M_RAM.ASM - MENSCH Vectors & Buffers 100H'
	 PAGE

	  ORG $00:0100


UBRK      DS 4         ;USER BREAK
UNMI      DS 4         ;USER NMI VECTOR
UNIRQ     DS 4         ;USER IRQ VECTOR
COPIRQ    DS 4         ;USER CO-PROCESSOR IRQ
IABORT    DS 4         ;USER ABORT POINTER
PIBIRQ    DS 4         ;PERIPHERAL INTERFACE IRQ
EDGEIRQS  DS 4         ;ALL EDGE IRQS
UNIRQT7   DS 4         ;USER TIMER 7 IRQ
UNIRQT2   DS 4         ;USER TIMER 2 IRQ
UNIRQT1   DS 4         ;USER TIMER 1 IRQ
UNIRQT0   DS 4         ;USER TIMER 0 IRQ
USER_CMD  DS 4         ;USER COMMAND
URESTART  DS 4         ;USER PWR UP RESTART VECT
UALRMIRQ  DS 4         ;USER --ALARM WAKEUP CALL

;********************************************

FORMAT_FLAGS DS 1      ;FLAG BITS FOR LCD SCREEN FORMAT & UPDATES

TIME_CHK  EQU Bit0     ;TIME TO UPDATE TIME DISPLAY
DATE_CHK  EQU Bit1     ;TIME TO UPDATE DATE DISPLAY

;********************************************

;SERIAL BUFFERS FOR ROM ONLY

ROM_IBUF0 DS 10
ROM_IBUF1 DS 10
ROM_IBUF2 DS 10
ROM_IBUF3 DS 10

ROM_OBUF0 DS 10
ROM_OBUF1 DS 10
ROM_OBUF2 DS 10
ROM_OBUF3 DS 10

STR_BUF_PTR  DS 2      ;POINTER FOR INPUT BUFFER
STR_BUF_HDR  DS 3      ;A PLACE FOR HI/LO:
STR_BUF      DS 40     ;A STRING INPUT BUFFER
D_TBUF       DS 10     ;SHORT BUFFER FOR DATE & TIME


P1LASTBYTE EQU *

P1SPACE   EQU $01FF-P1LASTBYTE     ;gives space left in Page 1


;The ROM only Stack will start at 00:01FFh

	  STTL 'M_RAM.ASM - High RAM for special variables'
	  PAGE

********************************************
*                                          *
*     THIS IS THE INTERNAL RAM FOR $DF80   *
*         ALL WDC W65C265 PROGRAMS         *
*                                          *
********************************************


	  ORG $00:DF80


*******************************************************
*******************************************************
* WARNING These 12 bytes Below  MUST be kept in order *
*******************************************************
*******************************************************


ACC       DS 2         ;TEMP ACC REG
XREG      DS 2         ;TEMP X REG
YREG      DS 2         ;TEMP Y REG
STK_PTR   DS 2         ;TEMP STACK POINTER

DIRREG    DS 2         ;DIRECT PAGE REG
DBREG     DS 1         ;DATA BANK REG

FLGS      DS 1         ;CONDITIONAL CODE REG
		       ;BIT 0--CARRY BIT/EMULATION FLAG
		       ;BIT 1--ZERO BIT
		       ;BIT 2--INTERRUPT ENABLE BIT
		       ;BIT 3--BINARY CODED DECIMAL
		       ;BIT 4--INDEX REG SELECT/BRK
		       ;BIT 5--ACC REG SELECT/E-BIT
		       ;BIT 6--OVERFLOW
		       ;BIT 7--MINUS

EBIT      EQU *

*******************************************************
*******************************************************
* WARNING These 13 bytes Above  MUST be kept in order *
*******************************************************
*******************************************************



PCL       DS 1         ;PROGRAM COUNTER LOW
PCH       DS 1         ;PROGRAM COUNTER HIGH
TPBR      DS 1         ;PROGRAM BANK REG
SB_SENTL  DS 1         ;SENTINAL BYTE FOR ROMULATOR

*******************************************************
*******************************************************
* WARNING These 7 bytes Below  MUST be kept in order *
*******************************************************
*******************************************************

DAYWK     DS 1         ;DAY OF WEEK 1 = SUNDAY
		       ;7 = SATURDAY
MONTH     DS 1         ;MONTH 1= JAN 12= DEC
DAY       DS 1         ;DAY       1 TO 28,29,30,31
YR        DS 1         ;91

HR        DS 1         ;HOURS     0 TO 23
MIN       DS 1         ;MINUTES   0 TO 59
SEC       DS 1         ;SECONDS   0 TO 59


*******************************************************
*******************************************************
* WARNING These 7 bytes Below  MUST be kept in order *
*******************************************************
*******************************************************

ADAYWK    DS 1         ;DAY OF WEEK 1 = SUNDAY
		       ;7 = SATURDAY
AMONTH    DS 1         ;MONTH 1= JAN 12= DEC
ADAY      DS 1         ;DAY       1 TO 28,29,30,31
AYR       DS 1         ;91

AHR       DS 1         ;HOURS     0 TO 23
AMIN      DS 1         ;MINUTES   0 TO 59
ASEC      DS 1         ;SECONDS   0 TO 59


*******************************************************
*******************************************************
* WARNING These 7 bytes Above  MUST be kept in order *
*******************************************************
*******************************************************

H100HZ    DS 1         ;0.01 SEC (ie 10 MSEC)
H10HZ     DS 1
H1HZ      DS 1
TENTHSEC  DS 1         ;0.1 SEC

DAYLIT    DS 1         ;DAY LIGHT SAVINGS TIME
		       ;BIT 0--ENABLED =1
		       ;BIT 1-6 NU
		       ;BIT 7--IN PROCESS OF
		       ;       MODIFYING TOD
DAYLITFLG EQU $01 
DAYLPROG  EQU $80 

TODCKS    DS 2         ;clock checksum


DOWNT0    DS 2         ;COUNT DOWN TIMER 0
DOWNT1    DS 2         ;COUNT DOWN TIMER 1
DOWNT2    DS 2         ;COUNT DOWN TIMER 2
DOWNT3    DS 2         ;COUNT DOWN TIMER 3
DOWNT4    DS 2         ;COUNT DOWN TIMER 4

UPT0      DS 4         ;COUNT UP TIMER 0 FOR

PWD_CELLS DS 2         ;POWER DOWN SENTINALS

		       ;STOP WATCH

SPEED     DS 1         ;MAIN XTAL SPEED
		       ;0 = 1.843200MHZ
		       ;1 = 2.457600MHZ
		       ;2 = 3.686400MHZ
		       ;3 = 4.915200MHZ
		       ;4 = 6.144000MHZ

	  PAGE

FLAGS     DS 1         ;SYSTEM FLAGS FOR ALARM & SPEED DIALING
		       ; BIT 0 EQU ALARM ENABLE
		       ; BIT 1 EQU ALARM IRQ
		       ; BIT 2 EQU ALARM RESET
		       ; BIT 3 EQU RESET COMPENSATION
		       ; BIT 4 EQU DELAY ON DTMF DIALING
		       ; BIT 5 EQU SPEED DIAL ACTIVE
		       ; BIT 6 EQU GOT A TIMER INTERRUPT FLAG
		       ; BIT 7 EQU

TMRIFLG   EQU $40      ;TIMER INTERRUPT OCCURED FLG
SPDFLG    EQU $20      ;SPEED DIAL FLG
DIALDELY  EQU $10      ;DELAY ON DTMF
RES_COMP  EQU $08      ;ADD RESET TIME TO TOD CLOCK
ALRMRST   EQU $04      ;RESET ALARM
ALRMIRQ   EQU $02      ;ALARM IS ACTIVE
ALRMENAB  EQU $01      ;ALARM IS SET


DTMFTMR   DS 1         ;DTMF DURATION COUNTER

PD_TIMER  DS 2

DFLASTBYTE EQU *

DFSPACE   EQU $DFBF-DFLASTBYTE     ;gives space left in the INTERNAL RAM

	  ENDS

	  APPEND ASCII.H
