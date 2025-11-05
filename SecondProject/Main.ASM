;Header Stuff
    
;Payden Hoskins
;09/08/25
;RCET3371
;Git URL
;MY Third Lab
    
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
;Code Section
;-------------------------------------------------------------------------------
    
;Register/Variable setup
    SOMEVALUE EQU 0x5f ; asign a value to a  variable
    
;Start of Program
    PSECT restVect,class=CODE,delta=2
    GOTO START
    PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
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
 ;PORTB
   ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF    0x95 
    CLRF    0x96    ;Disables interrupton
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6
    CLRF    0x18B   ;Contrids Interupt
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6
    MOVLW   0xff   
    MOVWF   0x186   ;Set Pins to Inputs
    ClRF    0x189   ;Set input to Digital
    CLRF    0x188   ;Sets inputs to digital
    CLRF    0x181
    CLRF    0x186
    BSF	    0x181,7
    ;BANK2
    BCF	0x03,5
    BSF	0x03,6
    CLRF    0x109   ;Sets all bits to 0
    ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF    0x95
    ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    0x17
    CLRF    0x06    ;Sets all portB outputs to 0
    
MAIN:
    ;CODE
    BCF	0x03,5
    BCF	0x03,6
    MOVLW   0x38
    BTFSC   PORTB,7
    GOTO    DOSTUFF
    MOVLW   0x37
    BTFSC   PORTB,6
    GOTO    DOSTUFF
    MOVLW   0x36
    BTFSC   PORTB,5
    GOTO    DOSTUFF
    MOVLW   0x35
    BTFSC   PORTB,4
    GOTO    DOSTUFF
    MOVLW   0x34
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    MOVLW   0x33
    BTFSC   PORTB,2
    GOTO    DOSTUFF
    MOVLW   0x32
    BTFSC   PORTB,1
    GOTO    DOSTUFF
    MOVLW   0x31
    BTFSC   PORTB,0
    GOTO    DOSTUFF
    MOVLW   0x30
    GOTO    DOSTUFF
    
    
DOSTUFF:
    ;CODE
    MOVWF   PORTC
    
    END  ;End of code. This is required.