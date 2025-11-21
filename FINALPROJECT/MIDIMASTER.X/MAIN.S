;Payden Hoskins
;11/18/25
;Final	Project
;RCET3375
    
;-------------------------------------------------------------------------------
    
; PIC16F1788 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Memory Code Protection (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = ON         ; Clock Out Enable (CLKOUT function is enabled on the CLKOUT pin)
  CONFIG  IESO = OFF            ; Internal/External Switchover (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is disabled)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  VCAPEN = OFF          ; Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
  CONFIG  PLLEN = OFF            ; PLL Enable (4x PLL enabled)
  CONFIG  STVREN = OFF          ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will not cause a Reset)
  CONFIG  BORV = HI             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), high trip point selected.)
  CONFIG  LPBOR = OFF           ; Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
  CONFIG  DEBUG = OFF           ; In-Circuit Debugger Mode (In-Circuit Debugger disabled, ICSPCLK and ICSPDAT are general purpose I/O pins)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

// config statements should precede project file includes.
#include <xc.inc>
#include <pic16f1788.inc>
;-------------------------------------------------------------------------------

;Register/Variable setup
ACKTEST	EQU 0X20

;Startup Section  
PSECT resetVect,class=CODE,delta=2

    
PSECT isrVect,class=CODE,delta=2

   
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
;BANK1
    MOVLW   1
    MOVWF   BSR	
;OSCTUNE- SET TO MAXIMUM FREQUENCY FOR INTERNAL OS
    MOVLW   0X1F
    MOVWF   OSCTUNE
;OSCCON--16MHz CLK ON THE INTERNAL OS
    MOVLW   0X78
    MOVWF   OSCCON

;TRIS
    MOVLW   0XFF
    MOVWF   TRISA
    MOVLW   0XFD
    MOVWF   TRISB
    MOVLW   0XFF
    MOVWF   TRISC    
    
;BANK2
    MOVLW   2
    MOVWF   BSR
    CLRF    LATA
    CLRF    LATB
    CLRF    LATC
    
    ;APFCON- SETTING MSSP TO BE ON PORTB6-7
    MOVLW   0X00
    MOVWF   APFCON1

;BANK3
    MOVLW   3
    MOVWF   BSR
    CLRF    ANSELA
    CLRF    ANSELB
    CLRF    ANSELC
    
;BANK4
    MOVLW   4
    MOVWF   BSR
    CLRF    WPUA
    CLRF    WPUB
    CLRF    WPUC
    CLRF    WPUE
    
    ;SSPCON1- MASTER MODE FOSC/(4*(SSPADD+1))
    MOVLW   0X28
    MOVWF   SSP1CON1 
    
    MOVLW   0X4F
    MOVWF   SSP1ADD

;BANK5
    MOVLW   5
    MOVWF   BSR
    CLRF    ODCONA
    CLRF    ODCONB
    CLRF    ODCONC
    
;BANK6
    MOVLW   6
    MOVWF   BSR
    CLRF    SLRCONA
    CLRF    SLRCONB
    CLRF    SLRCONC
    
;BANK7
    MOVLW   7
    MOVWF   BSR
    CLRF    INLVLA
    CLRF    INLVLB
    CLRF    INLVLC
    CLRF    INLVLE
    
;BANK10
    MOVLW   10
    MOVWF   BSR
    MOVLW   0X83
    MOVWF   CLKRCON
    
;BANK2
    MOVLW   0
    MOVWF   BSR
GOTO	MAIN
    
MAIN:
    BTFSC   PORTB,0
    CALL I2CWRITE
    GOTO    MAIN
I2CWRITE:    
//<editor-fold defaultstate="collapsed" desc="ADDRESS SEND">
    ;GOTO BANK4
    MOVLW   4
    MOVWF   BSR
    
    ;START ENABLE
    BSF	SEN
    
    MOVLW   0
    MOVWF   BSR
STARTFINISH:
    BTFSS   PIR1,3
    GOTO    STARTFINISH
    BCF	    PIR1,3
    
    MOVLW   4
    MOVWF   BSR
    
    ;SEND ADDRESS
    MOVLW   0XAA
    MOVWF   SSP1BUF
    
    ;WAIT FOR THE DATA IN THE BUFFER TO SEND
ADDBUFFERFULL:
    BTFSC   SSP1STAT,0
    GOTO    ADDBUFFERFULL
    
    ;CLEAR MSSP INTERRUPT FLAG
    MOVLW   0
    MOVWF   BSR
    BCF	    PIR1,3
    MOVLW   4
    MOVWF   BSR
    
    ;TEST FOR THE ACKNOWLEDGE FROM THE SLAVE
ADDACK:
    BTFSC   SSP1CON2,6
    GOTO    STOPSET
    
    ;CLEAR MSSP INTERRUPT FLAG
    MOVLW   0
    MOVWF   BSR
    BCF	    PIR1,3
    MOVLW   4
    MOVWF   BSR //</editor-fold>

    ;STOP CONDITION IS SET
STOPSET:
    BSF	    SSP1CON2,2	    
    
    ;TEST FOR THE STOP CONDITION TO FINISH
TESTFORSTOP:    
    BTFSC   SSP1CON2,2
    GOTO    TESTFORSTOP
    BCF	    PIR1,3   
    
    RETURN
END