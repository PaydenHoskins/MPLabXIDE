;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB5
    ;09/19/25
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
    ;GOTO ISR_Handler
    RETFIE
    
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
 START:
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
    MOVLW   0x01
    MOVWF   PORTC
   ;PORTB
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6 
    ClRF    ANSELH	;Set input to Digital
    CLRF    ANSEL	;Sets inputs to digital
    CLRF    INTCON	;Contrids Interupt
    MOVLW   0xF0	;LSB are outputs
    MOVWF   TRISB	;Set Pins to Inputs
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
    ;PORTA
    ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF    TRISA
    ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    PORTA
    
    
    COUNT1  EQU  0x20
    COUNT2  EQU	 0x21
    COUNT3  EQU	 0x22
    COUNT4  EQU	 0x23
    
    MAIN:
    BCF	0x03,5
    BCF	0x03,6
    ;ROW1
    MOVLW   0x08    ;+1
    MOVWF   PORTB   ;+1
    MOVLW   0x00    ;+1
    BTFSC   PORTB,7 ;+2(1)
    CALL    DOSTUFF ;+2
    MOVLW   0x05
    BTFSC   PORTB,6
    CALL    DOSTUFF
    MOVLW   0x0A
    BTFSC   PORTB,5
    CALL    DOSTUFF
    MOVLW   0x0F
    BTFSC   PORTB,4
    CALL    DOSTUFF
    ;ROW2
    MOVLW   0x04
    MOVWF   PORTB
    MOVLW   0x14
    BTFSC   PORTB,7
    CALL    DOSTUFF
    MOVLW   0x19
    BTFSC   PORTB,6
    CALL    DOSTUFF
    MOVLW   0x1E
    BTFSC   PORTB,5
    CALL    DOSTUFF
    MOVLW   0x23
    BTFSC   PORTB,4
    CALL    DOSTUFF
    ;ROW3
    MOVLW   0x02
    MOVWF   PORTB
    MOVLW   0x28
    BTFSC   PORTB,7
    CALL    DOSTUFF
    MOVLW   0x2D
    BTFSC   PORTB,6
    CALL    DOSTUFF
    MOVLW   0x32
    BTFSC   PORTB,5
    CALL    DOSTUFF
    MOVLW   0x37
    BTFSC   PORTB,4
    CALL    DOSTUFF
    ;ROW4
    MOVLW   0x01
    MOVWF   PORTB
    MOVLW   0x3C
    BTFSC   PORTB,7
    CALL    DOSTUFF
    MOVLW   0x41
    BTFSC   PORTB,6
    CALL    DOSTUFF
    MOVLW   0x46
    BTFSC   PORTB,5
    CALL    DOSTUFF
    MOVLW   0x4B
    BTFSC   PORTB,4
    CALL    DOSTUFF 
    CLRF    PORTB
    GOTO MAIN
    
DOSTUFF:
   ADDWF    PCL,1
;NOTE1
    MOVLW   0x34	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE2
    MOVLW   0x3A	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE3
    MOVLW   0x43	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE4
    MOVLW   0x4B	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE5
    MOVLW   0x54	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE6
    MOVLW   0x5F	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE7
    MOVLW   0x66	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE8
    MOVLW   0x71	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE9
    MOVLW   0x7E	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE10
    MOVLW   0x87	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE11
    MOVLW   0x97	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE12
    MOVLW   0xAA	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE13
    MOVLW   0xBF	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE14
    MOVLW   0xCA	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE15
    MOVLW   0xDF	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
;NOTE16
    MOVLW   0xFE	;27	
    MOVWF   COUNT3	
    CALL    SHITLOOP
    CALL    NOTE
    RETURN
    
    
    
    
NOTE:
LOOP3:
    MOVLW	0x01	;185
    MOVWF	COUNT2
LOOP2:
    MOVLW	0x01	;32
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
    RETURN
    
SHITLOOP:
    MOVLW	0x01
    XORWF	PORTA 
    MOVWF	PORTC
    RETURN
    END
   