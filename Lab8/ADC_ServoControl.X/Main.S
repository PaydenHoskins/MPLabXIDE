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
    ADRESH_SAVE EQU 0x20
    COUNT1 EQU	0x21
    COUNT2 EQU	0x22
    PCL_ADD EQU	0x23
 
    ;Start of Program
    PSECT resetVect,class=CODE,delta=2
	GOTO START
    
    PSECT isrVect,class=CODE,delta=2
	GOTO INTERRUPT
    
    PSECT code,class=CODE,delta=2
    ;Setup code that runs once at power up/ reset
 
    ;PORT SETUP
START:
    ;BANK0
    BCF	STATUS,5
    BCF	STATUS,6
    CLRF    PIR1
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    T1CON
    MOVLW   0x26
    MOVWF   T2CON
    CLRF    CCP1CON
    CLRF    CCP2CON
    MOVLW   0x43
    MOVWF   ADCON0
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    
    ;BANK1
    BSF	    STATUS,5
    CLRF    ADCON1
    CLRF    TRISA
    BSF	    TRISA,0
    CLRF    TRISB
    BSF	    TRISB,1
    BSF	    TRISB,0
    CLRF    TRISC
    MOVLW   0x02
    MOVWF   PIE1
    CLRF    PSTRCON
    
    ;BANK2
    BSF     STATUS,6
    BCF	    STATUS,5
    CLRF    CM2CON1
    
    ;BANK3
    BSF	    STATUS,6
    BSF	    STATUS,5
    CLRF    ANSELH
    CLRF    ANSEL
    BSF	    ANSEL,0

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
    BSF	    ADCON0,1
    BSF	    ADCON0,0
    MOVF    ADRESH,0
    BCF	    PORTC,0
    GOTO    MAIN
    
    INTERRUPT:
    CLRF    PIR1
    BSF	    PORTC,0
    MOVF    ADRESH,0
    MOVWF   ADRESH_SAVE
    CALL    CONVERSION
    MOVWF   COUNT2
    LOOP2:
    MOVLW   0x02	;
    MOVWF   COUNT1
    LOOP1:
    DECFSZ  COUNT1	;+1(2)
    GOTO    LOOP1	;+2
    DECFSZ  COUNT2	;+1(2)
    GOTO    LOOP2	;+2
    BCF	PORTC,0
    CLRF    PCL_ADD
    RETFIE
    
    
    CONVERSION:
    BTFSC   ADRESH_SAVE,7
    CALL    BIT7
    BTFSC   ADRESH_SAVE,6
    CALL    BIT6
    BTFSC   ADRESH_SAVE,5
    CAll    BIT5
    BTFSC   ADRESH_SAVE,4
    CALL    BIT4
    BTFSC   ADRESH_SAVE,3
    CALL    BIT3
    GOTO    LOOKUP
    
    BIT7:
    MOVLW   32
    ADDWF   PCL_ADD
    RETURN
    BIT6:
    MOVLW   16
    ADDWF   PCL_ADD
    RETURN
    BIT5:
    MOVLW   8
    ADDWF   PCL_ADD
    RETURN
    BIT4:
    MOVLW   4
    ADDWF   PCL_ADD
    RETURN
    BIT3:
    MOVLW   2
    ADDWF   PCL_ADD
    RETURN
    
    LOOKUP:
    MOVF    PCL_ADD,0
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
    RETURN
    END
    