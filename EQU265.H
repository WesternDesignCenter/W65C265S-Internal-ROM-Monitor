	 STTL 'EQU265.ASM--GLOBAL EQUATES FOR WDC65C265'
	 PAGE
         ;08-06-1994

	 DATA

POWER_DOWN_COUNT EQU 1800       ;TIME OUT IN SECONDS

LOWNIB   EQU $0F
HINIB    EQU $F0

Bit0     EQU 1
Bit1     EQU 2
Bit2     EQU 4
Bit3     EQU 8
Bit4     EQU 16
Bit5     EQU 32
Bit6     EQU 64
Bit7     EQU 128

********************************************
*                                          *
*     THIS IS THE INTERNAL RAM MAP FOR     *
*         ALL WDC W65C265 PROGRAMS         *
*                                          *
********************************************

;576 BYTES

;$00:0000 - $00:01FF
;$00:DF80 - $00:DFBF


********************************************
*                                          *
*     THIS IS THE GLOBAL EQUATES FOR       *
*         ALL WDC W65C265 PROGRAMS         *
*                                          *
********************************************

X8       EQU   $10
M8       EQU   $20

PD0      EQU   $FD00   PORT 0 DATA REGISTER
PD1      EQU   $FD01   PORT 1 DATA REGISTER
PD2      EQU   $FD02   PORT 2 DATA REGISTER
PD3      EQU   $FD03   PORT 3 DATA REGISTER
PDD0     EQU   $DF04   PORT 0 DATA DIRECTION REGISTER
PDD1     EQU   $DF05   PORT 1 DATA DIRECTION REGISTER
PDD2     EQU   $DF06   PORT 2 DATA DIRECTION REGISTER
PDD3     EQU   $DF07   PORT 3 DATA DIRECTION REGISTER


RVD08    EQU   $DF08   RESERVED $FD08-FD1F

VCS0 EQU $00DF10  ;LCD CONTROL VIA

VIA_PB          EQU VCS0        ;PB0-PB7 IS FOR DATA
VIA_PA          EQU VCS0+1      ;PA  IS USED FOR CONTROL
VIA_PDDB        EQU VCS0+2
VIA_PDDA        EQU VCS0+3
V_PT1CL         EQU VCS0+4
V_PT1CH         EQU VCS0+5
V_PT1LL         EQU VCS0+6
V_PT1LH         EQU VCS0+7
V_PT2CL         EQU VCS0+8
V_PT2CH         EQU VCS0+9
VIA_PSR         EQU VCS0+10
VIA_ACR         EQU VCS0+11
VIA_PCR         EQU VCS0+12
VIA_PIFR        EQU VCS0+13
VIA_PIER        EQU VCS0+14
VIA_P0RA        EQU VCS0+15


PD4      EQU   $DF20   PORT 4 DATA REGISTER
PD5      EQU   $DF21   PORT 5 DATA REGISTER
PD6      EQU   $DF22   PORT 6 DATA REGISTER
PD7      EQU   $DF23   PORT 7 DATA REGISTER
PDD4     EQU   $DF24   PORT 4 DATA DIRECTION REGISTER
PDD5     EQU   $DF25   PORT 5 DATA DIRECTION REGISTER
PDD6     EQU   $DF26   PORT 6 DATA DIRECTION REGISTER

PCS7     EQU   $DF27   PORT 7 CHIP SELECT ENABLE REGISTER
                        ;BIT 0-PCS70  SEL PORT REPLACEMENT & EXPANSION
                        ;BIT 1-PCS71  SEL COPROCESSOR EXPANSION
                        ;BIT 2-PCS72  SEL ON CHIP STUFF
                        ;BIT 3-PCS73  SEL 000200-007FFF  'CACHE' MEMORY
                        ;BIT 4-PCS74  SEL 8000-DEFF & E000-FFFF ROM
                        ;BIT 5-PCS75  SEL 4Meg ie BANKS 00-3F
                        ;BIT 6-PCS76  SEL 8Meg ie BANKS 40-BF
                        ;BIT 7-PCS77  SEL 4Meg ie BANKS C0-CF

RVD28    EQU   $DF28   RESERVED $DF28-$DF3F

