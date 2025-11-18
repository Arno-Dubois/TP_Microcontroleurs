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
    bcf TRISB, 4   ; Définir la pin C0 en sortie
    
    BANKSEL T0CON0
    movlw 0b10000000 ; Enable Timer
    addlw 0b00001000 ; Set Postscaler to 1:9
    movwf T0CON0     ; Save timer conf
    
    BANKSEL T0CON1
    movlw 0b01000000 ; Set timer source to Fosc/4
    addlw 0b00001100 ; Set Prescaler to 1:4096
    movwf T0CON1     ; Save timr conf
    
    BANKSEL TMR0H
    movlw 0b11011000 ; Set TMR0H to 216
    movwf TMR0H	     ; Save TMR0H
    
    goto loop

loop:
    ; Boucle infinie
    BANKSEL PIR0
    btfsc PIR0, 5 ; If timer reach value toggle led
    call ledToggle

    goto loop
    
ledToggle:
    bcf PIR0, 5 ; Reset timer flag
    
    BANKSEL LATB
    btg LATB, 4 ; Toggle led
    
    
    return

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end