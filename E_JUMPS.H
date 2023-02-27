;FILE E_JUMPS.H
;DATE 07-17-95

     .DATA
	  .ORG $00E000


Alter_Memory				 JMP 0

BACKSPACE					 JMP 0

RESERVED        			 JMP 0

CONTROL_TONES				 JMP 0

DO_LOW_PWR_PGM				 JMP 0

DUMPREGS						 JMP 0

DumpS28						 JMP 0

Dump_1_line_to_Output	 JMP 0

Dump_1_line_to_Screen	 JMP 0

Dump_to_Output				 JMP 0

Dump_to_Printer			 JMP 0

Dump_to_Screen				 JMP 0

Dump_to_Screen_ASCII		 JMP 0

RESERVED_2               JMP 0

FILL_Memory					 JMP 0

GET_3BYTE_ADDR				 JMP 0

GET_ALARM_STATUS			 JMP 0

GET_BYTE_FROM_PC			 JMP 0

_GET_CHR						 JMP 0

GET_HEX						 JMP 0

_GET_PUT_CHR		  		 JMP 0

GET_STR						 JMP 0

Get_Address					 JMP 0

Get_E_Address				 JMP 0

Get_S_Address				 JMP 0

_PUT_CHR						 JMP 0

PUT_STR						 JMP 0

READ_ALARM					 JMP 0

READ_DATE					 JMP 0

READ_TIME					 JMP 0

RESET_ALARM					 JMP 0

SBREAK						 JMP 0

SELECT_COMMON_BAUD_RATE	 JMP 0

SEND_BYTE_TO_PC			 JMP 0

_SEND_CR						 JMP 0

_SEND_SPACE					 JMP 0

SEND_HEX_OUT				 JMP 0

SET_ALARM					 JMP 0

SET_Breakpoint				 JMP 0

SET_DATE						 JMP 0

SET_TIME						 JMP 0

VERSION  					 JMP 0

WR_3_ADDRESS				 JMP 0

XS28IN						 JMP 0

R_RESET                  JMP 0

;*********

ASCBIN						 JMP 0
                         .ds 1
BIN2DEC						 JMP 0
                         .ds 1
BINASC						 JMP 0
                         .ds 1
HEXIN							 JMP 0
                         .ds 1
IFASC							 JMP 0
                         .ds 1
ISDECIMAL					 JMP 0
                         .ds 1
ISHEX   						 JMP 0
                         .ds 1
UPPER_CASE					 JMP 0
                         .ds 1


				.END