BCR      EQU   $DF40   BUS CONTROL REGISTER
			;134
                        ;BIT 0-EXTERNAL MEM BUS ENABLE
                        ;BIT 1-PORT 44-47 EDGE SENS IRQ
                        ;BIT 2-ALWAYS 0
                        ;BIT 3-ICE ENABLE=1
                        ;BIT 4-PORT 50-53 EDGE SENS IRQ
                        ;BIT 5-PORT 54-57 EDGE SENS IRQ
                        ;BIT 6-NMI,IRQ1,IRQ2 ENABLE = 1
                        ;BIT 7-EXTERNAL $F000-$FFFF = 1
			;265
                        ;BIT 0-EXTERNAL MEM BUS ENABLE
                        ;BIT 1-TONE GEN 0 ENABLE
                        ;BIT 2-TONE GEN 1 ENABLE
                        ;BIT 3-ICE ENABLE=1
                        ;BIT 4-MONITOR "WATCH DOG" ENABLE
                        ;BIT 5-ABORT ENABLE = 1 ON P40
                        ;BIT 6-NMI ENABLE = 1 ON P40
                        ;BIT 7-EXTERNAL $E000-$FFFF = 1


SSCR     EQU   $DF41   SYSTEM SPEED CONTROL REGISTER
                        ;BIT 0-FCLK START/STOP       1 = START FCLK
                        ;BIT 1-PHI2                  1 = PHI2 CLK AS FCLK/4
                        ;BIT 2-EXTERNAL RAM SELECT   1 = EXT $0000-$01FF
                        ;BIT 3-SYS CS0-CS7 SPEED SEL 1 = FAST FCLK
                        ;BIT 4-CS4 SPEED SEL         1 = FAST
                        ;BIT 5-CS5 SPEED SEL         1 = FAST
                        ;BIT 6-CS6 SPEED SEL         1 = FAST
                        ;BIT 7-CS7 SPEED SEL         1 = FAST

TCR      EQU   $DF42   TIMER CONTROL REGISTER
                        ;BIT 0-TIMER 4 INPUT CLOCK 0 = FCLK
                        ;BIT 1-TIMER 4 OUTPUT ENABLE 1 = OUTPUT ON P61
                        ;BIT 2 & 3-PWM  00 = DISABLE,       01 = POSITIVE EDGE
                        ;BIT 3-         10 = NEGATIVE EDGE, 11 = BOTH EDGES
                        ;BIT 4-UART0 TIMER SELECT 0 = TIMER 3, 1 = T4
                        ;BIT 5-UART1 TIMER SELECT 0 = TIMER 3, 1 = T4
                        ;BIT 6-UART2 TIMER SELECT 0 = TIMER 3, 1 = T4
                        ;BIT 7-UART3 TIMER SELECT 0 = TIMER 3, 1 = T4


;T0 = MONITOR "WATCH DOG"
;T1 = TIME OF DAY CLOCK
;T2 = PRESCALED INTERRUPT (UP COUNTER )
;T3 = UART #2
;T4 = UART #3
;T5 = TONE GENERATOR
;T6 = TONE GENERATOR
;T7 = PWM

TER      EQU   $DF43   TIMER ENABLE REGISTER
                        ;BIT 0-TIMER 0  1 = ENABLE
                        ;BIT 1-TIMER 1  1 = ENABLE
                        ;BIT 2-TIMER 2  1 = ENABLE
                        ;BIT 3-TIMER 3  1 = ENABLE
                        ;BIT 4-TIMER 4  1 = ENABLE
                        ;BIT 5-TIMER 5  1 = ENABLE
                        ;BIT 6-TIMER 6  1 = ENABLE
                        ;BIT 7-TIMER 7  1 = ENABLE
T0FLG    EQU $01
T1FLG    EQU $02
T2FLG    EQU $04
T3FLG    EQU $08
T4FLG    EQU $10
T5FLG    EQU $20
T6FLG    EQU $40
T7FLG    EQU $80


TIFR     EQU   $DF44   TIMER INTERRUPT FLAG REGISTER
                        ;BIT 0-TIMER 0  1 = INTERRUPT PENDING
                        ;BIT 1-TIMER 1  1 = INTERRUPT PENDING
                        ;BIT 2-TIMER 2  1 = INTERRUPT PENDING
                        ;BIT 3-TIMER 3  1 = INTERRUPT PENDING
                        ;BIT 4-TIMER 4  1 = INTERRUPT PENDING
                        ;BIT 5-TIMER 5  1 = INTERRUPT PENDING
                        ;BIT 6-TIMER 6  1 = INTERRUPT PENDING
                        ;BIT 7-TIMER 7  1 = INTERRUPT PENDING

