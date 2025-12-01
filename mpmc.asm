LIST    P=18F452
    #include <P18F452.INC>

    ; Configuration bits
    CONFIG  OSC = HS
    CONFIG  WDT = OFF
    CONFIG  LVP = OFF

    CBLOCK  0x20
        DUTY                ; PWM duty cycle (0-255)
    ENDC

    ORG     0x0000
    GOTO    MAIN

MAIN
    MOVLW   0x80                ; Default PWM duty cycle = 50%
    MOVWF   DUTY

    ; Set RD0 and RD1 as inputs for switches (others output for LEDs)
    MOVLW   b'00000011'         ; RD0/RD1 input, RD2?RD7 outputs
    MOVWF   TRISD

    ; RC2 as output for PWM
    BCF     TRISC,2

    ; Configure CCP1 (RC2) for PWM
    MOVLW   0x0C
    MOVWF   CCP1CON

    ; Set PWM period (PR2), and start Timer2
    MOVLW   0xFF
    MOVWF   PR2
    MOVLW   0x04
    MOVWF   T2CON
    BSF     T2CON, TMR2ON

MAIN_LOOP
    ; Check "speed up" switch on RD0 (pressed = logic HIGH)
    BTFSC   PORTD,0
    INCF    DUTY, F

    ; Check "speed down" switch on RD1 (pressed = logic HIGH)
    BTFSC   PORTD,1
    DECF    DUTY, F

    ; Clamp DUTY value between 0 and 255
    MOVLW   0x00
    CPFSLT  DUTY
    MOVLW   0x00
    MOVWF   DUTY
    MOVLW   0xFF
    CPFSGT  DUTY
    MOVLW   0xFF
    MOVWF   DUTY

    ; Set PWM duty cycle (RC2 pin)
    MOVF    DUTY,W
    MOVWF   CCPR1L

    ; Indicate approximate speed via LEDs (RD2?RD5)
    MOVF    DUTY,W
    SWAPF   WREG,F           ; Use upper nibble for rough level indication
    ANDLW   0x0F
    IORLW   0xC0             ; Shift into RD2?RD5 (if needed, adjust for your circuit)
    MOVWF   LATD

    GOTO    MAIN_LOOP

    END