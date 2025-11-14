;Header
    ;Payden Hoskins
    ;RCET3375
    ;LAB6
    ;10/13/25
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
    SAVE_RX	EQU 0x28
    PW_STATUS	EQU 0x21
    PS_STATUS	EQU 0x22
    PERIOD	EQU 0x23
    SKIP	EQU 0x24
    PW		EQU 0x25
    PS		EQU 0x26
    RX_STATUS   EQU 0x27
    ADC_HIGH	EQU 0x2B
    ADC_LOW	EQU 0x20
    STAT_SAVE	EQU 0x2A
 
    ;Start of Program
    PSECT resetVect,class=CODE,delta=2
	GOTO START
    
    PSECT isrVect,class=CODE,delta=2
	GOTO INTERRUPT
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    CLRF   INTCON
    BCF	STATUS,5
    BCF	STATUS,6
    MOVLW   0x00
    MOVWF   SKIP
    MOVWF   PW_STATUS
    MOVWF   PS_STATUS
    MOVWF   ADC_LOW
    MOVWF   ADC_HIGH
    MOVLW   200
    MOVWF   PERIOD
    ;BANK1
    BSF	STATUS,5
    ;Right justify ADC1
    MOVLW   0x80
    MOVWF   ADCON1
    ;Set timer rollover
    MOVLW   100
    MOVWF   PR2
    ;Setup transmit
    CLRF   TXSTA
    MOVLW   0x26
    MOVWF   TXSTA
    ;Enable pin 1 input
    MOVLW   0x01
    MOVWF   TRISA
    ;CLR TRISB
    CLRF    TRISB
    ;CLR TRISC
    CLRF    TRISC
    ;Enable Specific int flags
    MOVLW   0x22
    MOVWF   PIE1
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
    
    ;BANK2
    BCF	STATUS,5
    BSF	STATUS,6
    CLRF    CM2CON1
    
    ;BANK3
    BSF	STATUS,5
    ;Set up baud rate
    MOVLW   0x01
    MOVWF   BAUDCTL
    CLRF    ANSELH
    CLRF    ANSEL
    BSF	    ANSEL,0
    
    ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    ;Turn on ADC
    MOVLW   0x43
    MOVWF   ADCON0
    ;Turn on T2
    MOVLW   0x04
    MOVWF   T2CON
    ;BSF	   T2CON,2
    ;Setup Recive
    CLRF   RCSTA
    MOVLW   0x90
    MOVWF   RCSTA
    ;CLR Ports
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    ;ENABLE INTERRUPTS
    CLRF    PIR1
    MOVLW   0xC0
    MOVWF   INTCON
    BCF	    STATUS,2
    BSF	    ADCON0,0
    CLRF    PIR1
    BSF	    ADCON0,1
    GOTO    MAIN
      
    MAIN:  
    BTFSC   ADCON0,1
    GOTO    $-1
    MOVF    ADRESH,0  
    MOVWF   ADC_HIGH
    BSF	    STATUS,5
    MOVF    ADRESL,0
    BCF	    STATUS,5
    MOVWF   ADC_LOW
    BSF	    ADCON0,1
    GOTO    MAIN
    
    TRANSMIT:
    BSF	    RX_STATUS,0
    MOVLW   0x24
    MOVWF   TXREG 
    CLRF    PIR1
    RETFIE
    
    TRANSMIT_ADC:
    MOVF    ADC_HIGH,0
    MOVWF   TXREG 
    CLRF    ADC_HIGH  
    BTFSS   PIR1,4
    GOTO    $-1
    MOVF    ADC_LOW,0
    MOVWF   TXREG 
    CLRF    ADC_LOW
    CLRF    PIR1
    RETFIE
    
    INTERRUPT: 
    MOVF    STATUS,0
    MOVWF   STAT_SAVE
    BTFSC   PIR1,5
    GOTO    INTERRUPT_RECIVE
    BTFSC   PIR1,1
    GOTO    INTERRUPT_TIMER
    
    
    INTERRUPT_RECIVE:
    MOVF    RCREG,0
    MOVWF   SAVE_RX
    MOVF    SAVE_RX,0
    XORLW   36
    BTFSC   STATUS,2
    GOTO    TRANSMIT
    MOVF    SAVE_RX,0
    XORLW   33
    BTFSC   STATUS,2
    GOTO    TRANSMIT_ADC
    BTFSS   STATUS,2
    GOTO    SERVO
    CLRF    PIR1
    MOVF    STAT_SAVE,0
    MOVWF   STATUS
    RETFIE
    
    SERVO:
    MOVLW   0
    BTFSS   RX_STATUS,0
    MOVLW   15
    ADDWF   PCL,1
    CLRF    SKIP
    BTFSC   SAVE_RX,0
    CALL    BIT0
    BTFSC   SAVE_RX,1
    CALL    BIT1
    BTFSC   SAVE_RX,2
    CALL    BIT2
    BTFSC   SAVE_RX,3
    CALL    BIT3
    BTFSC   SAVE_RX,4
    CALL    BIT4 
    BCF	    RX_STATUS,0
    CLRF    PIR1
    CLRF    PIR1
    MOVF    STAT_SAVE,0
    MOVWF   STATUS
    RETFIE
    
    INTERRUPT_TIMER:
    CLRF    PIR1
    BTFSC   PW_STATUS,0
    GOTO    PW_DEC
    BTFSC   PS_STATUS,0
    GOTO    PS_DEC
    
    MOVF    SKIP,0
    ADDWF   PCL,1
    
    MOVLW   5
    GOTO    MATH
    MOVLW   6
    GOTO    MATH
    MOVLW   7
    GOTO    MATH
    MOVLW   8
    GOTO    MATH
    MOVLW   9
    GOTO    MATH
    MOVLW   10
    GOTO    MATH
    MOVLW   11
    GOTO    MATH
    MOVLW   12
    GOTO    MATH
    MOVLW   13
    GOTO    MATH
    MOVLW   14
    GOTO    MATH
    MOVLW   15
    GOTO    MATH
    MOVLW   16
    GOTO    MATH
    MOVLW   17
    GOTO    MATH
    MOVLW   18
    GOTO    MATH
    MOVLW   19
    GOTO    MATH
    MOVLW   20
    GOTO    MATH
    MOVLW   21
    GOTO    MATH
    MOVLW   22
    GOTO    MATH
    MOVLW   23
    GOTO    MATH
    MOVLW   24
    GOTO    MATH
    MOVLW   25
    GOTO    MATH
