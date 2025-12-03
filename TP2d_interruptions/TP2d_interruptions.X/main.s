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
    
    call configLEDM
    call configChenillard
    
    BANKSEL INTCON
    movlw 0b00100000 ; Activate interruption
    addlw 0b10000000 ; Activate high interruption
    addlw 0b01000000 ; Activate low interruption
    movwf INTCON     ; Save interupt config
    
    goto loop

configChenillard:
    Banksel TRISC
    clrf TRISC	     ; Définir les pins C en sortie
    movlw 0x00000001
    banksel LATC
    movwf LATC	     ; Initialiser la premiére led du chenillard
    movlw 25	     ; Set number of loop required
    movwf 0x21   
    clrf 0x20	     ; Clear counter  
    
    BANKSEL T2CON
    movlw 0b10000000 ; Enable Timer
    addlw 0b01010000 ; Set Prescaler to 1:32
    addlw 0b00001001 ; Set Postscaler to 1:10
    movwf T2CON      ; Save timer conf
    
    BANKSEL T2CLKCON
    movlw 0b00000001   ; Set timer source to Fosc/4
    movwf T2CLKCON     ; Save timer conf
    
    BANKSEL T2PR
    movlw 0b11111001 ; Define PR2 to 249
    movwf T2PR	     ; Save PR2
    
    BANKSEL PIE4
    movlw 0b00000010 ; Set interruption source to timer2
    movwf PIE4	     ; Save config
    
    BANKSEL IPR4
    movlw 0b00000010 ; Set interrupton to high priority
    movwf IPR4	     ; Save config
    
    return
    
configLEDM:
    bcf TRISB, 4   ; Définir la pin B4 en sortie
    
    BANKSEL T0CON0
    movlw 0b10000000 ; Enable Timer
    addlw 0b00000100 ; Set Postscaler to 1:5
    movwf T0CON0     ; Save timer conf
    
    BANKSEL T0CON1
    movlw 0b01000000 ; Set timer source to Fosc/4
    addlw 0b00001111 ; Set Prescaler to 1:32768
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
    
    retfie
    
moveChenillard:
    BANKSEL PIR4
    bcf PIR4, 1  ; Reset timer flag
    
    movf 0x20, W	 ; Get back counting variable
    addlw 1	 ; Increment one
    movwf 0x20
    
    CPFSEQ 0x21	 ; End there if counter didn't reach the value
    retfie
    banksel LATC
    rlncf LATC	 ; move all bits of LATC to the left
    clrf 0x20
    retfie

; Routines d'interruption ======================================================    
High_ISR:
    BANKSEL PIR4
    btfsc PIR4, 1  ; Check if it's the right interruption
    goto moveChenillard
    
    retfie	
    
Low_ISR:  
    BANKSEL PIR0
    btfsc PIR0, 5  ; Check if it's the right interruption
    goto ledToggle
    
    retfie
     
end