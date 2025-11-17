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
COUNT	EQU 0X21
P1_SAVE	EQU 0X22
P2_SAVE	EQU 0X23
P3_SAVE	EQU 0X24
PCL_ADD	EQU 0X25
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
GOTO	INTERRUPT
   
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
    
    ;INTERRUPT ENABLE
    CLRF PIE1
    CLRF PIE2
    BSF	PIE1,3
    BSF	PIE1,1
    
    ;PR2
    MOVLW   100
    MOVWF   PR2
    
    ; Slave address = 0x20 ? SSPADD = 0x40
    MOVLW 0x40
    MOVWF SSPADD

    ; TRIS: RC3=SCL, RC4=SDA inputs
    CLRF TRISA
    CLRF TRISB
    MOVLW 0x18
    MOVWF TRISC

    ;BANK3
    ; Disable analog
    BSF STATUS,6    
    CLRF ANSEL
    CLRF ANSELH
    CLRF OPTION_REG
    
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
    MOVLW   0X04
    MOVWF   T2CON
    
    ;COUNT SET
    MOVLW   200
    MOVWF   COUNT
    
    ;INTERRRUPTS
    CLRF INTCON
    CLRF PIR1
    CLRF PIR2
    BSF	INTCON,7
    BSF	INTCON,6

    GOTO MAIN;</editor-fold>

    
MAIN:
   NOP
   GOTO    MAIN
    
INTERRUPT:
   BTFSC   PIR1,1
   GOTO    PWMCONTROL
   BTFSC   PIR1,3          ; SSPIF set?
   GOTO    RECEIVED
    
   RETFIE
    
//<editor-fold defaultstate="collapsed" desc="RECIVING DATA INTERRUPT">
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
   GOTO    ENDRECIVE

DATA_PHASE:
   BCF STATUS,5         ; Bank0
   BCF SSPCON,4 
   MOVF SSPBUF,0         ; read byte, clears BF
   MOVWF BUF_SAVE
   BTFSC BUF_SAVE,7 
   GOTO    P3
   BTFSC BUF_SAVE,6
   GOTO    P2
   BTFSC BUF_SAVE,5
   GOTO    P1    
   GOTO    ENDRECIVE

P1:
   BTFSC BUF_SAVE,4
   CALL	BIT4
   BTFSC BUF_SAVE,3
   CALL	BIT3
   BTFSC BUF_SAVE,2
   CALL	BIT2
   BTFSC BUF_SAVE,1
   CALL	BIT1
   BTFSC BUF_SAVE,0
   CALL	BIT0
   CALL	LOOKUP
   MOVWF    P1_SAVE
   CLRF	PCL_ADD
   GOTO	ENDRECIVE
P2:
   BTFSC BUF_SAVE,4
   CALL	BIT4
   BTFSC BUF_SAVE,3
   CALL	BIT3
   BTFSC BUF_SAVE,2
   CALL	BIT2
   BTFSC BUF_SAVE,1
   CALL	BIT1
   BTFSC BUF_SAVE,0
   CALL	BIT0
   CALL	LOOKUP
   MOVWF    P2_SAVE
   CLRF	PCL_ADD
   GOTO	ENDRECIVE
P3:
   BTFSC BUF_SAVE,4
   CALL	BIT4
   BTFSC BUF_SAVE,3
   CALL	BIT3
   BTFSC BUF_SAVE,2
   CALL	BIT2
   BTFSC BUF_SAVE,1
   CALL	BIT1
   BTFSC BUF_SAVE,0
   CALL	BIT0
   CALL	LOOKUP
   MOVWF    P3_SAVE
   CLRF	PCL_ADD
   GOTO	ENDRECIVE
//<editor-fold defaultstate="collapsed" desc="WEIGHT">
BIT4:
    MOVLW   32
    ADDWF   PCL_ADD
    RETURN
BIT3:
    MOVLW   16
    ADDWF   PCL_ADD
    RETURN
BIT2:
    MOVLW   8
    ADDWF   PCL_ADD
    RETURN
BIT1:
    MOVLW   4
    ADDWF   PCL_ADD
    RETURN
BIT0:
    MOVLW   2
    ADDWF   PCL_ADD
    RETURN   //</editor-fold>
 
//<editor-fold defaultstate="collapsed" desc="LOOKUP">
LOOKUP:
    MOVF    PCL_ADD,0
    ADDWF   PCL,1
    MOVLW   195
    RETURN
    MOVLW   195
    RETURN
    MOVLW   194
    RETURN
    MOVLW   194
    RETURN
    MOVLW   193
    RETURN
    MOVLW   192
    RETURN
    MOVLW   191
    RETURN
    MOVLW   190
    RETURN
    MOVLW   189
    RETURN
    MOVLW   188
    RETURN
    MOVLW   187
    RETURN
    MOVLW   186
    RETURN
    MOVLW   185
    RETURN
    MOVLW   184
    RETURN
    MOVLW   183
    RETURN
    MOVLW   182
    RETURN
    MOVLW   181
    RETURN
    MOVLW   180
    RETURN
    MOVLW   180
    RETURN
    MOVLW   180
    RETURN
    MOVLW   179
    RETURN
    MOVLW   179
    RETURN
    MOVLW   178
    RETURN
    MOVLW   178
    RETURN
    MOVLW   177
    RETURN
    MOVLW   177
    RETURN
    MOVLW   176
    RETURN
    MOVLW   176
    RETURN
    MOVLW   176
    RETURN
    MOVLW   175
    RETURN
    MOVLW   175
    RETURN
    MOVLW   175
    RETURN//</editor-fold>
    
ENDRECIVE:
    BCF	STATUS,5
    BCF	STATUS,6
    BCF SSPCON,6          ; clear SSPOV
    BSF SSPCON,4          ; CKP=1 release clock (ACK)
    BCF PIR1,3            ; clear SSPIF
    RETFIE
    //</editor-fold>
    
//<editor-fold defaultstate="collapsed" desc="PWM CONTROLLER CODE">
PWMCONTROL:
    MOVLW   200
    XORWF   COUNT,0
    BTFSC   STATUS,2
    CALL    SETBITS
    MOVF    P1_SAVE,0
    XORWF   COUNT,0
    BTFSC   STATUS,2
    BCF	PORTB,0
    MOVF    P2_SAVE,0
    XORWF   COUNT,0
    BTFSC   STATUS,2
    BCF	PORTB,1
    MOVF    P3_SAVE,0
    XORWF   COUNT,0
    BTFSC   STATUS,2
    BCF	PORTB,2
    DECFSZ  COUNT,1
    GOTO    ENDPWM
    GOTO    FLIP
    
SETBITS:
    BSF	PORTB,0
    BSF	PORTB,1
    BSF	PORTB,2
    RETURN
    
FLIP:
;    BCF	PORTB,0
    MOVLW   200
    MOVWF   COUNT
    GOTO    ENDPWM
    
ENDPWM:
    BCF	STATUS,5
    BCF	STATUS,6
    BCF	PIR1,1
    RETFIE//</editor-fold>

    END