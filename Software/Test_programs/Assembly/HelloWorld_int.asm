; ========================================================================
; Interrupt based Hello World for Yamaha PSR-70 testing

; UART is HD6350
; Interrupt source is YM3860's timer, programmed 
; to cause interrupt every 10 ms.

UART_CONTROL    EQU     10H
UART_STATUS     EQU     10H
UART_DATA       EQU     11H

PPI_PA          EQU     20H
PPI_PB          EQU     21H
PPI_PC          EQU     22H
PPI_CONTROL     EQU     23H

; Variables in RAM
                ORG     0E000H
rtc_counter:    DS      1
send_ptr:       DS      2

; ------------------------------------------------------------------------
; Reset and interrupt vectors

        ORG     0
        SEEK    0
        DI
        JP      main
        
        ORG     38H
        SEEK    38H
        JP      int_service
                
; ------------------------------------------------------------------------
; Main program

main:
        LD      SP,0FFFFH
        
        IM      1                       ; original PSR-70 uses Interrupt Mode 1
        
        LD      HL,200
        CALL    delay
        
        CALL    init_ppi
        CALL    init_uart
        
        LD      A,0
        LD      (rtc_counter),A
        
        LD      A,71H                   ; start RTC interrupts
        LD      (0C003H),A
        
        EI
        
start_send:        
        LD      HL,hw_text              ; send "Hello world"
        CALL    send_data
        
        LD      A,(rtc_counter)         ; wait for 500 ms (50*10ms) to pass
        ADD     A,50
        LD      B,A
        
wait_loop:
        LD      A,(rtc_counter)
        CP      B
        JR      NZ,wait_loop
        
        JP      start_send
        
hw_text:
        DB      "Hello world!",0DH,0AH,00H
        
; ------------------------------------------------------------------------
; Start sending to UART. Interrupt service does the actual sending.
; Pointer to text in HL.

send_data:
        LD      (send_ptr),HL
        
        LD      A,35H               ; tx int enable
        OUT     (UART_CONTROL),A    ; this will cause first interrupt, because TDRE is already on
        
        RET
        
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
        
        LD      A,15H               ; clk/16, 8-N-1, tx + rx int disable
        OUT     (UART_CONTROL),A

        RET
        
; ------------------------------------------------------------------------
; Interrupt service

int_service:
        PUSH    AF
        PUSH    BC        
        PUSH    DE
        PUSH    HL

        LD      A,(0C000h)          ; is YM3806 interrupting?
        AND     05h
        CALL    NZ,YM3806_int_serv

        IN      A,(UART_status)     ; is UART interrupting?
        RLA                     
        CALL    C,uart_int_serv
        
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        EI
        RETI
   
; ------------------------------------------------------------------------
; Real-time interrupt service

YM3806_int_serv:
        LD      A,71H           ; reset the timer
        LD      (0C003H),A
        
        LD      HL,rtc_counter
        INC     (HL)
        
        RET
        
; ------------------------------------------------------------------------
; UART interrupt service

uart_int_serv:
        AND     04H         ; TDRE after 1 rotation
        RET     Z
        
        LD      HL,(send_ptr)
        LD      A,(HL)
        OR      A
        JR      Z,end_send
        OUT     (UART_DATA),A       ; send char
        
        INC     HL
        LD      (send_ptr),HL
                
        RET
        
end_send:
        LD      A,15H               ; tx int disable
        OUT     (UART_CONTROL),A
        RET
        