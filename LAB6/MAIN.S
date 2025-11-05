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
    MOVWF   W_SAVE
    MOVF    OPTION_REG, 0
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
    MOVLW   0x90	;Set GIE on and INTE on
    MOVWF    INTCON	;Contrids Interupt
    MOVLW   0x01	;ALL PINS are outputs
    MOVWF   TRISB	;Sets ALL PINS to output
    MOVLW   0xC0	;Sets falling edge INT, and no pull up
    CLRF    OPTION_REG
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
    GOTO    MAIN
    W_SAVE  EQU	0x20
    OPT_SAVE	EQU 0x21
    COUNT1  EQU  0x22
    COUNT2  EQU	 0x23
    COUNT3  EQU	 0x24
    COUNT4  EQU	 0x25
	
MAIN:
    MOVLW   0x31
    MOVWF   PORTC
    GOTO MAIN
    
INTERUPT:
    MOVWF   OPT_SAVE
    MOVLW   0x37
    MOVWF   PORTC
    CALL    DELAY
    MOVF    OPT_SAVE, 0
    MOVWF   OPTION_REG
    MOVF    W_SAVE, 0
    BCF	    INTCON, 1
    RETURN
    
     DELAY:
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