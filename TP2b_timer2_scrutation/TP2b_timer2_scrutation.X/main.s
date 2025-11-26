PROCESSOR 18F25K40
#include <xc.inc>
    
; Observation ==================================================================
; On observe sur l'oscilloscope un crénelage de période 20µs, ce qui correspond
; bien à notre configuration d'inverser l'état de la broche tous les 10µs.

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
    bcf TRISB, 5   ; Définir la pin B5 en sortie
    
    BANKSEL T2CON
    movlw 0b10000000 ; Enable Timer
    addlw 0b01010000 ; Set Prescaler to 1:32
    addlw 0b00000100 ; Set Postscaler to 1:5
    movwf T2CON     ; Save timer conf
    
    BANKSEL T2CLKCON
    movlw 0b00000001   ; Set timer source to Fosc/4
    movwf T2CLKCON     ; Save timer conf
    
    BANKSEL T2PR
    movlw 0b00000000 ; Define PR2 to 0
    movwf T2PR	     ; Save PR2
    
    goto loop

loop:
    ; Boucle infinie
    BANKSEL PIR4
    btfsc PIR4, 1 ; If timer reach value toggle led
    call ledToggle

    goto loop
    
ledToggle:
    BANKSEL PIR4
    bcf PIR4, 1 ; Reset timer flag
    
    BANKSEL LATB
    btg LATB, 5 ; Toggle led
    
    
    return

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end