;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB4.1
    ;09/15/25
    ;-------------------------------------------------------------------------------
;Configuration
 ; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
  ;Include Statments
#include <xc.inc>
;Code Section
;-------------------------------------------------------------------------------
    ;Register/Variable setup
    SOMEVALUE EQU 0x5f ; asign a value to a  variable
    
;Start of Program
    PSECT restVect,class=CODE,delta=2
    GOTO START
    PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
START:
    ;PORTB
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6 
    ClRF    ANSELH	;Set input to Digital
    CLRF    ANSEL	;Sets inputs to digital
    CLRF    INTCON	;Contrids Interupt
    MOVLW   0x00	;Sets outputs
    MOVWF   TRISB	;Set Pins to outputs
    CLRF    OPTION_REG
    BSF	    OPTION_REG,7
   ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF   WPUB 
    CLRF   IOCB		;Disables interrupton
    ;BANK2
    BCF	0x03,5
    BSF	0x03,6
    CLRF    CM2CON1	;Sets all bits to 0
    ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    CCP1CON
    COUNT1  EQU  0x20
    COUNT2  EQU	 0x21
    COUNT3  EQU	 0x22
    COUNT4  EQU	 0x23
    


    
    
    
;CODE
    MAIN1:
     ;SET PORTB 0
	MOVLW	0x30
	MOVWF	PORTB
	NOP
	NOP
	
	
     ;LOOPS
	MOVLW	0x1B	;27	
	MOVWF	COUNT3	
    LOOP3:
	MOVLW	0xB9	;185
	MOVWF	COUNT2
    LOOP2:
	MOVLW	0x20	;32
	MOVWF	COUNT1
    LOOP1:
	DECFSZ	COUNT1	;+1(2)
	GOTO	LOOP1	;+2
	DECFSZ	COUNT2	;+1(2)
	GOTO	LOOP2	;+2
	NOP		;+1
	NOP		;+1
	NOP		;+1
	NOP		;+1
	DECFSZ	COUNT3	;+1(2)
	GOTO	LOOP3	;+2
	
	MOVLW	0x5E	;94	
	MOVWF	COUNT4
    FUDGE:
	DECFSZ	COUNT4	;+1(2)
	GOTO	FUDGE

      ;PUT 5 on output
	MOVLW	0x35
	MOVWF	PORTB
	NOP
	NOP
	NOP
	
      ;LOOPS
	MOVLW	0x1B	;27	
	MOVWF	COUNT3	
    LOOP6:
	MOVLW	0xB9	;185
	MOVWF	COUNT2
    LOOP5:
	MOVLW	0x20	;32
	MOVWF	COUNT1
    LOOP4:
	DECFSZ	COUNT1	;+1(2)
	GOTO	LOOP4	;+2
	DECFSZ	COUNT2	;+1(2)
	GOTO	LOOP5	;+2
	NOP
	NOP
	NOP
	NOP
	DECFSZ	COUNT3	;+1(2)
	GOTO	LOOP6	;+2
	
	MOVLW	0x5E	;94	
	MOVWF	COUNT4
    FUDGE1:
	DECFSZ	COUNT4	;+1(2)
	GOTO	FUDGE1
	
	GOTO MAIN1
    END
	 
	 