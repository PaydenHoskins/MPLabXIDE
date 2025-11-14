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
 BUF_SAVE   EQU	0X21
 SAVE_RX    EQU 0x22
 PW_STATUS  EQU 0x23
 PS_STATUS  EQU 0x24
 PERIOD	EQU 0x25
 SKIP	EQU 0x26
 PW0	EQU 0x27
 PS0	EQU 0x28
 PW1 EQU    0X2D
 PS1 EQU    0X2E
 PW2 EQU    0X2F
 PS2 EQU    0X30
 PW EQU	0X31
 PS EQU	0X32
 RX_STATUS   EQU 0x29
 ADC_HIGH   EQU 0x2A
 ADC_LOW    EQU 0x2B
 STAT_SAVE  EQU 0x2C
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
    
    ;Set timer rollover
    MOVLW   100
    MOVWF   PR2
    
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
    
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
    
    BCF STATUS,5
    BSF	STATUS,6
    
    CLRF    CM2CON1
    
    ; Disable analog
    BSF STATUS,5
    BSF	STATUS,6
    MOVLW   0x01
    MOVWF   BAUDCTL
    CLRF ANSEL
    CLRF ANSELH
    
    CLRF    OPTION_REG
    
    CLRF PIE1
    CLRF PIE2

    ; Bank0
    BCF STATUS,5
    BCF STATUS,6
    ;EQU
    MOVLW   0x00
    MOVWF   SKIP
    MOVWF   PW_STATUS
    MOVWF   PS_STATUS
    MOVWF   ADC_LOW
    MOVWF   ADC_HIGH
    MOVLW   200
    MOVWF   PERIOD
    
    ;Turn on T2
    MOVLW   0x04
    MOVWF   T2CON
    
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
    
    BTFSC   PIR1,1
    GOTO PWORPSCHECK
    
    GOTO    MAIN
    
SERVOS:   
    BTFSC   BUF_SAVE,5
    CALL    SERVO0
    
    BTFSC   BUF_SAVE,6
    CALL    SERVO1
    
    BTFSC   BUF_SAVE,7
    CALL    SERVO2
    
    GOTO MAIN
//<editor-fold defaultstate="collapsed" desc="DATA RECIVE">
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
;    MOVWF PORTB
    BCF SSPCON,6          ; clear SSPOV
    BSF SSPCON,4          ; CKP=1 release clock (ACK)
    BCF PIR1,3            ; clear SSPIF
    RETURN//</editor-fold>

//<editor-fold defaultstate="collapsed" desc="SERVOS">
SERVO0:
    BTFSC BUF_SAVE,0
    CALL    BIT0
    BTFSC BUF_SAVE,0
    CALL    BIT1
    BTFSC BUF_SAVE,0
    CALL    BIT2
    BTFSC BUF_SAVE,0
    CALL    BIT3
    BTFSC BUF_SAVE,0
    CALL    BIT4
    
    CALL LOOKUP
    
    MOVF    PW,0
    MOVWF   PW0
    MOVF    PS,0
    MOVWF   PS0
    
    GOTO    PW0_DEC
SERVO1:
    BTFSC BUF_SAVE,0
    CALL    BIT0
    BTFSC BUF_SAVE,0
    CALL    BIT1
    BTFSC BUF_SAVE,0
    CALL    BIT2
    BTFSC BUF_SAVE,0
    CALL    BIT3
    BTFSC BUF_SAVE,0
    CALL    BIT4
    
    CALL LOOKUP
    
    MOVF    PW,0
    MOVWF   PW1
    MOVF    PS,0
    MOVWF   PS1
    
    GOTO    PW1_DEC
SERVO2:
    BTFSC BUF_SAVE,0
    CALL    BIT0
    BTFSC BUF_SAVE,0
    CALL    BIT1
    BTFSC BUF_SAVE,0
    CALL    BIT2
    BTFSC BUF_SAVE,0
    CALL    BIT3
    BTFSC BUF_SAVE,0
    CALL    BIT4
    
    CALL LOOKUP
    
    MOVF    PW,0
    MOVWF   PW2
    MOVF    PS,0
    MOVWF   PS2
    
    GOTO    PW2_DEC//</editor-fold>

    
PWORPSCHECK: 
    CLRF    PIR1
    BTFSC   PW_STATUS,0
    GOTO    PW_DEC
    BTFSC   PS_STATUS,0
    GOTO    PS_DEC
    GOTO    SERVOS
    
//<editor-fold defaultstate="collapsed" desc="PS AND PW">
PS0_DEC:
    CLRF    PIR1
    BSF	    PS_STATUS,0
    BCF	    PORTB,0
    DECFSZ  PS,1
    RETURN
    BCF	    PORTB,0
    BCF	    PS0_STATUS,0
    BSF	    PW0_STATUS,0
    RETURN
    
