; FILE: M_PWRDWN.ASM     power down routine
; DATE: 11-14-94



ENTER_LOW_POWER_MODE_ROM:


        CLI     ;LET THE CLOCK RUN

        LDA #Bit6+Bit2+Bit1
        JSL CONTROL_KEYBOARD_PORT
        LDA #Bit6+Bit4+Bit3+Bit2+Bit1   ;Turn off printer port
        JSL CONTROL_PRINTER_PORT
        LDA #Bit6+Bit4+Bit3+Bit2+Bit1
        JSL CONTROL_MODEM_PORT
        LDA #Bit6+Bit4+Bit3+Bit2+Bit1
        JSL CONTROL_PC_PORT
        LDA #0
        JSL CONTROL_CONTROLLER_PORT
        LDA #0
        JSL CONTROL_DISPLAY
        LDA #0          ;TURN OFF SPEAKER AMP
        JSL CONTROL_SPEAKER_AMP

        LDA #$FF
        STA PDD0
        STA PDD1
        STA PDD2
        STA PDD3
        STZ PD0
        STZ PD1
        STZ PD2
        STZ PD3

      .IFZ IROM

        LDA #Bit4       ;EPROM ONLY
        STA PCS7
        LDA #Bit7+Bit3+Bit0 ;FOR TEST ONLY
        STA BCR

      .ELSE

	STZ PCS7
        LDA #Bit3+Bit1
	STA BCR

      .ENDIF

        LDA #Bit1+Bit2+Bit3  ;goto slow clock & Internal RAM
        TRB SSCR           
        LDA #Bit0       ;TURN OFF FCLOCK
        TRB SSCR

?3      LDA FLAGS
        BIT #ALRMENAB
        BEQ ?4
        BIT #ALRMIRQ
        BEQ ?4
        JMP RESET

?4      LDA PD6
        BIT #Bit0       ;CK KEYBOARD DATA IN
        BNE ?3            ;MARKING
        JMP RESET


ENTER_LOW_POWER_MODE:

        JMP (LO_PWR_JMP)



        END
