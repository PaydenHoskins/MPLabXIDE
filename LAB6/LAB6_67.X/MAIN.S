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
	RETFIE
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    
    ; BANK1: TRIS setup
    BSF     STATUS,5
    BCF     STATUS,6
    CLRF    PSTRCON
    MOVLW   0x03         ; 0,1 PORTB = inputs
    MOVWF   TRISB
    CLRF    TRISC        ; all PORTC = outputs
    MOVLW   0x03
    MOVWF   IOCB    
    CLRF    WPUB
    MOVLW   0x02
    MOVWF    PIE1
    
    ; BANK0: clear peripherals + I/O
    BCF     STATUS,5
    BCF     STATUS,6
    CLRF    PIR1
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    T1CON
    CLRF    CCP1CON
    CLRF    CCP2CON
    MOVLW	0x00
    MOVWF   PORTB
    MOVLW	0x00
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
    MOVLW   0x00
    MOVWF   OPTION_REG
    MOVLW   0x88
    MOVWF   INTCON
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
    DISPLAY_SAVE EQU 0x2C
    DISPLAY6_SAVE EQU 0x2D
 
    GOTO    MAIN
    
    MAIN:
    MOVLW   0x31
    MOVWF   DISPLAY_SAVE
    MOVLW   0x31
    MOVWF   PORTC
    GOTO MAIN
    
    INTERUPT:
    MOVWF   W7_SAVE
    MOVF    STATUS,0
    MOVWF   STAT7_SAVE
    BTFSS   PORTB, 0
    GOTO    DISPLAY7
    
    MOVWF   W6_SAVE
    MOVF    STATUS,0
    MOVWF   STAT6_SAVE    
    BTFSS   PORTB, 1
    GOTO    DISPLAY6
    GOTO    BACK

    DISPLAY7:
    ;MOVWF   W7_SAVE
    ;MOVF    STATUS,0
    ;MOVWF   STAT7_SAVE
   
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
    
    MOVF    DISPLAY_SAVE,0
    MOVWF   PORTC
    
    MOVF    COUNT1_SAVE,0
    MOVWF   COUNT1    
    MOVF    COUNT2_SAVE,0
    MOVWF   COUNT2
    MOVF    COUNT3_SAVE,0
    MOVWF   COUNT3
    MOVF    COUNT4_SAVE,0
    MOVWF   COUNT4    
    
    MOVF    W7_SAVE,0
    GOTO    BACK
    
    DISPLAY6:
    ;MOVWF   W6_SAVE
    ;MOVF    STATUS,0
    ;MOVWF   STAT6_SAVE
   
    BSF	    STATUS,5
    BCF	    STATUS,6
    BCF	    IOCB,1
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    BSF	    INTCON,7
    BCF	    INTCON,0
    
    MOVLW   0x36
    MOVWF   PORTC  
    
    CALL    DELAY
    
    MOVF    STAT6_SAVE,0
    MOVWF   STATUS
    
    MOVF    DISPLAY_SAVE,0
    MOVWF   PORTC
    
    BSF	    STATUS,5
    BCF	    STATUS,6
    BSF	    IOCB,1
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    MOVF    W6_SAVE,0    
    BCF	    INTCON, 0
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