; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

#include "p16f883.inc"

; CONFIG1
; __config 0xE0F1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 ;Code Section
;-------------------------------------------------------------------------------
    
;Register/Variable setup
    SOMEVALUE EQU 0x5f ; asign a value to a  variable
    
;Start of Program
    ORG 0x0000           ;Reset vector address
    GOTO START
    ORG 0x0004
    RETFIE
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