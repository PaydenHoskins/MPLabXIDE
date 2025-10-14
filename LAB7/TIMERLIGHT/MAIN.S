;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;09/25/25
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
    SOMEVALUE EQU 0x5f ; asign a value to a  variable
    
    ;Start of Program
    PSECT resetVect,class=CODE,delta=2
	GOTO START
    
    PSECT isrVect,class=CODE,delta=2
	GOTO INTERUPT
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    BCF	STATUS, 5
    BCF	STATUS, 6
    CAR1    EQU	0x20
    CAR2    EQU	0x21
    CAR3    EQU	0x22
    NSG	EQU 0x23
    NSY	EQU 0x24
    ADD2    EQU 0x25
    EWG	EQU 0x26
    EWY	EQU 0x27
    EWR	EQU 0x28
    ADD	EQU 0x29
    NSRR    EQU 0x2A
    EWRR    EQU 0x2B
    NSC	EQU 0x2C
    EWC	EQU 0x2D
   ; NSCC    EQU	0x2E
   ; EWCC    EQU	0x2F
    ; BANK1: TRIS setup

    BSF     STATUS,5
    BCF     STATUS,6
    MOVLW   0x02
    MOVWF    PIE1
    CLRF    PSTRCON
    MOVLW   0x03        ; 0,1 PORTB = inputs
    MOVWF   TRISB
    CLRF    TRISC        ; all PORTC = outputs
    MOVLW   0x00
    MOVWF   IOCB
    CLRF    WPUB
    
    ; BANK0: clear peripherals + I/O
    BCF     STATUS,5
    BCF     STATUS,6
    CLRF    PIR1
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    T1CON
    MOVLW   0x56
    MOVWF   T2CON
    CLRF    CCP1CON
    CLRF    CCP2CON
    MOVLW   0x00
    MOVWF   PORTB
    MOVLW   0x00
    MOVWF   PORTC
    MOVLW   109
    MOVWF   NSG
    ;MOVWF   NSR
    MOVWF   EWG
    MOVWF   EWR
    MOVLW   22
    MOVWF   NSY
    MOVWF   EWY
    MOVWF   NSRR
    MOVWF   EWRR
    CLRF    ADD


    ; BANK2: disable comparators
    BSF     STATUS,6
    CLRF    CM2CON1
    BCF     STATUS,6     ; back to Bank0

    ; BANK3: digital mode
    BSF     STATUS,5
    BSF     STATUS,6    
    CLRF    ANSELH
    CLRF    ANSEL    

    ; BANK0: OPTION + interrupts
    BCF     STATUS,5
    BCF     STATUS,6
    MOVLW   0x00
    MOVWF   OPTION_REG
    MOVLW   0xC0
    MOVWF   INTCON
    BCF     INTCON,0     ; clear RBIF
    GOTO    MAIN
    
    MAIN:
    BTFSC   PORTB,0
    BSF	CAR1,0
    BTFSC   PORTB,1
    BSF	CAR2,0
    MOVLW   109
    BTFSC    PORTB,0
    MOVWF   NSC
    MOVLW   109
    BTFSC   PORTB,1
    MOVWF   EWC
    GOTO MAIN
    
//    INCTEST:
//    MOVLW   0x13
//    ADDWF   EWC,0
//    MOVWF   EWCC
//    BTFSC   EWCC,7
//    INCF    EWC
//    GOTO    MAIN
//    
//    INCTEST0:
//    MOVLW   0x13
//    ADDWF   NSC,0
//    MOVWF   NSCC
//    BTFSC   NSCC,7
//    INCF    NSC
//    GOTO    MAIN
    
    INTERUPT:
    CLRF    PIR1
    MOVF    ADD2,0
    ADDWF   PCL,1
    MOVF    CAR2,0
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    GOTO    BOTH
    BTFSC   CAR1,0
    GOTO    NSDIR
    BTFSC   CAR2,0
    GOTO    EWDIR
    GOTO    BOTH
    
    NSDIR:
    MOVLW   6
    MOVWF   ADD2
    MOVF    CAR2,0
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    CLRF    ADD2
    CLRF    PIR1
    MOVF    ADD,0
    ADDWF   PCL,1
    MOVLW   0x81
    MOVWF   PORTC
    DECFSZ  NSC
    RETFIE
    MOVLW   0x04
    MOVWF   ADD
    MOVLW   0x82
    MOVWF   PORTC
    DECFSZ  NSY
    RETFIE
    MOVLW   0x0A
    MOVWF   ADD
    MOVLW   0x84
    MOVWF   PORTC
    DECFSZ  NSRR
    RETFIE
    GOTO    RECOUNT2
    
    EWDIR:
    MOVLW   8
    MOVWF   ADD2
    MOVF    CAR2,0
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    CLRF    ADD2
    MOVF    ADD,0
    ADDWF   PCL,1
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVLW   0x10
    MOVWF   ADD
    MOVLW   0x24
    MOVWF   PORTC
    DECFSZ  EWC
    RETFIE
    MOVLW   0x16
    MOVWF   ADD
    MOVLW   0x44
    MOVWF   PORTC
    DECFSZ  EWY
    RETFIE
    MOVLW   0x1C
    MOVWF   ADD
    MOVLW   0x84
    MOVWF   PORTC
    DECFSZ  EWRR
    RETFIE
    GOTO    RECOUNT
    
    BOTH:
    MOVLW   4
    MOVWF   ADD2
    CLRF    PIR1
    MOVF    ADD,0
    ADDWF   PCL,1
    MOVLW   0x81
    MOVWF   PORTC
    DECFSZ  NSG
    RETFIE
    MOVLW   0x04
    MOVWF   ADD
    MOVLW   0x82
    MOVWF   PORTC
    DECFSZ  NSY
    RETFIE
    MOVLW   0x0A
    MOVWF   ADD
    MOVLW   0x84
    MOVWF   PORTC
    DECFSZ  NSRR
    RETFIE
    CLRF    CAR1
    BTFSC   CAR2,0
    CLRF    ADD2
    MOVLW   0x10
    MOVWF   ADD
    MOVLW   0x24
    MOVWF   PORTC
    DECFSZ  EWG
    RETFIE
    MOVLW   0x19
    MOVWF   ADD
    MOVLW   0x44
    MOVWF   PORTC
    DECFSZ  EWY
    RETFIE
    MOVLW   0x1F
    MOVWF   ADD
    MOVLW   0x84
    MOVWF   PORTC
    DECFSZ  EWRR
    RETFIE
    GOTO    RECOUNT
    
    
    RECOUNT:
    MOVLW   109
    MOVWF   NSG
    ;MOVWF   NSR
    MOVWF   EWG
    MOVWF   EWR
    MOVLW   22
    MOVWF   NSRR
    MOVWF   EWRR
    MOVWF   NSY
    MOVWF   EWY
    CLRF    ADD
    CLRF    CAR1
    CLRF    CAR2
    CLRF    CAR3
    CLRF    ADD2
    RETFIE
    
    RECOUNT2:
    MOVLW   109
    MOVWF   NSG
    ;MOVWF   NSR
    MOVWF   EWG
    MOVWF   EWR
    MOVLW   22
    MOVWF   NSRR
    MOVWF   EWRR
    MOVWF   NSY
    MOVWF   EWY
    MOVLW   0x10
    MOVWF    ADD
    CLRF    CAR1
    CLRF    CAR2
    CLRF    CAR3
    CLRF    ADD2
    RETFIE
    
    END
    
    