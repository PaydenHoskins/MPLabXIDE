;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;10/13/25
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
   COUNT1  EQU  0x20
    COUNT2  EQU	 0x21
    COUNT3  EQU	 0x22
    COUNT4  EQU	 0x23
    S_REG   EQU	 0x24
    S_COUNT1  EQU  0x25
    S_COUNT2  EQU	 0x26
    S_COUNT3  EQU	 0x27
    S_COUNT4  EQU	 0x28
    DECCOUNT	EQU 0x29
    DECCOUNT2	EQU 0x2A
    DECCOUNT3	EQU 0x2B
    ADSAVE	EQU 0x2C
 
    ;Start of Program
    PSECT resetVect,class=CODE,delta=2
	GOTO START
    
    PSECT isrVect,class=CODE,delta=2
	GOTO INTERRUPT
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
  ;BANK1
    BSF	STATUS,5
    BCF	STATUS,6
    CLRF    PSTRCON
    CLRF    TRISC
    MOVLW   0x30
    MOVWF   IOCB
  ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    CLRF    ADSAVE
    CLRF    DECCOUNT
    CLRF    DECCOUNT2
    MOVLW   156
    MOVWF   DECCOUNT3
    MOVLW   0x53
    MOVWF   S_REG
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
    MOVLW   0xF0	;LSB are outputs
    MOVWF   TRISB	;Set Pins to Inputs
    CLRF    OPTION_REG
    BSF	    OPTION_REG,7
    MOVLW   0x80
    MOVWF   EECON1
   ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF   WPUB 
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
    MOVLW   0x01
    ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    PORTA
    CLRF    INTCON	;Contrids Interupt
    BCF	    STATUS,2
    BCF	    INTCON,0    
    MOVLW   0xC8
    MOVWF   INTCON
    BCF	    PIR2,4
    
    MAIN:
    MOVLW   0x53
    XORWF   S_REG,1
    MOVF    S_REG,0
    MOVWF   PORTC
    CALL    DELAY
    GOTO MAIN
    
    
    INTERRUPT:
    CLRF    ADSAVE
    BTFSC   PORTB,5
    GOTO    RECORD_INTERRUPT
    BTFSC   PORTB,4
    GOTO    READ_INTERRUPT
    BCF	    INTCON,0
    RETFIE
    
    READ_INTERRUPT:
    MOVF    COUNT1,0
    MOVWF   S_COUNT1
    MOVF    COUNT2,0
    MOVWF   S_COUNT2
    MOVF    COUNT3,0
    MOVWF   S_COUNT3
    MOVF    COUNT4,0
    MOVWF   S_COUNT4
    
    MOVF    ADSAVE,0 ;SELECT ADDRESS
    
    BSF	    STATUS,6
    MOVWF   EEADR
    BSF	    STATUS,5
    BCF	    EECON1,7
    BSF	    EECON1,0
    BCF	    STATUS,5
    MOVF    0x0C,0
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVWF   PORTC
    INCF    ADSAVE
    CALL    DELAY
    MOVLW   0x0A
    XORWF   ADSAVE,0
    BTFSS   STATUS,2
    GOTO    $-19
    GOTO    DONE
    
    
    
    
    RECORD_INTERRUPT:
    MOVF    COUNT1,0
    MOVWF   S_COUNT1
    MOVF    COUNT2,0
    MOVWF   S_COUNT2
    MOVF    COUNT3,0
    MOVWF   S_COUNT3
    MOVF    COUNT4,0
    MOVWF   S_COUNT4
    
    
    CALL    BUTTON
    BTFSC   PORTA,0
    GOTO    DONE    
    MOVLW   0x0A
    XORWF   ADSAVE,0
    BTFSS   STATUS,2
    GOTO    $-6
    BCF	STATUS,5
    BCF	STATUS,6
    GOTO    DONE
    
    
    DONE:
    BCF	STATUS,5
    BCF	STATUS,6
    MOVF    S_COUNT1,0
    MOVWF   COUNT1
    MOVF    S_COUNT2,0
    MOVWF   COUNT2
    MOVF    S_COUNT3,0
    MOVWF   COUNT3
    MOVF    S_COUNT4,0
    MOVWF   COUNT4
    BCF	    INTCON,0
    BCF	    STATUS,2
    RETFIE
	
    
    BUTTON:
    BCF	STATUS,5
    BCF	STATUS,6
    ;ROW1
    MOVLW   0x08    ;+1
    MOVWF   PORTB   ;+1
    MOVLW   0
    BTFSC   PORTA,1
    GOTO    DOSTUFF
    MOVLW   2
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    MOVLW   4
    BTFSC   PORTA,3
    GOTO    DOSTUFF
    MOVLW   6
    BTFSC   PORTA,4
    GOTO    DOSTUFF 
    ;ROW2
    MOVLW   0x04
    MOVWF   PORTB
    MOVLW   8
    BTFSC   PORTA,1
    GOTO    DOSTUFF
    MOVLW   10
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    MOVLW   12
    BTFSC   PORTA,3
    GOTO    DOSTUFF
    MOVLW   14
    BTFSC   PORTA,4
    GOTO    DOSTUFF
    ;ROW3
    MOVLW   0x02
    MOVWF   PORTB
    MOVLW   16
    BTFSC   PORTA,1
    GOTO    DOSTUFF
    MOVLW   18
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    MOVLW   20
    BTFSC   PORTA,3
    GOTO    DOSTUFF
    MOVLW   22
    BTFSC   PORTA,4
    GOTO    DOSTUFF
    ;ROW4
    MOVLW   0x01
    MOVWF   PORTB
    MOVLW   24    ;+1
    BTFSC   PORTA,1
    GOTO    DOSTUFF ;+2
    MOVLW   26
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    MOVLW   28
    BTFSC   PORTA,3
    GOTO    DOSTUFF
    MOVLW   30
    BTFSC   PORTA,4
    CALL    DOSTUFF
    CLRF    PORTB
    RETURN
    
    
