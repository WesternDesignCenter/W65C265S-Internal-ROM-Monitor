;------------------------------------------------------------------------------
;*
;* VECTCODE code for the 65816 remote debugger
;*  Copyright 1991, Red Mountain Software
;*                  1504 N. Sinova
;*                  Mesa, AZ  85205
;*                  (602) 981-8550 voice
;*                  (602) 461-9039 BBS/FAX
;*
;*
;------------------------------------------------------------------------------

        TITLE   VECTCODE.ASM - 65816 STARTUP/EXCEPTION VECTORS

                INCLUDE         MACROS.ASM

;*******Only GLOBAL symbols are included in the symbol table that the
;*******debugger reads, so we are going to make all of the symobls defined
;*******in this module GLOBAL.
                GLOBALS         ON

;------------------------------------------------------------------------------
; This section should be located to the 4 byte area where your AI interface
; will be. (00:FFF0) in this example.
;
AI_LOCATION     SECTION
AI_ZERO         DB      0
AI_ONE          DB      1
AI_DATA         DB      $AA
AI_STATUS       DB      $CC
                ENDS


;--------------Work Ram for MONITOR--------------------------------------------
MRAMBASE:        SECTION
                DS      16
                ENDS



;------------Code--------------------------------------------------------------
                CODE
RESET:
                SEI
                CLD

                CLC             ;Go into NATIVE '816 mode.
                XCE             ;Set the mode to native

                ON16            ;Set our desired register length

                LDX     #$1FF  ;Set our 16-bit stack pointer
                TXS
;
;----This delay loop was necessary for the HARDWARE to stabilize on the target
;----that the debugger was developed and tested on.
;
                LDY     #8
RESDED:
                LDX     #$FFFF
RESLOP:
                DEX
                BNE     RESLOP
                DEY
                BNE     RESDED
;---------------------End of hardware stabilization delay----------------------


; Setup the bank addresses
                JML     BNKJMP          ;set program bank register correctly
BNKJMP:
                OFF16
                LDA     #0              ;set data bank register to 0
                PHA
                PLB

;CSHPIA          EQU     0:8C00H         ;1/2 PIA
;P1DATA          EQU     CSHPIA+0         DATA
;P1DDR           EQU     CSHPIA+1         DIRECTION REGISTER
;
;
;                LDA     #$1F
;                STA     !P1DATA
;
;                LDA     #10111111B   6 EEP DATA INPUT   5 EEP DATA OUTPUT
;                STA     !P1DDR
;
;                LDA     #$1F            ;nmi off
;                STA     !P1DATA
;



;******************************************************************************
;  This is our call that allows the MONITOR to initialize it's RAM
;******************************************************************************
                ON16
                LDA     #MRAMBASE
                PHA
                OFF16
                LDA     #^AI_LOCATION           ;Push our AI bank
                PHA
                ON16
                LDA     #AI_LOCATION            ;Push our AI base
                PHA

                JSL     >MONITOR_INIT_RAM       ;Inintialize the MONITOR'S RAM

                ON16
                TSC                             ;Clear the stack
                CLC
                ADC     #5
                TCS
;******************************************************************************


                CLI                             ;ENABLE IRQ'S

                OFF16
                LDA     #$11
                LDX     #$22
                LDY     #$33

NO_DATA:
                LDY     #$FF
L_RESDED:
                LDX     #$FF
L_RESLOP:
                LDA     #$AA
                NOP
                JMP     !NEXT
                NOP
NEXT:           JMP     !NEXT_2
                CMP     #$FF
NEXT_2:
                SEC
                NOP
                NOP
                CLC

                JSR     TEST_JSR

                JSR     TEST_16_BITS

                JSR     TEST_EMULATION

                JSR     TEST_SEI

                BSR     TEST_JSR

                DEX
                BNE     L_RESLOP
                DEY
                BNE     L_RESDED

                JMP     !NO_DATA

TEST_JSR:
                LDA     #$CD
                CLC
                ADC     #1
                SEC
                SBC     #10
                CLC
                ADC     #9
                RTS
TEST_16_BITS:
                PHP
                ON16
                LDA     #$1234
                SEC
                SBC     #$1111
                PLP
                RTS


;-----------------------------------------------------------------------------
TEST_SEI:
                PHP
                ON16

                LDA     #$DEAD
                CLC
                ADC     #$DEAD

                LDY     #20
aRESDED:
                LDX     #$FFFF
