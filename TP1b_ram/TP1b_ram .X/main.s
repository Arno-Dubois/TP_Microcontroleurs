PROCESSOR 18F25K40
#include <xc.inc>
    
; Commentaire sur le programme =================================================
; Le programme vas trop vite pour effectuer un timer, mais en théorie le temps
; d'allumer toutes les LED peux être utilisé comme un timer

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
PSECT   code, abs
   
; Table des pins ===============================================================
; LED LD0 pin RC0
; LED LD1 pin RC1
; LED LD2 pin RC2
; LED LD3 pin RC3
; LED LD4 pin RC4
; LED LD5 pin RC5
; LED LD6 pin RC6
; LED LD7 pin RC7

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
    clrf TRISC   ; Définir les pins C en sortie
    clrf 0x20    ; Efface tout
    clrf 0x21
    movlw 0
    goto loop

loop:
    ; Boucle infinie
    addlw 1	  ; Add one to W
    bc addMSByte  ; and branch if overflow
    
    
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
    
addMSByte :
    movf 0x21, W     ; Put value of MSByte in W
    addlw 1	     ; Add one
    movwf 0x21	     ; Save MSByte
    movff 0X21, LATC ; Show LED
    
    goto loop	     ; Go back to incrementing LSByte
    
end