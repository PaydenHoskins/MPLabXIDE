;Header Stuff
    
;Payden Hoskins
;09/08/25
;RCET3371
;Git URL
;My First Project
    
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
    ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF    0x96    ;Disables interrupton
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6
    CLRF    0x18B  ;Contrids Interupt
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6
    CLRF    0x186   ;Set Pins to output
    ClRF    0x189   ;Set input to Digital
    CLRF    0x188  ;Sets inputs to digital
    CLRF    0x181
    BSF	0x181,7
    ;BANK2
    BCF	0x03,5
    BSF	0x03,6
    CLRF    0x109 ;Sets all bits to 0
    ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF   0x95
    ;BANK0
    BCF	0x03,5
    BCF	0x03,6
    CLRF    0x17
    CLRF    0x06   ;Sets all portB outputs to 0
    ;BANK3
    BSF	0x03,5
    BSF	0x03,6
    CLRF    0x186
    ;BANK1
    BSF	0x03,5
    BCF	0x03,6
    CLRF   0x95    
    
;Main program loop (runs forever)
MainLoop:
    BCF	0x03,5
    BCF	0x03,6  ;select bank 0
    INCF    0x06, 1
    GOTO MainLoop
    
;Subs below here
;SomeSub:
    ;NOP
    ;RETURN
    
END  ;End of code. This is required.