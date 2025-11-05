;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;11/4/25
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
 
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
    
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
START:
;BANK1
BSF STATUS,5
BCF STATUS,6
;SSPCON2&SSPSTAT
MOVLW	0xA0
MOVWF	SSPCON2
MOVLW	0x40
MOVWF	SSPSTAT
;TRIS SETS
CLRF	TRISA
CLRF	TRISB
MOVLW	0X01
MOVWF	TRISB
CLRF	TRISC
MOVLW	0x18
MOVWF	TRISC
;PIE SETUP
MOVLW	0x08
MOVWF	PIE1
MOVLW	0x08
MOVWF	PIE2
;PCON
CLRF	PCON
;WPUB
CLRF	WPUB
;IOCB
CLRF	IOCB
;BANK2
BCF STATUS,5
BSF STATUS,6

;BANK3
BSF STATUS,5
CLRF	ANSEL
CLRF	ANSELH
;BANK0
BCF STATUS,5
BCF STATUS,6
;MCCP
MOVLW	0x38
MOVWF	SSPCON
;PORT'S
CLRF	PORTA
CLRF	PORTB
CLRF	PORTC
;TIMER'S1&2
CLRF	T1CON
CLRF	T2CON
;INTCON
CLRF	INTCON
GOTO	MAIN
    
    
MAIN:
BTFSC	PORTB,0
GOTO	TRANSMIT
GOTO	MAIN
    
    
TRANSMIT:
BSF STATUS,5
BSF SSPCON2,0
BCF STATUS,5
MOVLW	0x40
MOVWF	SSPBUF
BSF STATUS,5
BTFSC	SSPSTAT,0
GOTO	$-1
BSF SSPCON2,2
BCF STATUS,5
GOTO	MAIN
