PROCESSOR 18F25K40
#include <xc.inc>
    
; Observation ==================================================================
; On observe que les signaux sont beaucoup plus stables et l'ensemble des
; signaux ont la même période.

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
    
    BANKSEL INTCON
    movlw 0b00100000 ; Activate interruption
    addlw 0b10000000 ; Activate high interruption
    movwf INTCON     ; Save interupt config
    
    BANKSEL PIE4
    movlw 0b00000010 ; Set interruption source to timer2
    movwf PIE4	     ; Save config
    
    BANKSEL IPR4
    movlw 0b00000010 ; Set interrupton to high priority
    movwf IPR4	     ; Save config
    
    
    
    goto loop

loop:
    ; Boucle infinie
    goto loop
    
ledToggle:
    BANKSEL PIR4
    bcf PIR4, 1 ; Reset timer flag
    
    BANKSEL LATB
    btg LATB, 5 ; Toggle led
    
    
    retfie

; Routines d'interruption ======================================================    
High_ISR:
    BANKSEL PIR4
    btfsc PIR4, 1  ; Check if it's the right interruption
    goto ledToggle
    
    retfie	
    
Low_ISR:  
    retfie
     
end