DOSTUFF:
   ADDWF    PCL,1
;NOTE16
    MOVLW   0x31   ;27	  
    GOTO    WRITE
;NOTE15
    MOVLW   0x32	;27		
    GOTO    WRITE
;NOTE14
    MOVLW   0x33	;27		    
    GOTO    WRITE
;NOTE13
    MOVLW   0x34	;27		
    GOTO    WRITE
;NOTE12
    MOVLW   0x35	;27		
    GOTO    WRITE
;NOTE11
    MOVLW   0x36	;27	   
    GOTO    WRITE
;NOTE10
    MOVLW   0x37	;27		       
    GOTO    WRITE
;NOTE9
    MOVLW   0x38	;27		       
    GOTO    WRITE
;NOTE8
    MOVLW   0x39	;27		       
    GOTO    WRITE
;NOTE7
    MOVLW   0x41	;27		       
    GOTO    WRITE
;NOTE6
    MOVLW   0x42	;27		        
    GOTO    WRITE
;NOTE5
    MOVLW   0x43	;27		        
    GOTO    WRITE
;NOTE4
    MOVLW   0x45	;27		       
    GOTO    WRITE
;NOTE3
    MOVLW   0x46	;27		        
    GOTO    WRITE
;NOTE2
    MOVLW   0x47	;27	        
    GOTO    WRITE
;NOTE1
    MOVLW   0x48	;27		        
    GOTO    WRITE
    
    WRITE:
    MOVWF   COUNT3
    MOVF    ADSAVE,0 ;moves address to w
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEADR ;Sets Address
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVF    COUNT3,0 ;moves number pressed to data
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   0x0C ;Move button press to EEPREOM
    BSF	    STATUS,5
    BSF	    STATUS,6
    MOVLW   0x04
    MOVWF   EECON1
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2 
    BSF	    EECON1,1
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    BTFSS   PIR2,4
    GOTO    $-1
    BCF	    PIR2,4
    
    MOVF    COUNT3,0
    MOVWF   PORTC
    
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6    
    
    INCF    ADSAVE
    RETURN
    
    DELAY:
    MOVLW	45	;27	
    MOVWF	COUNT3	
    LOOP3:
    MOVLW	185	;185
    MOVWF	COUNT2
    LOOP2:
    MOVLW	32	;32
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
	
    MOVLW	0x1	;1	
    MOVWF	COUNT4
    FUDGE:
    DECFSZ	COUNT4	;+1(2)
    GOTO	FUDGE
    RETURN