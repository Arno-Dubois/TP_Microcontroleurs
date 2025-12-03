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
    goto loop

loop:
    ; Boucle infinie
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end