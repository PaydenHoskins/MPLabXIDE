;Header
    ;Payden Hoskins
    ;RCET3375
    ;TEST_FILE
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
#include <pic16f883.inc>    ;INCLUDE pic status calls
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
    ;PORTB
    ;BANK3
    BSF	STATUS,5
    BSF	STATUS,6 
    ClRF    ANSELH	;Set input to Digital
    CLRF    ANSEL	;Sets inputs to digital
    CLRF    INTCON	;Contrids Interupt
    MOVLW   0x00	;Sets outputs
    MOVWF   TRISB	;Set Pins to outputs
    CLRF    OPTION_REG
    BSF	    OPTION_REG,7
   ;BANK1
    BSF	STATUS,5
    BCF	STATUS,6
    CLRF   WPUB 
    CLRF   IOCB		;Disables interrupton
    ;BANK2
    BCF	STATUS,5
    BSF	STATUS,6
    CLRF    CM2CON1	;Sets all bits to 0
    ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    CLRF    CCP1CON
    
MAIN:
    INCF    PORTB,1
    GOTO    MAIN
    
END