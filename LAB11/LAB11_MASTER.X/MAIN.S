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
POT0 EQU   0X20
POT1 EQU   0X21
POT2 EQU   0X22
COUNT	EQU 0X23
POTCOUNT    EQU	0X24
WRITEDAT    EQU	0X25
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
    
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
//<editor-fold defaultstate="collapsed" desc="SETUP">
START:
;BANK1
    BSF STATUS,5
    BCF STATUS,6
;A/D
    MOVLW   0X00
    MOVWF   ADCON1
;SSPCON2&SSPSTAT
    MOVLW	0x00
    MOVWF	SSPCON2
    MOVLW	0x80
    MOVWF	SSPSTAT
;TRIS SETS
    MOVLW   0X07
    MOVWF   TRISA
    CLRF   TRISB
    BSF	TRISB,7
    MOVLW   0x18
    MOVWF   TRISC
;PIE SETUP
    MOVLW	0x08
    MOVWF	PIE1
    MOVLW	0x08
    MOVWF	PIE2
;PCON
    CLRF	PCON
;WPUB
    CLRF	WPUB
;IOCB
    CLRF	IOCB
;BAUD RATE
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
;BANK2
    BCF STATUS,5
    BSF STATUS,6

;BANK3
    BSF STATUS,5
    MOVLW   0X07
    MOVWF	ANSEL
    CLRF	ANSELH
;BANK0
    BCF STATUS,5
    BCF STATUS,6
;EQU
    MOVLW   0X01
    MOVWF    POTCOUNT
;MCCP
    MOVLW	0x28
    MOVWF	SSPCON
;PORT'S
    CLRF	PORTA
    CLRF	PORTB
    CLRF	PORTC
;TIMER'S1&2
    CLRF	T1CON
    CLRF	T2CON
;INTCON
    CLRF	INTCON
;A/D 
    MOVLW   0X03
    MOVWF   ADCON0
    GOTO	MAIN//</editor-fold>

    
    
MAIN:
    BTFSS   ADCON0,1
    CALL POTREADCHECK
    GOTO    MAIN
    
TRANSMIT:
    BSF STATUS,5    ;BANK1
    BSF	SSPCON2,0   ;START CONDITION
    
    BCF STATUS,5    ;BANK0
    BTFSS  PIR1,3   ;WAIT FOR START TO FINISH
    GOTO    $-1
    BCF	PIR1,3

    //<editor-fold defaultstate="collapsed" desc="SEND ADDRESS">
    MOVLW   0X40
    MOVWF   SSPBUF
    
    BSF	STATUS,5    ;BANK1
BITFULLTEST:
    BTFSC   SSPSTAT,0	;TEST BUFFER FULL BIT
    GOTO    BITFULLTEST
    
    BCF	STATUS,5
    BCF	PIR1,3
    BSF	STATUS,5
    
CHECKACK:
    BTFSC   SSPCON2,6	;CHECK FOR ACK STATUS
    GOTO CHECKACK
    
    
    BCF	STATUS,5
    BCF	PIR1,3
    BSF	STATUS,5
    //</editor-fold>
    
    //<editor-fold defaultstate="collapsed" desc="SEND DATA BYTE1">
    BCF	STATUS,5
    ;USE POTCOUNT TO DETERMINE SENT VALUE
    
//<editor-fold defaultstate="collapsed" desc="POT DATA SELECT">
    MOVLW   0X01
    ;CHECK FOR VALUE 0 IN POTCOUNT, IF IT IS 0 THEN START ADC0 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEDATPOT0
    
    MOVLW   0X02
    ;CHECK FOR VALUE 1 IN POTCOUNT, IF IT IS 1 THEN START ADC1 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEDATPOT1
    
    MOVLW   0X03
    ;CHECK FOR VALUE 2 IN POTCOUNT, IF IT IS 2 THEN START ADC2 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEDATPOT2//</editor-fold>

WRITESEQ:
    MOVWF   SSPBUF
    BSF	STATUS,5    ;BANK1
BFTEST:
    BTFSC   SSPSTAT,0	;TEST BUFFER FULL BIT
    GOTO    BFTEST    
    
    BCF	STATUS,5
    BCF	PIR1,3
    BSF	STATUS,5
    

NACKPROTECTION: 
    MOVLW   0X01
    ADDWF   COUNT
    MOVLW   0X07
    XORWF   COUNT,0
    BTFSC   STATUS,2
    GOTO    STOPSEQ
CHECKACK2:
    BTFSC   SSPCON2,6	;CHECK FOR ACK STATUS
    GOTO    NACKPROTECTION     
    
    BCF	STATUS,5
    BCF	PIR1,3
    BSF	STATUS,5
    //</editor-fold>
    
STOPSEQ:    
    BSF	SSPCON2,2	;START THE STOP SEQUENCE
    
    BCF	STATUS,5
    BTFSS   PIR1,3	; WAIT FOR FLAG THAT SAYS THE STOP SEQUENCE IS DONE
    GOTO    $-1
    BCF	PIR1,3

    RETURN
    