EIFR     EQU   $DF45   EDGE INTERRUPT FLAG REGISTER
                        ;BIT 0-PE56 EDGE IRQ
                        ;BIT 1-NE57 EDGE IRQ
                        ;BIT 2-PE60 EDGE IRQ
                        ;BIT 3-PWM  PROGRAMABLE EDGE IRQ (P62)
                        ;BIT 4-NE64 EDGE IRQ
                        ;BIT 5-NE66 EDGE IRQ
                        ;BIT 6-PIB       IRQ
                        ;BIT 7-IRQ  LEVEL IRQ

TIER     EQU   $DF46   TIMER INTERRUPT ENABLE REGISTER
                        ;BIT 0-TIMER 0  1 = IRQ ENABLE
                        ;BIT 1-TIMER 1  1 = IRQ ENABLE
                        ;BIT 2-TIMER 2  1 = IRQ ENABLE
                        ;BIT 3-TIMER 3  1 = IRQ ENABLE
                        ;BIT 4-TIMER 4  1 = IRQ ENABLE
                        ;BIT 5-TIMER 5  1 = IRQ ENABLE
                        ;BIT 6-TIMER 6  1 = IRQ ENABLE
                        ;BIT 7-TIMER 7  1 = IRQ ENABLE

EIER     EQU   $DF47   EDGE INTERRUPT ENABLE REGISTER
                        ;BIT 0-PE56 EDGE IRQ                   1 = IRQ ENABLE
                        ;BIT 1-NE57 EDGE IRQ                   1 = IRQ ENABLE
                        ;BIT 2-PE60 EDGE IRQ                   1 = IRQ ENABLE
                        ;BIT 3-PWM  PEOGRAMABLE EDGE IRQ (P62) 1 = IRQ ENABLE
                        ;BIT 4-NE64 EDGE IRQ                   1 = IRQ ENABLE
                        ;BIT 5-NE66 EDGE IRQ                   1 = IRQ ENABLE
                        ;BIT 6-PIB  IRQ                        1 = IRQ ENABLE
                        ;BIT 7-IRQ  LEVEL IRQ                  1 = IRQ ENABLE
PE56ENABLE   EQU $01
NE57ENABLE   EQU $02
PE60ENABLE   EQU $04
PWMENABLE    EQU $08
NE64ENABLE   EQU $10
NE66ENABLE   EQU $20
PIBIRQENABLE EQU $40

UIFR     EQU   $DF48   UART INTERRUPT FLAG REGISTER
                        ;BIT 0-UART0 RECEIVE    1 = INTERRUPT PENDING
                        ;BIT 1-UART0 TRANSMIT   1 = INTERRUPT PENDING
                        ;BIT 2-UART1 RECEIVE    1 = INTERRUPT PENDING
                        ;BIT 3-UART1 TRANSMIT   1 = INTERRUPT PENDING
                        ;BIT 4-UART2 RECEIVE    1 = INTERRUPT PENDING
                        ;BIT 5-UART2 TRANSMIT   1 = INTERRUPT PENDING
                        ;BIT 6-UART3 RECEIVE    1 = INTERRUPT PENDING
                        ;BIT 7-UART3 TRANSMIT   1 = INTERRUPT PENDING
UART0R   EQU $01
UART0T   EQU $02
UART1R   EQU $04
UART1T   EQU $08
UART2R   EQU $10
UART2T   EQU $20
UART3R   EQU $40
UART3T   EQU $80

UIER     EQU   $DF49   UART INTERRUPT ENABLE REGISTER
                        ;BIT 0-UART0 RECEIVE    1 = ENABLE IRQ
                        ;BIT 1-UART0 TRANSMIT   1 = ENABLE IRQ
                        ;BIT 2-UART1 RECEIVE    1 = ENABLE IRQ
                        ;BIT 3-UART1 TRANSMIT   1 = ENABLE IRQ
                        ;BIT 4-UART2 RECEIVE    1 = ENABLE IRQ
                        ;BIT 5-UART2 TRANSMIT   1 = ENABLE IRQ
                        ;BIT 6-UART3 RECEIVE    1 = ENABLE IRQ
                        ;BIT 7-UART3 TRANSMIT   1 = ENABLE IRQ


