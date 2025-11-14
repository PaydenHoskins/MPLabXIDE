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
 BUF_SAVE   EQU	0X20
 POT1	EQU 0X21
 POT2	EQU 0X22
 POT3	EQU 0X23
 PCL_ADD1   EQU	0X24
 PCL_ADD2   EQU	0X25
 PCL_ADD3   EQU	0X26
 COUNT1 EQU 0x27
 COUNT2 EQU 0x28
 COUNT3	EQU 0X29
 COUNT4	EQU 0X2A
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
GOTO INTERRUPT    
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
    MOVLW 0x40
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
    
    MOVLW   0X02
    MOVWF   PIE1
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
    
    ;TIMER2
    MOVLW   0X26
    MOVWF   T2CON
    
    ;INTERRUPTS
    CLRF PIR1
    CLRF PIR2
    MOVLW   0XC0
    MOVWF INTCON
    
    GOTO MAIN;</editor-fold>

    
    
MAIN:
    BTFSC   PIR1,3
    CALL    SERVOSTUFF
    BSF	INTCON,7
    GOTO MAIN
    
INTERRUPT:
    BTFSC   PIR1,1
    CALL    TIMER
    RETFIE
    
TIMER:
    CALL    DEC1
    CALL    DEC2
    CALL    DEC3
    RETFIE
   
    
SERVOSTUFF:
    BCF	INTCON,7
    CALL RECEIVED
    BTFSS   PIR1,3
    GOTO    $-1
    CALL RECEIVED
    CALL RECEIVED
    BTFSC   BUF_SAVE,5
    CALL   POT1SETUP
    BTFSC   BUF_SAVE,6
    CALL   POT2SETUP
    BTFSC   BUF_SAVE,7
    CALL   POT3SETUP
    RETURN
    
//<editor-fold defaultstate="collapsed" desc="I2C">
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
    BCF SSPCON,6          ; clear SSPOV
    BSF SSPCON,4          ; CKP=1 release clock (ACK)
    BCF PIR1,3            ; clear SSPIF
    MOVF    BUF_SAVE,0
    RETURN//</editor-fold>
 
//<editor-fold defaultstate="collapsed" desc="POT1">
POT1SETUP:
    MOVWF   POT1
    BTFSC   POT1,4
    CALL    BIT4
    ADDWF   PCL_ADD1
    BTFSC   POT1,3
    CALL    BIT3
    ADDWF   PCL_ADD1
    BTFSC   POT1,3
    CAll    BIT2
    ADDWF   PCL_ADD1
    BTFSC   POT1,1
    CALL    BIT1
    ADDWF   PCL_ADD1
    BTFSC   POT1,0
    CALL    BIT0
    ADDWF   PCL_ADD1
    MOVF    PCL_ADD3,0
    CALL    LOOKUP
    MOVWF   COUNT2
    RETURN
    //</editor-fold>
    
//<editor-fold defaultstate="collapsed" desc="POT2">
POT2SETUP:
    MOVWF   POT2
    BTFSC   POT2,4
    CALL    BIT4
    ADDWF   PCL_ADD2
    BTFSC   POT2,3
    CALL    BIT3
    ADDWF   PCL_ADD2
    BTFSC   POT2,3
    CAll    BIT2
    ADDWF   PCL_ADD2
    BTFSC   POT2,1
    CALL    BIT1
    ADDWF   PCL_ADD2
    BTFSC   POT2,0
    CALL    BIT0
    ADDWF   PCL_ADD2
    MOVF    PCL_ADD2,0
    CALL    LOOKUP
    MOVWF   COUNT3
    RETURN
    //</editor-fold>    
    
//<editor-fold defaultstate="collapsed" desc="POT3">
POT3SETUP:
    MOVWF   POT3
    BTFSC   POT3,4
    CALL    BIT4
    ADDWF   PCL_ADD3
    BTFSC   POT3,3
    CALL    BIT3
    ADDWF   PCL_ADD3
    BTFSC   POT3,3
    CAll    BIT2
    ADDWF   PCL_ADD3
    BTFSC   POT3,1
    CALL    BIT1
    ADDWF   PCL_ADD3
    BTFSC   POT3,0
    CALL    BIT0
    ADDWF   PCL_ADD3
    MOVF    PCL_ADD3,0
    CALL    LOOKUP
    MOVWF   COUNT4
    RETURN
    //</editor-fold>
  
//<editor-fold defaultstate="collapsed" desc="WEIGHT">
BIT4:
    MOVLW   32
    RETURN
BIT3:
    MOVLW   16
    RETURN
BIT2:
    MOVLW   8
    RETURN
BIT1:
    MOVLW   4
    RETURN
BIT0:
    MOVLW   2
    RETURN//</editor-fold>

//<editor-fold defaultstate="collapsed" desc="LOOKUP">
LOOKUP:
    ADDWF   PCL,1
    MOVLW   55
    RETURN
    MOVLW   62
    RETURN
    MOVLW   69
    RETURN
    MOVLW   76
    RETURN
    MOVLW   83
    RETURN
    MOVLW   90
    RETURN
    MOVLW   97
    RETURN
    MOVLW   104
    RETURN
    MOVLW   111
    RETURN
    MOVLW   118
    RETURN
    MOVLW   125
    RETURN
    MOVLW   132
    RETURN
    MOVLW   139
    RETURN
    MOVLW   146
    RETURN
    MOVLW   153
    RETURN
    MOVLW   160
    RETURN
    MOVLW   167
    RETURN
    MOVLW   174
    RETURN
    MOVLW   181
    RETURN
    MOVLW   188
    RETURN
    MOVLW   195
    RETURN
    MOVLW   205
    RETURN
    MOVLW   211
    RETURN
    MOVLW   217
    RETURN
    MOVLW   222
    RETURN
    MOVLW   228
    RETURN
    MOVLW   228
    RETURN
    MOVLW   228
    RETURN
    MOVLW   228
    RETURN//</editor-fold>
  
    DEC1:
    MOVWF   COUNT2
    BSF	PORTB,0
    LOOP2:
    MOVLW   0x02	;
    MOVWF   COUNT1
    LOOP1:
    DECFSZ  COUNT1	;+1(2)
    GOTO    LOOP1	;+2
    DECFSZ  COUNT2	;+1(2)
    GOTO    LOOP2	;+2
    BCF	PORTB,0
    CLRF    PCL_ADD1
    RETURN
    
    DEC2:
    MOVWF   COUNT3
    BSF	PORTB,1
    LOOP4:
    MOVLW   0x02	;
    MOVWF   COUNT1
    LOOP3:
    DECFSZ  COUNT1	;+1(2)
    GOTO    LOOP3	;+2
    DECFSZ  COUNT3	;+1(2)
    GOTO    LOOP4	;+2
    BCF	PORTB,1
    CLRF    PCL_ADD2
    RETURN
    
    DEC3:
    MOVWF   COUNT4
    BSF	PORTB,2
    LOOP6:
    MOVLW   0x02	;
    MOVWF   COUNT1
    LOOP5:
    DECFSZ  COUNT1	;+1(2)
    GOTO    LOOP5	;+2
    DECFSZ  COUNT4	;+1(2)
    GOTO    LOOP6	;+2
    BCF	PORTB,2
    CLRF    PCL_ADD3
    RETURN
    
    END