//<editor-fold defaultstate="collapsed" desc="CHECK WHAT POT">
POTREADCHECK:
    MOVLW   0X01
    ;CHECK FOR VALUE 0 IN POTCOUNT, IF IT IS 0 THEN START ADC0 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEPOT0
    
    MOVLW   0X02
    ;CHECK FOR VALUE 2 IN POTCOUNT, IF IT IS 1 THEN START ADC1 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEPOT1

    
    MOVLW   0X03
    ;CHECK FOR VALUE 2 IN POTCOUNT, IF IT IS 2 THEN START ADC2 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    WRITEPOT2//</editor-fold>

    
ADCONVERTERSEND:    
    CALL TRANSMIT
    INCF    POTCOUNT,1

CHANGEADC:
    MOVLW   0X04
    ;CHECK FOR VALUE 3 IN POTCOUNT, IF IT IS 3 THEN RESET TO 0
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    CALL    SETTO1
    
//<editor-fold defaultstate="collapsed" desc="ADC CHECK">
    MOVLW   0X01
    ;CHECK FOR VALUE 0 IN POTCOUNT, IF IT IS 0 THEN START ADC0 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADCONCHANGE
    
    MOVLW   0X02
    ;CHECK FOR VALUE 1 IN POTCOUNT, IF IT IS 1 THEN START ADC1 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADCONCHANGE
    
    MOVLW   0X03
    ;CHECK FOR VALUE 2 IN POTCOUNT, IF IT IS 2 THEN START ADC2 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADCONCHANGE
    //</editor-fold>

RESTART:
    BCF	PIR1,6
    BSF	ADCON0,1
    RETURN

SETTO1:
    MOVLW   0X01
    MOVWF   POTCOUNT
    RETURN
    
//<editor-fold defaultstate="collapsed" desc="IS EVERYTHING DONE">
I2CIDLE:
    BSF STATUS,5
    MOVLW	0x1F
    ANDWF	SSPCON2,0
    BTFSC	STATUS,2
    RETURN
    GOTO	I2CIDLE//</editor-fold>
   
//<editor-fold defaultstate="collapsed" desc="SAVE POT VALUES">
WRITEPOT0:
    MOVF    ADRESH,0
    MOVWF   POT0
    BCF    STATUS,0
    RRF	POT0
    BCF    STATUS,0
    RRF	POT0
    BCF    STATUS,0
    RRF	POT0
    BCF    STATUS,0
    MOVLW   0X20
    ADDWF   POT0,1
    GOTO    ADCONVERTERSEND
    
WRITEPOT1:
    MOVF    ADRESH,0
    MOVWF   POT1
    BCF    STATUS,0
    RRF	POT1
    BCF    STATUS,0
    RRF	POT1
    BCF    STATUS,0
    RRF	POT1
    BCF    STATUS,0
    MOVLW   0X40
    ADDWF   POT1,1
    GOTO    ADCONVERTERSEND
    
WRITEPOT2:
    MOVF    ADRESH,0
    MOVWF   POT2
    BCF    STATUS,0
    RRF	POT2
    BCF    STATUS,0
    RRF	POT2
    BCF    STATUS,0
    RRF	POT2
    BCF    STATUS,0
    MOVLW   0X80
    ADDWF   POT2,1
    GOTO    ADCONVERTERSEND//</editor-fold>

//<editor-fold defaultstate="collapsed" desc="ADCCHANGE">
ADCONCHANGE:
    MOVLW   0X01
    ;CHECK FOR VALUE 0 IN POTCOUNT, IF IT IS 0 THEN START ADC0 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADC0
    
    MOVLW   0X02
    ;CHECK FOR VALUE 1 IN POTCOUNT, IF IT IS 1 THEN START ADC1 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADC1
    
    MOVLW   0X03
    ;CHECK FOR VALUE 2 IN POTCOUNT, IF IT IS 2 THEN START ADC2 CONVERSION
    XORWF   POTCOUNT,0
    BTFSC   STATUS,2
    GOTO    ADC2
    
MOVETOADCON:
    MOVWF   ADCON0
    GOTO    RESTART//</editor-fold>
    
//<editor-fold defaultstate="collapsed" desc="MOVE POT DATA TO WRITE REG">
WRITEDATPOT0:
    MOVF    POT0,0
    MOVWF   WRITEDAT
    GOTO    WRITESEQ
    
WRITEDATPOT1:
    MOVF    POT1,0
    MOVWF   WRITEDAT
    GOTO    WRITESEQ
    
WRITEDATPOT2:
    MOVF    POT2,0
    MOVWF   WRITEDAT
    GOTO    WRITESEQ//</editor-fold>

    
//<editor-fold defaultstate="collapsed" desc="CHANGE THE ADCON0 SETUP">
ADC0:
    MOVLW   0X01
    MOVWF   ADCON0
    GOTO    MOVETOADCON
ADC1:
    MOVLW   0X05
    MOVWF   ADCON0
    GOTO    MOVETOADCON
ADC2:
    MOVLW   0X09
    MOVWF   ADCON0
    GOTO    MOVETOADCON//</editor-fold>
