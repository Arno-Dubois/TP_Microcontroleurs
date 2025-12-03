PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
PSECT   code, abs
   
; Table des pin ================================================================
; Les boutons BP0 et BP1 sont par défaut sur l'état 1 et passe à l'état 0
; l'orqu'ils sont appuyés
; Le BP0 est sur la pin RA6 et le BP0 sur la pin RA7
   
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
    BANKSEL ANSELA
    bcf ANSELA, 6 ; Set RA6(BP1) to analog
    bcf ANSELA, 7 ; Set RA7(BP0) to analog
    BANKSEL TRISA
    bsf TRISA, 6 ; PORTA6 est une entrée button1
    bsf TRISA, 7 ; PORTA7 est une entrée button0
    
    clrf TRISC   ; Définir les pins C en sortie
    clrf 0x20    ; Efface tout
    clrf 0x21
    movlw 1
    movwf 0x22	 ; Set 0x22 to one
    movlw 0
    
    goto main
    
main:
    btfss PORTA, 6 ; Teste si PORTA6, button1 != 1
    goto loop
    btfss PORTA, 7 ; Teste si PORTA7, button0 != 1
    goto loop
    
    goto main

loop:
    ; Boucle infinie
    addlw 1	  ; Add one to W
    bc addMSByte  ; and branch if overflow
    
    nop ; Add delay else led are too fast
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    goto main

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
    
addMSByte:
    movf 0x21, W     ; Put value of MSByte in W
    addlw 1	     ; Add one
    movwf 0x21	     ; Save MSByte
    
    bc moveChenilars ; If add 1 to 0x21 overflow move chenillars
    
    goto main	     ; Go back to incrementing LSByte
    
moveChenilars:
    movf 0x22, W     ; Get back 0x22
    
    btfss PORTA, 6   ; Teste si PORTA6, button1 != 0
    rrncf 0x22	     ; move all bits of 0x22 to the left
    btfss PORTA, 7   ; Teste si PORTA7, button0 != 0
    rlncf 0x22	     ; move all bits of 0x22 to the left
    movff 0X22, LATC ; Show LED
    
    goto main
    
    
end