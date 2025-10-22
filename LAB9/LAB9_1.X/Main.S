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
    SAVE_RX EQU	0x20
 
 
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
    ;Setup transmit
    MOVLW   0x2E
    MOVWF   TXSTA
    ;Enable pin 1 input
    MOVLW   0x01
    MOVWF   TRISA
    ;CLR TRISB
    CLRF    TRISB
    ;Enable Specific int flags
    MOVLW   0x20
    MOVWF   PIE1
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
    
    ;BANK2
    BCF	STATUS,5
    BSF	STATUS,6
    
    
    ;BANK3
    BSF	STATUS,5
    ;Set up baud rate
    MOVLW   0x01
    MOVWF   BAUDCTL
    
    ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    ;Setup Recive
    MOVLW   0x90
    MOVWF   RCSTA
    ;CLR Ports
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    ;ENABLE INTERRUPTS
    CLRF    PIR1
    MOVLW   0xC0
    MOVWF   INTCON
    
    
    GOTO    MAIN
    
    
    MAIN:
    MOVF    SAVE_RX,0
    MOVWF   PORTB
 
    GOTO    MAIN
    
    INTERRUPT:
    BSF	    STATUS,5
    CLRF    PIE1
    BCF	    STATUS,5
    MOVF    RCREG,0
    MOVWF   SAVE_RX
    MOVWF   TXREG
    BSF	    STATUS,5
    BSF     PIE1,5
    BCF	    STATUS,5
    CLRF    PIR1
    RETFIE
    