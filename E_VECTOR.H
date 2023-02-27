	   .STTL 'E VECTORS'
;FILE:E_VECTOR

;DATE:01-05-95

	  CODE

	  LONGA OFF
	  LONGI ON

	  IFZ IROM
	  ORG $00:8000
	  BYTE 'WDC',0
	  LDA #$89     ;ENABLE EXT ROM, ICE & EXT BUS
	  STA BCR
	  LDA #$13     ;ENABLE CS4, CS1 & CS0
	  STA PCS7

	  JMP RESET

	  ENDIF

	  ORG $00:E000

	  JMP        Alter_Memory

	  JMP        BACKSPACE

HERE      JMP        HERE

	  JMP        CONTROL_TONES

	  JMP        DO_LOW_PWR_PGM

	  JMP        DUMPREGS

	  JMP        DumpS28

	  JMP        Dump_1_line_to_Output

	  JMP        Dump_1_line_to_Screen

	  JMP        Dump_to_Output

	  JMP        Dump_to_Printer

	  JMP        Dump_to_Screen

	  JMP        Dump_to_Screen_ASCII

	  JMP        Dump_It

	  JMP        FILL_Memory

	  JMP        GET_3BYTE_ADDR

	  JMP        GET_ALARM_STATUS

	  JMP        GET_BYTE_FROM_PC

	  JMP        GET_CHR

	  JMP        GET_HEX

	  JMP        GET_PUT_CHR

	  JMP        GET_STR

	  JMP        Get_Address

	  JMP        Get_E_Address

	  JMP        Get_S_Address

	  JMP        PUT_CHR

	  JMP        PUT_STR

	  JMP        READ_ALARM

	  JMP        READ_DATE

	  JMP        READ_TIME

	  JMP        RESET_ALARM

	  JMP        SBREAK

	  JMP        SELECT_COMMON_BAUD_RATE

	  JMP        SEND_BYTE_TO_PC

	  JMP        SEND_CR

	  JMP        SEND_SPACE

	  JMP        SEND_HEX_OUT

	  JMP        SET_ALARM

	  JMP        SET_Breakpoint

	  JMP        SET_DATE

	  JMP        SET_TIME

	  JMP        VERSION

	  JMP        WR_3_ADDRESS

	  JMP        XS28IN

	  JMP        RESET

	  JSR        ASCBIN
	  RTL

	  JSR        BIN2DEC
	  RTL

	  JSR        BINASC
	  RTL

	  JSR        HEXIN
	  RTL

	  JSR        IFASC
	  RTL

	  JSR        ISDECIMAL
	  RTL

	  JSR        ISHEX
	  RTL

	  JSR        UPPER_CASE
	  RTL



	  DS 8         ;RESERVED FOR EXPANSION

	  ENDS

	  APPEND ROM_INIT.ASM
