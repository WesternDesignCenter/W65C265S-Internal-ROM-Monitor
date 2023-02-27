;*
;* Macros used for 65816 monitor.
;* Copyright 1991, Red Mountain Software
;*                 1504 N. Sinova
;*                 Mesa, AZ  85205
;*                 (602) 981-8550 voice
;*                 (602) 461-9039 BBS/FAX
;*
;-------------------------M--A--C--R--O--S-------------------------------------
                CONDLIST OFF

MEM16           EQU     $20
IND16           EQU     $10
*
;------------------------------------------------------------------------------
RSDEL           .MACRO
;                NOP
;                NOP
;                NOP
                ENDM
;------------------------------------------------------------------------------
ON16MEM         .MACRO
                LONGA   ON
                REP     #MEM16
                ENDM

OFF16MEM        .MACRO
                LONGA   OFF
                SEP     #MEM16
                ENDM

;------------------------------------------------------------------------------
ON16            .MACRO
                .LONGI  ON
                .LONGA  ON
                REP     #<(MEM16.OR.IND16)
                .ENDM

;------------------------------------------------------------------------------
OFF16           .MACRO
                .LONGI  OFF
                .LONGA  OFF
                SEP     #<(MEM16.OR.IND16)
                .ENDM

;------------------------------------------------------------------------------
OFF16X          .MACRO
                .LONGI  OFF
                SEP     #<(IND16)
                .ENDM

;------------------------------------------------------------------------------
ON16X           .MACRO
                .LONGI  ON
                REP     #<(IND16)
                .ENDM

;------------------------------------------------------------------------------
MOVE            .MACRO  NUMB,FROM,TO,FBANK,TBANK
        .IFSAME FROM,X
        .ELSE
                LDX     FROM
        .ENDIF
        .IFSAME TO,Y
        .ELSE
                LDY     TO
        .ENDIF
                LDA     NUMB
                DEC     A
                PHB
                MVN     #TBANK,#FBANK
                PLB
                .ENDM

;------------------------------------------------------------------------------

MIF             .MACRO  ARG1,CNDIT,ARG2,JMPTO

              .IFSAME  ARG1,A
                .IFSAME  ARG2,X
                  STX   COMPWORK
                  CMP   COMPWORK
                .ELSE
                .IFSAME  ARG2,Y
                  STY   COMPWORK
                  CMP   COMPWORK
                .ELSE
                  CMP   ARG2
                .ENDC
                .ENDIF
              .ELSE
              .IFSAME  ARG1,X
                .IFSAME  ARG2,A
                  STA   COMPWORK
                  CPX   COMPWORK
                .ELSE
                .IFSAME  ARG2,Y
                  STY   COMPWORK
                  CPX   COMPWORK
                .ELSE
                  CPX   ARG2
                .ENDC
                .ENDIF
              .ELSE

              .IFSAME  ARG1,Y
                .IFSAME  ARG2,X
                  STX   COMPWORK
                  CPY   COMPWORK
                .ELSE
                .IFSAME  ARG2,A
                  STA   COMPWORK
                  CPY   COMPWORK
                .ELSE
                  CPY   ARG2
                .ENDC
                .ENDIF
              .ENDIF
              .ENDIF
              .ENDIF
;
;
              .IFSAME    CNDIT,EQ
                BEQ     JMPTO
              .ENDIF
;
              .IFSAME    CNDIT,LT
                BCC     JMPTO
              .ENDIF
;
              .IFSAME    CNDIT,GT
                BEQ     IFLB1#
                BCS     JMPTO
IFLB1#:
              .ENDIF
;
              .IFSAME    CNDIT,LE
                BEQ     JMPTO
                BCC     JMPTO
              .ENDIF
;
              .IFSAME    CNDIT,GE
                BCS     JMPTO
              .ENDIF
              .ENDM

;------------------------------------------------------------------------------
; relative Branch to SubRoutine
;
BSR             .MACRO  SUBNAME
                PER     #2
                BRL     SUBNAME
                .ENDM
;------------------------------------------------------------------------------
; relative Branch to Subroutine Long
;
BSL             .MACRO  SUBNAME
                PHK
                PER     #2
                BRL     SUBNAME
                .ENDM
;------------------------------------------------------------------------------
; restore the stack pointer to address prior to stack parameter passing
;
RESTORE_STACK   .MACRO  NUMB

                TSX
                ON16MEM
                TXA
                CLC
                ADC     NUMB
                TAX
                OFF16MEM
                TXS
                .ENDM
;-------------------------M--A--C--R--O--S-------------------------------------
                LIST ON
