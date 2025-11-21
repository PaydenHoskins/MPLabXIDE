;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;11/20/25
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
 BUF_SAVE   EQU	0X20
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
    
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
;<editor-fold defaultstate="collapsed" desc="STARTUP CODE.">
START:
; Bank1
    BSF STATUS,5
    BCF STATUS,6
    MOVLW 0X01
    MOVWF SSPCON2
    
    MOVLW 0x80
    MOVWF SSPSTAT

    ; Slave address = 0x20 ? SSPADD = 0x40
    MOVLW 0xAA
    MOVWF SSPADD

    ; TRIS: RC3=SCL, RC4=SDA inputs
    CLRF TRISA
    CLRF TRISB
    MOVLW 0x18
    MOVWF TRISC

    ; Disable analog
    BSF STATUS,5
    CLRF ANSEL
    CLRF ANSELH
    
    CLRF    OPTION_REG
    
    CLRF PIE1
    CLRF PIE2

    ; Bank0
    BCF STATUS,5
    BCF STATUS,6

    ; SSPCON: I2C Slave mode, 7-bit address, SSPEN=1
    MOVLW 0x36
    MOVWF SSPCON

    CLRF PORTA
    CLRF PORTB
    CLRF PORTC

    CLRF INTCON
    CLRF PIR1
    CLRF PIR2

    GOTO MAIN;</editor-fold>

    
    
MAIN:
    BTFSC PIR1,3          ; SSPIF set?
    CALL RECEIVED
    GOTO MAIN
    
RECEIVED:
    ; Check D_A bit (SSPSTAT<5>): 0=Address, 1=Data
    BSF STATUS,5          ; Bank1
    BTFSS SSPSTAT,5
    GOTO ADDRESS_PHASE
    GOTO DATA_PHASE

ADDRESS_PHASE:
    BCF STATUS,5          ; Bank0
    BCF SSPCON,4 
    MOVF SSPBUF,0         ; dummy read clears BF
    BCF SSPCON,6          ; clear SSPOV
    BSF SSPCON,4          ; CKP=1 release clock
    BCF PIR1,3            ; clear SSPIF
    RETURN

DATA_PHASE:
    BCF STATUS,5         ; Bank0
    BCF SSPCON,4 
    MOVF SSPBUF,0         ; read byte, clears BF
    MOVWF BUF_SAVE
    MOVWF PORTB
    BCF SSPCON,6          ; clear SSPOV
    BSF SSPCON,4          ; CKP=1 release clock (ACK)
    BCF PIR1,3            ; clear SSPIF
    RETURN