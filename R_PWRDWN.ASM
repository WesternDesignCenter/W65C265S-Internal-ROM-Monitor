; FILE: R_PWRDWN.ASM     power down routine
; DATE: 12-02-94

	 STTL 'POWERDOWN CONTROL'
	 PAGE

	 CODE

ENTER_LOW_POWER_MODE:

        JMP (LO_PWR_JMP)

;*******************************************


DO_LOW_PWR_PGM:

	LDX #$01FF	;RESET STACK POINTER
        TXS

        CLI     ;LET THE CLOCK RUN

        LDA #A_MENSCH
	BIT <DISPTYP
        BEQ ?1         ;NOT A MENSCH PLATFORM
        LDA #Bit3      ;TURN OFF HOST PORT PWR
        TSB PWR_XTRL_REG

?1      LDA #$FF       ;set all busses low 
        STA PDD0
        STA PDD1
        STA PDD2
        STA PDD3
        STZ PD0
        STZ PD1
        STZ PD2
        STZ PD3

       IFZ IROM

        LDA #$FF        ;SET ALL EXTERNAL SELECTS HI
        STA PD7
        LDA #Bit4       ;LEAVE EPROM SELECT ONLY
        STA PCS7
        LDA #Bit7+Bit3+Bit0 ;FOR TEST ONLY
        STA BCR

       ELSE

        LDA #$FF        ;SET ALL EXTERNAL SELECTS HI
        STA PD7
	STZ PCS7
        LDA #Bit3+Bit0
	STA BCR

       ENDIF

        LDA #Bit1+Bit2+Bit3  ;goto slow clock & Internal RAM
        TRB SSCR           
        LDA #Bit0       ;TURN OFF  FAST CLOCK
        TRB SSCR

        LDX #0          ;WAIT FOR THINGS TO SETTLE
?DLY    INX             ;BEFORE TESTING POWER UP.
        BNE ?DLY



TRY_RESTART:

?3      LDA >FLAGS       ;LOOK FOR REASON TO RESTART
        BIT #ALRMENAB
        BEQ ?4
        BIT #ALRMIRQ
        BEQ ?4
        JMP URESTART



?4      LDA #A_MENSCH
	BIT <DISPTYP
        BEQ ?6          ;NOT A MENSCH PLATFORM
        LDA PD6
        BIT #Bit0       ;CK KEYBOARD DATA IN
        BNE ?6            ;MARKING
?5      JMP URESTART

?6     	LDX PWD_CELLS   ;USER SENTINAL
	CPX #$AA55
        BNE TRY_RESTART	;NO PAGE 1 PGM
	JSR $00:01C0
	BVS TRY_RESTART	;KEEP CHECKING
        BRA ?5		;RESTART

	ENDS

	APPEND R_SBREAK.ASM
