; FILE;  TABLES.ASM--TIMER CONSTANTS
; DATE:  11-22-1994

	 STTL 'TABLES AND CONSTANTS'

	 ORG $00:FEA0

T2_1MSEC_TBL EQU *
	 WORD 1843200/16000    ;1.8432 MHZ
	 WORD 2457600/16000    ;2.4576 MHZ
	 WORD 3686400/16000    ;3.6864 MHZ
	 WORD 4915200/16000    ;4.9152 MHZ
	 WORD 6144000/16000    ;6.1440 MHZ


BAUDOFFSET EQU *
	 BYTE 00       ;1.8432 MHZ
	 BYTE 26       ;2.4576 MHZ
	 BYTE 52       ;3.6864 MHZ
	 BYTE 78       ;4.9125 MHZ
	 BYTE 104      ;6.1440 MHZ




ACIBAUD  EQU *
                        ;1.8432MHZ  
	 WORD $0416    ;  110 BAUD
	 WORD $02FF    ;  150 BAUD
	 WORD $017F    ;  300 BAUD
	 WORD $00BF    ;  600 BAUD
	 WORD $005F    ; 1200 BAUD
	 WORD $003F    ; 1800 BAUD
	 WORD $002F    ; 2400 BAUD
	 WORD $0017    ; 4800 BAUD
	 WORD $000B    ; 9600 BAUD
	 WORD $0008    ;14400 BAUD
	 WORD $0005    ;19200 BAUD
	 WORD $0002    ;38400 BAUD
	 WORD $0001    ;57600 BAUD

                        ;2.4576MHZ  
	 WORD $0573    ;  110 BAUD
	 WORD $03FF    ;  150 BAUD
	 WORD $01FF    ;  300 BAUD
	 WORD $00FF    ;  600 BAUD
	 WORD $007F    ; 1200 BAUD
	 WORD $0054    ; 1800 BAUD
	 WORD $003F    ; 2400 BAUD
	 WORD $001F    ; 4800 BAUD
	 WORD $000F    ; 9600 BAUD
	 WORD $000B    ;14400 BAUD
	 WORD $0007    ;19200 BAUD
	 WORD $0003    ;38400 BAUD
	 WORD $0002    ;57600 BAUD BAD WONT WORK AT 2.4576MHZ

                        ;3.6864MHZ  
	 WORD $082E    ;  110 BAUD
	 WORD $05FF    ;  150 BAUD
	 WORD $02FF    ;  300 BAUD
	 WORD $017F    ;  600 BAUD
	 WORD $00BF    ; 1200 BAUD
	 WORD $007F    ; 1800 BAUD
	 WORD $005F    ; 2400 BAUD
	 WORD $002F    ; 4800 BAUD
	 WORD $0017    ; 9600 BAUD
	 WORD $0011    ;14400 BAUD
	 WORD $000B    ;19200 BAUD
	 WORD $0005    ;38400 BAUD
	 WORD $0003    ;57600 BAUD

                        ;4.9152MHZ  
	 WORD $0AE8    ;  110 BAUD
	 WORD $07FF    ;  150 BAUD
	 WORD $03FF    ;  300 BAUD
	 WORD $01FF    ;  600 BAUD
	 WORD $00FF    ; 1200 BAUD
	 WORD $00AA    ; 1800 BAUD
	 WORD $007F    ; 2400 BAUD
	 WORD $003F    ; 4800 BAUD
	 WORD $001F    ; 9600 BAUD
	 WORD $0017    ;14400 BAUD  ; 14,629 ACTUAL
	 WORD $000F    ;19200 BAUD
	 WORD $0007    ;38400 BAUD
	 WORD $0004    ;57600 BAUD

                        ;6.1440 MHZ  
	 WORD $0DA2    ;  110 BAUD
	 WORD $09FF    ;  150 BAUD
	 WORD $04FF    ;  300 BAUD
	 WORD $027F    ;  600 BAUD
	 WORD $013F    ; 1200 BAUD
	 WORD $00DF    ; 1800 BAUD
	 WORD $009F    ; 2400 BAUD
	 WORD $004F    ; 4800 BAUD
	 WORD $0027    ; 9600 BAUD
	 WORD $001D    ;14400 BAUD  ; 14,222 ACTUAL
	 WORD $0013    ;19200 BAUD
	 WORD $0009    ;38400 BAUD
	 WORD $0006    ;57600 BAUD


;
;
;TIME OF DAY MAX MIN TABLES
;
;
MAXTTBL  EQU *
	 BYTE 8        ;DAY OF WEEK
	 BYTE 13       ;MONTH
	 BYTE 32       ;DAY
	 BYTE 100      ;YR
	 BYTE 24       ;HR
	 BYTE 60       ;MIN
	 BYTE 60       ;SEC

MINTTBL  EQU *
	 BYTE 1        ;DAY OF WEEK
	 BYTE 1        ;MONTH
	 BYTE 1        ;DAY
	 BYTE 0        ;YR
	 BYTE 0        ;HR
	 BYTE 0        ;MIN
	 BYTE 0        ;SEC


LASTDY   BYTE 31       ;JANUARY
	 BYTE 28       ;FEBRUARY-EXCEPT LEAP YR
	 BYTE 31       ;MARCH
	 BYTE 30       ;APRIL
	 BYTE 31       ;MAY
	 BYTE 30       ;JUNE
	 BYTE 31       ;JULY
	 BYTE 31       ;AUGUST
	 BYTE 30       ;SEPTEMBER
	 BYTE 31       ;OCTOBER
	 BYTE 30       ;NOVEMBER
	 BYTE 31       ;DECEMBER

DFLTS    EQU *
	 BYTE 5        ;DAY OF WEEK

	 BYTE 07       ;MONTH
	 BYTE 01       ;DAY
	 BYTE 93       ;YEAR

	 BYTE 12       ;HOUR
	 BYTE 00       ;MINUTES
	 BYTE 0        ;SEC
	 BYTE 0        ;DAYLIGHT SAVING OFF
DFLTSEND EQU *

;
;  STTL 'CONVERSION TABLES
;
HEXTOPOS EQU *
	 BYTE $01,$02,$04,$08
	 BYTE $10,$20,$40,$80


BINDECL  EQU *
	 BYTE $00,$01,$02,$03,$04,$05,$06,$07,$08,$09
	 BYTE $10,$11,$12,$13,$14,$15

BINDECH  BYTE $00,$16,$32,$48,$64,$80,$96

DECBIN   BYTE 00,10,20,30,40,50,60,70,80,90



ROMSPACE EQU $00:FF80-*  ;gives space left in the ROM BEFORE TABLES


	 APPEND IRQVTRS.ASM