RVD4A    EQU   $DF4A   RESERVED I/O $DF4A-$DF4F

T0LL     EQU   $DF50   TIMER 0 LATCH LOW
T0LH     EQU   $DF51   TIMER 0 LATCH HIGH
T1LL     EQU   $DF52   TIMER 1 LATCH LOW
T1LH     EQU   $DF53   TIMER 1 LATCH HIGH
T2LL     EQU   $DF54   TIMER 2 LATCH LOW
T2LH     EQU   $DF55   TIMER 2 LATCH HIGH
T3LL     EQU   $DF56   TIMER 3 LATCH LOW
T3LH     EQU   $DF57   TIMER 3 LATCH HIGH
T4LL     EQU   $DF58   TIMER 4 LATCH LOW
T4LH     EQU   $DF59   TIMER 4 LATCH HIGH
T5LL     EQU   $DF5A   TIMER 5 LATCH LOW
T5LH     EQU   $DF5B   TIMER 5 LATCH HIGH
T6LL     EQU   $DF5C   TIMER 6 LATCH LOW
T6LH     EQU   $DF5D   TIMER 6 LATCH HIGH
T7LL     EQU   $DF5E   TIMER 7 LATCH LOW
T7LH     EQU   $DF5F   TIMER 7 LATCH HIGH

T0CL     EQU   $DF60   TIMER 0 COUNTER LOW
T0CH     EQU   $DF61   TIMER 0 COUNTER HIGH
T1CL     EQU   $DF62   TIMER 1 COUNTER LOW
T1CH     EQU   $DF63   TIMER 1 COUNTER HIGH
T2CL     EQU   $DF64   TIMER 2 COUNTER LOW
T2CH     EQU   $DF65   TIMER 2 COUNTER HIGH
T3CL     EQU   $DF66   TIMER 3 COUNTER LOW
T3CH     EQU   $DF67   TIMER 3 COUNTER HIGH
T4CL     EQU   $DF68   TIMER 4 COUNTER LOW
T4CH     EQU   $DF69   TIMER 4 COUNTER HIGH
T5CL     EQU   $DF6A   TIMER 5 COUNTER LOW
T5CH     EQU   $DF6B   TIMER 5 COUNTER HIGH
T6CL     EQU   $DF6C   TIMER 6 COUNTER LOW
T6CH     EQU   $DF6D   TIMER 6 COUNTER HIGH
T7CL     EQU   $DF6E   TIMER 7 COUNTER LOW
T7CH     EQU   $DF6F   TIMER 7 COUNTER HIGH

ACSR0    EQU   $DF70   ASYNCH. CONTROL/STATUS REGISTER 0
                        ;BIT 0-XMIT PORT ENABLE
                        ;BIT 1-XMIT IRQ SOURCE
                        ;BIT 2-7/8 BIT DATA
                        ;BIT 3-PARITY ENABLE
                        ;BIT 4-ODD/EVEN PARITY
                        ;BIT 5-RECV ENABLE
                        ;BIT 6-SOFTWARE SEMIPHORE
                        ;BIT 7-RECV ERROR FLG
SON      EQU $01
DISCH    EQU $02

ARTD0    EQU   $DF71   ASYNCH. RECVR/TRANSMTR DATA REGISTER 0
ACSR1    EQU   $DF72   ASYNCH. CONTROL/STATUS REGISTER 1
ARTD1    EQU   $DF73   ASYNCH. RECVR/TRANSMTR DATA REGISTER 1
ACSR2    EQU   $DF74   ASYNCH. CONTROL/STATUS REGISTER 2
ARTD2    EQU   $DF75   ASYNCH. RECVR/TRANSMTR DATA REGISTER 2
ACSR3    EQU   $DF76   ASYNCH. CONTROL/STATUS REGISTER 3
ARTD3    EQU   $DF77   ASYNCH. RECVR/TRANSMTR DATA REGISTER 3



                        ;UART IO LINES
DTR0     EQU $01
DTR1     EQU $04
DTR2     EQU $10
DTR3     EQU $40

DSR0     EQU $02
DSR1     EQU $08
DSR2     EQU $20
DSR3     EQU $80



VIA2_PDA        EQU $DFE1       ;POWER CONTROL 
VIA2_PDDA       EQU $DFE3

	  ENDS

	  APPEND R_EQU.H
