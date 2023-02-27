         .STTL 'R_EQU.H - MENSCH EQUATES FOR ROM MONITOR
         .PAGE
         ;11-10-1994

	 DATA



********************************************
*                                          *
*     THIS IS THE PORT MAP FOR THE         *
*       MENSCH COMPUTER FIRMWARE           *
*                                          *
********************************************


         ;PD0  ADDRESS REGISTER A0-A7
         ;PD1  ADDRESS REGISTER A8-A15
         ;PD2  DATA REGISTER D0-D7
         ;PD3  ADDRESS REGISTER A16-A23
         ;PD4  PORT 4 
                        ;BIT 0-NMI
                        ;BIT 1-IRQ
                        ;BIT 2-PCMCIA Card Sense
                        ;BIT 3-PCMCIA Card Sense
                        ;BIT 4-PCMCIA Card Sense
                        ;BIT 5-PCMCIA Card Sense
                        ;BIT 6-RES* for VIA's
                        ;BIT 7-RES for PCMCIA slots
         ;PD6  PORT 5
                        ;BIT 0-DTR0 SERIAL UART
                        ;BIT 1-DSR0 SERIAL UART
                        ;BIT 2-DTR1 SERIAL UART
                        ;BIT 3-DSR1 SERIAL UART
                        ;BIT 4-DTR2 SERIAL UART
                        ;BIT 5-DSR2 SERIAL UART
                        ;BIT 6-DTR3 SERIAL UART
                        ;BIT 7-DSR3 SERIAL UART
         ;PD6  PORT 6
                        ;BIT 0-RXD0 SERIAL UART
                        ;BIT 1-TXD0 SERIAL UART
                        ;BIT 2-RXD1 SERIAL UART
                        ;BIT 3-TXD1 SERIAL UART
                        ;BIT 4-RXD2 SERIAL UART
                        ;BIT 5-TXD2 SERIAL UART
                        ;BIT 6-RXD3 SERIAL UART
                        ;BIT 7-TXD3 SERIAL UART
         ;PD7  PORT 7
                        ;BIT 0-CS0 VIA for LCD
                        ;BIT 1-CS1 VIA for Pwr Xtrl & Game Port
                        ;BIT 2-CS2 Expansion Header J6
                        ;BIT 3-CS3 RAM   $0200 - $7FFF
                        ;BIT 4-CS4 EPROM $8000 - $FFFF
                        ;BIT 5-CS5 Low IC Card
                        ;BIT 6-CS6 Hi IC Card
                        ;BIT 7-CS7 Expansion Header J6



         ;Port Replacement & Expansion


DISP_DATA_DREG EQU $DF10  ;VIA B PORT
                        ;BIT 0-DISPLAY D0           (INPUT/OUTPUT)
                        ;BIT 1-DISPLAY D1           (INPUT/OUTPUT)
                        ;BIT 2-DISPLAY D2           (INPUT/OUTPUT)
                        ;BIT 3-DISPLAY D3           (INPUT/OUTPUT)
                        ;BIT 4-DISPLAY D4           (INPUT/OUTPUT)
                        ;BIT 5-DISPLAY D5           (INPUT/OUTPUT)
                        ;BIT 6-DISPLAY D6           (INPUT/OUTPUT)
                        ;BIT 7-DISPLAY D7           (INPUT/OUTPUT)
DISP_DATA_DIR  EQU $DF12  ;DATA DIRECTION REG

DISP_CNTL_REG EQU $DF11  ;CONTROL REG TO DISPLAY VIA B PORT
                        ;BIT 0-DISPLAY ENABLE       (OUTPUT)
                        ;BIT 1-DISPLAY REG SELECT   (OUTPUT)
                        ;BIT 2-DISPLAY READ/WRITE*  (OUTPUT)
                        ;BIT 3-Bat Voltage Detector (INPUT)
                        ;BIT 4-Not used             (INPUT)
                        ;BIT 5-Not used             (INPUT)
                        ;BIT 6-DISPLAY Select       (OUTPUT)
                        ;BIT 7-Display Reset        (OUTPUT)
DISP_CNTL_DIR EQU  $DF13  ;DATA DIRECTION REG



         ;VIA USED FOR SEGA GAME PORT & POWER XTROL

SEGA_DATA_REG  EQU $DFE0  ;SEGA GAME PORT   all inputs
                        ;BIT 0-PIN 1
                        ;BIT 1-PIN 2
                        ;BIT 2-PIN 3
                        ;BIT 3-PIN 4
                        ;BIT 4-PIN 6
                        ;BIT 5-PIN 7
                        ;BIT 6-PIN 9
                        ;BIT Sega PWR Control*
                        ;    Low = Pwr on
SEGA_DATA_DIR  EQU $DFE2  ;DATA DIRECTION REG



PWR_XTRL_REG   EQU $DFE1  ;VIA A PORT
                        ;BIT 0-Display power*
                        ;BIT 1-Printer Port PWR*
                        ;BIT 2-Host Port PWR*
                        ;BIT 3-MODEM Port PWR
                        ;BIT 4-Spkr AMP PWR on & Expansion PIN 52
                        ;BIT 5-Expansion PIN 54
                        ;BIT 6-Expansion PIN 56
                        ;BIT 7-Expansion PIN 58
PWR_XTRL_DIR   EQU $DFE3  ;DATA DIRECTION REG



********************************************
*                                          *
*     THIS IS THE TIMMER MAP FOR THE       *
*         MENSCH COMPUTER PROGRAMS         *
*                                          *
********************************************

         ;T0  TIMER #0 IS NOT USED
         ;T1  TIMER #1 IS FOR TIME OF DAY CLOCK TIMING
         ;T2  TIMER #2 IS FOR GENERAL 10 MSEC TIMING
         ;T3  TIMER #3 IS FOR UART BAUD RATE TIMING
         ;T4  TIMER #4 IS FOR UART BAUD RATE TIMING
         ;T5  TIMER #5 IS FOR TONE GENERATOR TIMING
         ;T6  TIMER #6 IS FOR TONE GENERATOR TIMING
         ;T7  TIMER #7 IS FOR PULSE WIDTH MEASUREMENT TIMING

	 ENDS

	  APPEND R_RAM.ASM