PS0_DEC:
    CLRF    PIR1
    BSF	    PS_STATUS,0
    BCF	    PORTB,1
    DECFSZ  PS,1
    RETURN
    BCF	    PORTB,1
    BCF	    PS1_STATUS,0
    BSF	    PW1_STATUS,0
    RETURN
    
PS0_DEC:
    CLRF    PIR1
    BSF	    PS_STATUS,0
    BCF	    PORTB,2
    DECFSZ  PS,1
    RETURN
    BCF	    PORTB,2
    BCF	    PS2_STATUS,0
    BSF	    PW2_STATUS,0
    RETURN
    
    
PW0_DEC:
    CLRF    PIR1
    BSF	    PW_STATUS,0
    BSF	    PORTB,0
    DECFSZ  PW1,1
    RETURN
    BSF	    PORTB,0
    BCF	    PW0_STATUS,0
    BSF	    PS0_STATUS,0
    GOTO    PS0_DEC
    
PW1_DEC:
    CLRF    PIR1
    BSF	    PW_STATUS,0
    BSF	    PORTB,1
    DECFSZ  PW1,1
    RETURN
    BSF	    PORTB,1
    BCF	    PW1_STATUS,0
    BSF	    PS1_STATUS,0
    GOTO    PS1_DEC
    
PW2_DEC:
    CLRF    PIR1
    BSF	    PW_STATUS,0
    BSF	    PORTB,2
    DECFSZ  PW1,1
    RETURN
    BSF	    PORTB,2
    BCF	    PW2_STATUS,0
    BSF	    PS2_STATUS,0
    GOTO    PS2_DEC//</editor-fold>
  
//<editor-fold defaultstate="collapsed" desc="WEIGHT SECTION">
BIT0:
    MOVLW   1
    ADDWF   SKIP,1
    RETURN
BIT1:
    MOVLW   2
    ADDWF   SKIP,1
    RETURN
BIT2:
    MOVLW   4
    ADDWF   SKIP,1
    RETURN
BIT3:
    MOVLW   8
    ADDWF   SKIP,1
    RETURN
BIT4:
    MOVLW   16
    ADDWF   SKIP,1
    RETURN//</editor-fold>
   
//<editor-fold defaultstate="collapsed" desc="LOOKUP">
LOOKUP:
    MOVF    SKIP,0
    ADDWF   PCL,1
    
    GOTO    MATH0
    GOTO    MATH1
    GOTO    MATH2
    GOTO    MATH3
    GOTO    MATH4
    GOTO    MATH5
    GOTO    MATH6
    GOTO    MATH7
    GOTO    MATH8
    GOTO    MATH9
    GOTO    MATH10
    GOTO    MATH11
    GOTO    MATH12
    GOTO    MATH13
    GOTO    MATH14
    GOTO    MATH15
    GOTO    MATH16
    GOTO    MATH17
    GOTO    MATH18
    GOTO    MATH19
    GOTO    MATH20
    GOTO    MATH21
    GOTO    MATH22
    GOTO    MATH23
    GOTO    MATH24
    GOTO    MATH25
    GOTO    MATH26
    GOTO    MATH27
    GOTO    MATH28
    GOTO    MATH29
    GOTO    MATH30
    GOTO    MATH31//</editor-fold>
    
//<editor-fold defaultstate="collapsed" desc="MATH">
MATH0:
    MOVLW   5
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    RETURN
MATH1:
    MOVLW   5
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    RETURN
MATH2:
    MOVLW   6
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH3:
    MOVLW   7
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH4:
    MOVLW   7
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH5:
    MOVLW   8
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH6:
    MOVLW   9
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC 
MATH7:
    MOVLW   9
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC 
MATH8:
    MOVLW   9
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC 
MATH9:
    MOVLW   10
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC 
MATH10:
    MOVLW   11
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH11:
    MOVLW   11
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC 
MATH12:
    MOVLW   12
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH13:
    MOVLW   13
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH14:
    MOVLW   13
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH15:
    MOVLW   14
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH16:
    MOVLW   14
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH17:
    MOVLW   15
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH18:
    MOVLW   16
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH19:
    MOVLW   16
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH20:
    MOVLW   17
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH21:
    MOVLW   18
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH22:
    MOVLW   18
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH23:
    MOVLW   19
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH24:
    MOVLW   20
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH25:
    MOVLW   20
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH26:
    MOVLW   21
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH27:
    MOVLW   22
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH28:
    MOVLW   22
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH29:
    MOVLW   23
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH30:
    MOVLW   24
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
MATH31:
    MOVLW   25
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC//</editor-fold>