//    
//    
    PS_DEC:
    CLRF    PIR1
    BSF	    PS_STATUS,0
    BCF	    PORTA,1
    DECFSZ  PS,1
    RETFIE
    BCF	    PORTA,1
    BCF	    PS_STATUS,0
    MOVF    STAT_SAVE,0
    MOVWF   STATUS
    RETFIE
    
    
    PW_DEC:
    CLRF    PIR1
    BSF	    PW_STATUS,0
    BSF	    PORTA,1
    DECFSZ  PW,1
    RETFIE
    BSF	    PORTA,1
    BCF	    PW_STATUS,0
    BSF	    PS_STATUS,0
    GOTO    PS_DEC
//    
//    
    MATH:
    MOVWF   PW
    MOVF    PW,0
    SUBWF   PERIOD,0
    MOVWF   PS
    GOTO    PW_DEC
//     
//    
    BIT0:
    MOVLW   2
    ADDWF   SKIP,1
    RETURN
    BIT1:
    MOVLW   4
    ADDWF   SKIP,1
    RETURN
    BIT2:
    MOVLW   8
    ADDWF   SKIP,1
    RETURN
    BIT3:
    MOVLW   16
    ADDWF   SKIP,1
    RETURN
    BIT4:
    MOVLW   32
    ADDWF   SKIP,1
    RETURN