aRESLOP:
                DEX
                BNE     aRESLOP
                DEY
                BNE     aRESDED


                NOP
                NOP
                NOP

                SEI
                SEC
                SBC     #$DEAD
                ASL     A
                LSR     A
                CLC
                ADC     #$DAD
                SEC
                SBC     #$DAD
                CLI

                LDA     #$FEED
                CLC
                ADC     #$DEAD
                SEC
                SBC     #$DEAD


                PLP
                RTS

;------Go into emulation mode---------------(for testing only)-----------------
TEST_EMULATION:
                PHP
                OFF16

                SEC             ;Go into emulation mode
                XCE

;                CHIP    6502

                lda     #$22    ;Emulation mode coded in lowercase for clarity
                clc

                adc     #$22
                lsr     a
                lsr     a
                lsr     a
                lsr     a

                eor     #$ff

                chip    65816

                brl     skipit

                nop
                nop
                lda     #$12

skipit:
                clc             ;Go back into NATIVE mode
                xce

                PLP
                RTS


;------------------------------------------------------------------------------
;*
;*
;* Note: For register operations, stack depth is critical!
;*       when implementing this monitor, you must make sure that these
;*       stack depth tables will accurately reflect the stack depth that will
;*       be active at the time of the MONITOR_IRQ_ENTRY or MONITOR_BREAKPOINT_
;*       ENTRY call!
;*
;*       If this is not set correctly, then all register operations on the
;*       PC side will not work correctly.
;*
;*       The registers can be pushed onto the stack in any order as long as
;*       the stack descriptor accuratley reflects the location and size of
;*       each register. At first it would be best if you just used the order
;*       in the example IRQ, along with the following stack descriptors.
;*
;*       In order for the program counter to be accurate, the debugger must
;*       be called from an interrupt handler.
;*
;*
;*
;
NATIVE_DEPTH    EQU     1*3+5 ;# OF JSL's * bytes per JSL =TOTAL STACK DEPTH
EMULATION_DEPTH EQU     1*2+5 ;# OF JSR's * bytes per JSR =TOTAL STACK DEPTH

;-----stack frame descriptor for NATIVE MODE-----------------------------------

                DATA
NATIVE_STACK:
                db      NATIVE_DEPTH+13,0  ;Total stack bytes used
                db      NATIVE_DEPTH+07,2  ;A  depth,length (IN BYTES)
                db      NATIVE_DEPTH+05,2  ;X
                db      NATIVE_DEPTH+03,2  ;Y
                db      NATIVE_DEPTH+10,1  ;Processor status word
                db      NATIVE_DEPTH+11,2  ;Program counter
                db      1,2                ;Stack depth(ALWAYS 1 FOR STACK), length
                db      NATIVE_DEPTH+13,1  ;Program bank register
                db      NATIVE_DEPTH+09,1  ;Data bank register
                db      NATIVE_DEPTH+01,2  ;Direct register

;-----stack frame descriptor for EMULATION mode--------------------------------

EMULATION_STACK:
                db      EMULATION_DEPTH+6,0     ;Total stack bytes used

                db      EMULATION_DEPTH+3,1     ;A depth,length
                db      EMULATION_DEPTH+2,1     ;X
                db      EMULATION_DEPTH+1,1     ;Y
                db      EMULATION_DEPTH+4,1     ;Processor status word
                db      EMULATION_DEPTH+5,2     ;Program counter
                db      1,2                     ;Stack depth(ALWAYS 1 FOR STACK), length
                db      0,1                     ;Zero indicates no register
                db      0,1
                db      0,2

                CODE


;------------------------------------------------------------------------------
;------An EXAMPLE of an EMULATION MODE IRQ handler calling the MONITOR---------
;------------------------------------------------------------------------------

;                CHIP    6502

                CHIP    65816
                LONGA   OFF
                LONGI   OFF

EMULATION_SIRQ:
                PHA
                PHX
                PHY

                TSX                     ;Get the P register on the stack
                INX
                INX                     ;We must allow for roll-over, so we
                INX                     ;go the long way instead of $104,x
                INX

                LDA     $100,X          ;Get the old status register

                AND     #$10            ;Break instuction?
                BEQ     EMM_NO_BREAK    ;No, not BRK, it is IRQ.
;
;-----ACTUAL setup and call to the monitor code------EMULATION MODE------------
                lda     #>MRAMBASE       ;Get the high byte
                pha
                lda     #<MRAMBASE       ;Get the low byte
                pha

                LDX     #<EMULATION_STACK ;Get the low byte
                LDY     #>EMULATION_STACK ;Get high byte of stack frame
                JSR     MONITOR_BREAKPOINT_ENTRY
                pla                     ;clear the stack ala 'C'
                pla
                JMP     EMM_AI_DONE
