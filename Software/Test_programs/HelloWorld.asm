; ========================================================================
; Simple Hello World for Yamaha PSR-70 testing

; UART is HD6350

UART_CONTROL    EQU     10H
UART_STATUS     EQU     10H
UART_DATA       EQU     11H

PPI_PA          EQU     20H
PPI_PB          EQU     21H
PPI_PC          EQU     22H
PPI_CONTROL     EQU     23H

; ------------------------------------------------------------------------
; Main program, starts from reset

        DI
        LD      SP,0FFFFH
        
        LD      HL,200
        CALL    delay
        
        CALL    init_ppi
        CALL    init_uart
        
start_send:        
        LD      HL,hw_text
send_loop:
        LD      A,(HL)
        OR      A
        JP      Z,pause
        CALL    putchar
        INC     HL
        JP      send_loop

pause:
        LD      HL,500
        CALL    delay
        JP      start_send
        
hw_text:
        DB      "Hello world!",0DH,0AH,00H
        
; ------------------------------------------------------------------------
; Send a char to UART

putchar:
        LD      B,A
put_wait:
        IN      A,(UART_STATUS)     ; poll tx empty
        AND     02H
        JP      Z,put_wait
        
        LD      A,B
        OUT     (UART_DATA),A       ; send char
        
        RET

; ------------------------------------------------------------------------
; Delay for HL * 1 ms

delay:
        LD      DE,251
delay_loop:
        DEC     DE
        LD      A,D
        OR      E
        JP      NZ,delay_loop
        
        DEC     HL
        LD      A,H
        OR      L
        JP      NZ,delay
        
        RET

; ------------------------------------------------------------------------
; Control word taken from PSR-70 original PPI (8255) init.

init_ppi:
        LD      A,90h               ; 8255 control: mode 0, PA=in, PB=out PC=out
        OUT     (PPI_CONTROL),A
        LD      A,80h               ; PC7 controls some chip resets, must be high
        OUT     (PPI_PC),A
        
        LD      HL,100
        CALL    delay

        RET

; ------------------------------------------------------------------------
; This control sequence taken from PSR-70 original UART init.

init_uart:
        LD      A,00H
        OUT     (UART_CONTROL),A
        OUT     (UART_CONTROL),A
        OUT     (UART_CONTROL),A

        LD      A,03H               ; master reset
        OUT     (UART_CONTROL),A
        LD      HL,5
        CALL    delay
        
        LD      A,95H               ; clk/16, 8-N-1, tx + rx int disable
        OUT     (UART_CONTROL),A

        RET
        
        
