PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
PSECT   code, abs
   
; Vecteur de reset =============================================================
org     0x000
goto init 
   
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR 

; Programme principal ==========================================================
org 0x100   

init:
    ; Initialisation  
    movlw 0x07 ; Charger 0x08 dans WREG
    BANKSEL RC0PPS
    movwf RC0PPS ; Charger WREG (0x08) dans RA0PPS
    BANKSEL TRISC
    bcf TRISC, 0
    
    bcf TRISC, 1
    bsf LATC, 1
    
    BANKSEL PWM3CON
    movlw 0b10000000 ; Enable PWM3
    movwf PWM3CON    ; Save config
    
    BANKSEL PWM3DCH
    movlw 0b00110010 ; Config 20% de overflow = 200
    movwf PWM3DCH
    
    BANKSEL T2CON
    movlw 0b10000000 ; Enable Timer
    addlw 0b01010000 ; Set Prescaler to 1:32
    addlw 0b00001111 ; Set Postscaler to 1:16
    movwf T2CON      ; Save timer conf
    
    BANKSEL T2CLKCON
    movlw 0b00000001   ; Set timer source to Fosc/4
    movwf T2CLKCON     ; Save timer conf
    
    BANKSEL T2PR
    movlw 0b11111001 ; Define PR2 to 249
    movwf T2PR	     ; Save PR2
    
    call configLEDM
    
    BANKSEL INTCON
    movlw 0b00100000 ; Activate interruption
    addlw 0b10000000 ; Activate high interruption
    addlw 0b01000000 ; Activate low interruption
    movwf INTCON     ; Save interupt config
    
    goto loop
    
configLEDM:
    bcf TRISB, 4   ; Définir la pin B4 en sortie

    BANKSEL T0CON0
    movlw 0b10000000 ; Enable Timer
    addlw 0b00000100 ; Set Postscaler to 1:5
    movwf T0CON0     ; Save timer conf

    BANKSEL T0CON1
    movlw 0b01000000 ; Set timer source to Fosc/4
    addlw 0b00000111 ; Set Prescaler to 1:32768
    movwf T0CON1     ; Save timr conf

    BANKSEL TMR0H
    movlw 0b01111100 ; Set TMR0H to 124
    movwf TMR0H	     ; Save TMR0H

    BANKSEL PIE0
    movlw 0b00100000 ; Set interruption source to timer0
    movwf PIE0	     ; Save config

    BANKSEL IPR0
    movlw 0b00000000 ; Set interrupton to low priority
    movwf IPR0	     ; Save config

    return

loop:
    ; Boucle infinie
    
   
    goto loop
    
ledToggle:
    BANKSEL PIR0
    bcf PIR0, 5 ; Reset timer flag

    BANKSEL LATB
    btg LATB, 4 ; Toggle led
    BANKSEL PWM3DCH
    btfss 0x23
    incfsz PWM3DCH ; Config 20% de overflow = 200
    btg 0x23
    btfsc 0x23
    incfsz PWM3DCH ; Config 20% de overflow = 200
    btg 0x23

    retfie

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    BANKSEL PIR0
    btfsc PIR0, 5  ; Check if it's the right interruption
    goto ledToggle
    retfie
     
end