;------------------------------------------------------------------------------

EMM_NO_BREAK:
;-----ACTUAL setup and call to the monitor code------EMULATION MODE------------
                lda     #>MRAMBASE
                pha
                lda     #<MRAMBASE
                pha

                LDX     #<EMULATION_STACK ;Get the low byte
                LDY     #>EMULATION_STACK ;Get high byte of stack frame
                JSR     MONITOR_IRQ_ENTRY
                pla                     ;clear the stack ala 'C'
                pla
                JMP     EMM_AI_DONE
;------------------------------------------------------------------------------
EMM_AI_DONE:
************The rest of your IRQ code would go here************


EMM_IRQRET:
                PLY
                PLX
                PLA
                RTI



;------------------------------------------------------------------------------
;------An EXAMPLE of a NATIVE MODE IRQ handler calling the MONITOR-------------
;------------------------------------------------------------------------------

                CHIP    65816
NATIVE_SIRQ:
                ON16
                PHB
                PHA
                PHX
                PHY
                PHD

                OFF16
                LDA     #0
                PHA
                PLB

;------Actual setup and call to the monitor code------NATIVE MODE--------------
                ON16
                lda     #MRAMBASE
                PHA
                LDX     #NATIVE_STACK   ;Native stack frame pointer
                LDY     #0              ;Native stack frame bank
                JSL     >MONITOR_IRQ_ENTRY
                PLA
                OFF16
;------------------------------------------------------------------------------

;  ****The rest of the IRQ routines go here****

                ON16
                PLD
                PLY
                PLX
                PLA
                PLB
                RTI
;
;
;---------BRK instruction handler for NATIVE MODE------------------------------
;-------------Your BRK vector should point here--------------------------------
;
;
NATIVE_BREAK:
                ON16           ;16 BITS ON

                PHB
                PHA
                PHX
                PHY
                PHD            ;PUSH DIRECT REGISTER

                OFF16
                LDA     #0     ;Setup the DBR to be bank 0
                PHA
                PLB

                LDA     >AI_STATUS       ;GET THE AI STATUS
                CMP     #$CC            ;IS THE AI THERE?
                BEQ     BRK_NO_AI

                ON16
                LDA     #MRAMBASE
                PHA
                LDX     #NATIVE_STACK   ;Native stack frame pointer
                LDY     #0              ;Native stack frame bank
                JSL     >MONITOR_BREAKPOINT_ENTRY
                PLA
BRK_NO_AI:
                ON16
                PLD
                PLY
                PLX
                PLA
                PLB
                RTI
;
;
; The following is a method you could use to periodically call the MONITOR
; from your program if you don't want to use the IRQ interface.
;
                OFF16
NATIVE_CHECK:
                PHP
                ON16
                PHB
                PHA
                PHX
                PHY
                PHD

                OFF16
                LDA     #0
                PHA
                PLB

                LDA     >AI_STATUS       ;GET THE AI STATUS
                CMP     #$CC            ;IS THE AI THERE?
                BEQ     NC_NO_AI
                AND     #2              ;IS DATA FROM THE HOST AVAILABLE?
                BEQ     NC_NO_AI        ;YES, GO PROCESS IT.

                ON16
                LDA     #MRAMBASE
                PHA
                LDX     #NATIVE_STACK   ;Native stack frame pointer
                LDY     #0              ;Native stack frame bank
                JSL     >MONITOR_IRQ_ENTRY
                PLA
NC_NO_AI:
                ON16
                PLD
                PLY
                PLX
                PLA
                PLB
                PLP
                RTL

;-----------------Include the MONITOR-----------------------------------------

        INCLUDE MONDB.INC


;******************************************************************************
;****************END OF DEMONSTRATION SECTION**********************************
;******************************************************************************


COPROUT:
                RTI

NNMI:
                RTI

ABRTROUT:
                RTI

ECOP:
                RTI

ERES:
                RTI

EABORT:
                RTI

ENMI:
                RTI


                ENDS



VECTORSN:       SECTION

                DW      COPROUT         ;FFE4
                DW      NATIVE_BREAK
                DW      ABRTROUT
                DW      NNMI
                DW      RESET
                DW      NATIVE_SIRQ
                ENDS


VECTORSE:       SECTION                 ;FFF4
                DW      ECOP
                DW      ERES
                DW      EABORT
                DW      ENMI
                DW      RESET
                DW      EMULATION_SIRQ
                ENDS

