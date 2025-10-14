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
	GOTO INTERUPT
	BACK:
	BCF	INTCON,0
	RETFIE
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    
    ; BANK1: TRIS setup
    BSF     STATUS,5
    BCF     STATUS,6
    CLRF    PSTRCON
    CLRF    TRISB
    BSF	    TRISB,0
    BSF	    TRISB,1    
    CLRF    TRISC        ; all PORTC = outputs
    CLRF    IOCB 
    BSF     IOCB,0
    BSF	    IOCB,1    
    CLRF    WPUB
    CLRF    PIE1
    CLRF    PIE2
    
    ; BANK0: clear peripherals + I/O
    BCF     STATUS,5
    BCF     STATUS,6
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    T1CON
    CLRF    CCP1CON
    CLRF    CCP2CON
    MOVLW   0x00
    MOVWF   PORTB
    MOVLW   0x30
    MOVWF   PORTC

    ; BANK2: disable comparators
    BSF     STATUS,6
    CLRF    CM2CON1
    BCF     STATUS,6     ; back to Bank0

    ; BANK3: digital mode
    BSF     STATUS,5
    BSF     STATUS,6    
    CLRF    ANSELH
    CLRF    ANSEL    

    ; BANK0: OPTION + interrupts
    BCF     STATUS,5
    BCF     STATUS,6
    CLRF    PIR1
    CLRF    PIR2
    MOVLW   0x00
    MOVWF   OPTION_REG
    BCF     INTCON,0     ; clear RBIF
    
    W7_SAVE	EQU 0x20	;for main loop W
    STAT7_SAVE	EQU 0x21    ;for main loop 
    W6_SAVE	EQU 0x26    ;6 interupt save
    STAT6_SAVE   EQU 0x27
    COUNT1	EQU 0x22
    COUNT2	EQU 0x23
    COUNT3	EQU 0x24
    COUNT4	EQU 0x25
    COUNT1_SAVE	EQU 0x28
    COUNT2_SAVE	EQU 0x29
    COUNT3_SAVE	EQU 0x2A
    COUNT4_SAVE	EQU 0x2B
    IOCB7_SAVE EQU 0x2C
    IOCB6_SAVE EQU 0x2E
    DISPLAY7_SAVE EQU 0x2D

    CLRF    INTCON
    MOVLW   0x88
    MOVWF   INTCON
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
    GOTO    BACK

    DISPLAY7:
    
    MOVWF   W7_SAVE
    BSF	    STATUS,5
    MOVF    IOCB,0
    BCF	    STATUS,5
    MOVWF   IOCB7_SAVE
    MOVF    PORTC,0
    MOVWF   DISPLAY7_SAVE
    MOVF    STATUS,0
    MOVWF   STAT7_SAVE
    MOVF    PORTC,0
    MOVWF   DISPLAY7_SAVE
    MOVF    COUNT1,0
    MOVWF   COUNT1_SAVE
    MOVF    COUNT2,0
    MOVWF   COUNT2_SAVE
    MOVF    COUNT3,0
    MOVWF   COUNT3_SAVE
    MOVF    COUNT4,0
    MOVWF   COUNT4_SAVE
    
    MOVLW   0x37
    MOVWF   PORTC  
    
    CALL    DELAY
    
    MOVF    STAT7_SAVE,0
    MOVWF   STATUS
    
    MOVF    COUNT1_SAVE,0
    MOVWF   COUNT1    
    MOVF    COUNT2_SAVE,0
    MOVWF   COUNT2
    MOVF    COUNT3_SAVE,0
    MOVWF   COUNT3
    MOVF    COUNT4_SAVE,0
    MOVWF   COUNT4    
    
    MOVF    DISPLAY7_SAVE,0
    MOVWF   PORTC
    
    MOVF    IOCB7_SAVE,0
    BSF	    STATUS,5
    MOVWF   IOCB
    BCF	    STATUS,5
    
    MOVF    W7_SAVE,0
    BCF	    INTCON,0	
    GOTO    BACK
    
    DISPLAY6:
    MOVWF   W6_SAVE 
    
    BSF	    STATUS,5
    MOVF    IOCB,0
    BCF	    IOCB,1 
    BSF	    IOCB,0
    BCF	    STATUS,5
    MOVWF   IOCB6_SAVE    

    MOVF    STATUS,0
    MOVWF   STAT6_SAVE    
    
    BCF	    INTCON,0
   
    
    MOVLW   0x36
    MOVWF   PORTC  
    
    BSF	    INTCON,7
    
    CALL    DELAY
    
    BCF INTCON,7
    
    MOVF    STAT6_SAVE,0
    MOVWF   STATUS
      

    
    BSF	    STATUS,5
    BSF	    IOCB,1  
    BCF	    STATUS,5
    
    BCF	    INTCON,0
    MOVF    IOCB6_SAVE,0
    
    BSF	    STATUS,5
    MOVLW   0x03
    MOVWF   IOCB
    BCF	    STATUS,5
    
    ;MOVLW   0x31
    ;MOVWF   PORTC
    
    MOVF    W6_SAVE,0
    GOTO    BACK
    
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