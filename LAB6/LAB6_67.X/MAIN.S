;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;09/25/25
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
#include <pic16f883.inc>
;Code Section
;-------------------------------------------------------------------------------
;Register/Variable setup
SOMEVALUE EQU 0x5f ; asign a value to a  variable
    
    ;Start of Program
PSECT resetVect,class=CODE,delta=2
    GOTO START
    
PSECT isrVect,class=CODE,delta=2
    CALL INTERUPT
    RETFIE
    
PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    ;PORTC
 ;BANK1
   BSF	STATUS,5
   BCF	STATUS,6
   CLRF    PSTRCON
   CLRF    TRISC
  ;BANK0
   BCF	STATUS,5
   BCF	STATUS,6
   CLRF    SSPCON
   CLRF    RCSTA
   CLRF    T1CON
   CLRF    CCP1CON
   CLRF    CCP2CON
   CLRF    PORTC
   MOVLW   0x00
   MOVWF   PORTC
    ;PORTB
 ;BANK3
    BSF	0x03,5
    BSF	0x03,6 
    ClRF    ANSELH	;Set input to Digital
    CLRF    ANSEL	;Sets inputs to digital
    MOVLW   0xC8	;Set GIE on and INTE on
    MOVWF   INTCON	;Contrids Interupt
    BCF	    INTCON, 0
    MOVLW   0x03	;ALL PINS are outputs
    MOVWF   TRISB	;Sets ALL PINS to output
    MOVLW   0xC0	;Sets falling edge INT, and no pull up
    CLRF    OPTION_REG
  ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF   WPUB 
    CLRF   IOCB		;Disables interrupton
    BSF	   IOCB, 1
    BSF	   IOCB, 0
  ;BANK2
    BCF	0x03,5
    BSF	0x03,6
    CLRF    CM2CON1	;Sets all bits to 0
  ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    PORTB
    CLRF    CCP1CON
    W7_SAVE	EQU 0x20	;for main loop W
    OPT7_SAVE	EQU 0x21    ;for main loop 
    W6_SAVE	EQU 0x26    ;6 interupt save
    OPT6_SAVE   EQU 0x27
    COUNT1	EQU 0x22
    COUNT2	EQU 0x23
    COUNT3	EQU 0x24
    COUNT4	EQU 0x25
    COUNT1_SAVE	EQU 0x28
    COUNT2_SAVE	EQU 0x29
    COUNT3_SAVE	EQU 0x2A
    COUNT4_SAVE	EQU 0x2B
    DISPLAY1_SAVE EQU 0x2C
    DISPLAY6_SAVE EQU 0x2D
    GOTO    MAIN

MAIN:
    MOVLW   0x31
    MOVWF   PORTC
    GOTO MAIN
    
INTERUPT:
    BTFSS   PORTB, 0
    GOTO    DISPLAY7
    BTFSS   PORTB, 1
    GOTO    DISPLAY6
LEAVE:    
    RETURN

DISPLAY7:
    MOVWF   W7_SAVE
    MOVF    OPTION_REG, 0
    MOVWF   OPT7_SAVE
    MOVF    COUNT1, 0
    MOVWF   COUNT1_SAVE
    MOVF    COUNT2, 0
    MOVWF   COUNT2_SAVE
    MOVF    COUNT3, 0
    MOVWF   COUNT3_SAVE
    MOVF    COUNT4, 0
    MOVWF   COUNT4_SAVE
    MOVLW   0x37
    MOVWF   PORTC
    CALL    DELAY 
    MOVF    COUNT1_SAVE, 0
    MOVWF   COUNT1
    MOVF    COUNT2_SAVE, 0
    MOVWF   COUNT2
    MOVF    COUNT3_SAVE, 0
    MOVWF   COUNT3
    MOVF    COUNT4_SAVE, 0
    MOVWF   COUNT4
    MOVF    OPT7_SAVE, 0
    MOVF    DISPLAY1_SAVE, 0
    MOVWF   PORTC
    MOVWF   OPTION_REG
    MOVF    W7_SAVE, 0
    BCF	    INTCON, 0
    GOTO    LEAVE
    
DISPLAY6:
    MOVWF   W6_SAVE
    MOVF    OPTION_REG, 0
    MOVWF   OPT6_SAVE
    BSF	STATUS, 5
    BCF	STATUS, 6
    BCF	    IOCB, 1
    BCF	STATUS, 5
    BCF	STATUS, 6
    BCF	    INTCON, 0
    BSF	    INTCON, 7
    MOVLW   0x36
    MOVWF   DISPLAY1_SAVE
    MOVWF   PORTC
    CALL    DELAY
    BSF	STATUS, 5
    BCF	STATUS, 6
    BSF	    IOCB, 1
    BCF	STATUS, 5
    BCF	STATUS, 6
    MOVF    OPT6_SAVE, 0
    MOVWF   OPTION_REG
    MOVF    W6_SAVE, 0
    BCF	    INTCON, 0
    GOTO    LEAVE
    
DELAY:
    BCF	STATUS, 5
    BCF	STATUS, 6
    	MOVLW	0x0B	;11	
	MOVWF	COUNT3	
    LOOP3:
	MOVLW	0xED	;185
	MOVWF	COUNT2
    LOOP2:
	MOVLW	0xFF	;32
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
    RETURN
	
    
	
END