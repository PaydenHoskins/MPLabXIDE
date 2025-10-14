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
    ADRESH_SAVE EQU 0x20
    COUNT1 EQU	0x21
    COUNT2 EQU	0x22
 
    ;Start of Program
    PSECT resetVect,class=CODE,delta=2
	GOTO START
    
    PSECT isrVect,class=CODE,delta=2
	GOTO INTERRUPT
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    CLRF    PIR1
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    T1CON
    MOVLW   0x26
    MOVWF   T2CON
    CLRF    CCP1CON
    CLRF    CCP2CON
    MOVLW   0x43
    MOVWF   ADCON0
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    
    ;BANK1
    BSF	    STATUS,5
    CLRF    ADCON1
    CLRF    TRISA
    BSF	    TRISA,0
    CLRF    TRISB
    BSF	    TRISB,1
    BSF	    TRISB,0
    CLRF    TRISC
    MOVLW   0x02
    MOVWF   PIE1
    CLRF    PSTRCON
    
    ;BANK2
    BSF     STATUS,6
    BCF	    STATUS,5
    CLRF    CM2CON1
    
    ;BANK3
    BSF	    STATUS,6
    BSF	    STATUS,5
    CLRF    ANSELH
    CLRF    ANSEL
    BSF	    ANSEL,0

    ; BANK0: OPTION + interrupts
    BCF     STATUS,5
    BCF     STATUS,6
    MOVLW   0x00
    MOVWF   OPTION_REG
    MOVLW   0xC0
    MOVWF   INTCON
    BCF     INTCON,0     ; clear RBIF
    
    GOTO    MAIN
    
    MAIN:
    BSF	    ADCON0,1
    BSF	    ADCON0,0
    MOVF    ADRESH,0
    BCF	PORTC,0
    GOTO    MAIN
    
    INTERRUPT:
    CLRF    PIR1
    BSF	    PORTC,0
    MOVLW   155	
    BTFSC   PORTB,1
    MOVLW   0xF7
    BTFSC   PORTB,0
    MOVLW   55
    MOVWF   COUNT2
    LOOP2:
    MOVLW   0x02	;
    MOVWF   COUNT1
    LOOP1:
    DECFSZ  COUNT1	;+1(2)
    GOTO    LOOP1	;+2
    DECFSZ  COUNT2	;+1(2)
    GOTO    LOOP2	;+2
    BCF	PORTC,0
    RETFIE
    
    LOOKUP:
//    BTFSC
//    MOVLW   55
//    BTFSC
//    MOVLW   63
//    BTFSC
//    MOVLW   71
//    BTFSC
//    MOVLW   79
//    BTFSC
//    MOVLW   87
//    BTFSC
//    MOVLW   95
//    BTFSC
//    MOVLW   103
//    BTFSC
//    MOVLW   111
//    BTFSC
//    MOVLW   119
//    BTFSC
//    MOVLW   127
//    BTFSC
//    MOVLW   135
//    BTFSC
//    MOVLW   143
//    BTFSC
//    MOVLW   151
//    BTFSC
//    MOVLW   159
//    BTFSC
//    MOVLW   167
//    BTFSC
//    MOVLW   175
//    BTFSC
//    MOVLW   183
//    BTFSC
//    MOVLW   191
//    BTFSC
//    MOVLW   199
//    BTFSC
//    MOVLW   207
//    BTFSC
//    MOVLW   215
//    BTFSC
//    MOVLW   223
//    BTFSC
//    MOVLW   231
//    BTFSC
//    MOVLW   239
//    BTFSC
//    MOVLW   247
    RETURN
    
    
    END
    