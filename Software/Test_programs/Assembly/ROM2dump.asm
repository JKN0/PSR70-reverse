; ========================================================================
; Yamaha PSR-70 ROM2 dumper
; Sends ROM2 contents to serial port in format
; 0000 12 34 56 ...
; 0010 AB CD EF ...
; ...
;
; ROM2 (32 kB) resides in processor address space at 8000H...BFFFH (16 kB). 
; Highest address bit (A14) is driven from 8255 PC4. This determines 
; which ROM2 block (0000H...3FFFh or 4000H...7FFFH) is seen 
; in processor addresses 8000H...BFFFH.

; I/O devices
UART_CONTROL    EQU     10H
UART_STATUS     EQU     10H
UART_DATA       EQU     11H

PPI_PA          EQU     20H
PPI_PB          EQU     21H
PPI_PC          EQU     22H
PPI_CONTROL     EQU     23H

; ASCII chars
CR              EQU     0DH
LF              EQU     0AH
SPACE           EQU     20H

; Variables in RAM
                ORG     0E000H
a14_mask:       DS      1

; ------------------------------------------------------------------------
; Main program, starts from reset

        ORG     0
        SEEK    0

        DI
        LD      SP,0FFFFH
        
        LD      HL,200
        CALL    delay
        
        CALL    init_ppi
        CALL    init_uart

        LD      A,00H
        LD      (a14_mask),A
        
block_loop:
        LD      DE,0                ; DE counts from 0000H...3FFFH two times

row_loop:
        CALL    print_cr_lf
        
        PUSH    DE                  ; Arduino SoftwareSerial needs some time to breathe
        LD      HL,10
        CALL    delay
        POP     DE

        LD      A,(a14_mask)        ; print ROM2 real address, including A14 (0000H...7FFFH)
        OR      D
        LD      H,A
        LD      L,E
        CALL    print_addr

byte_loop:
        LD      A,SPACE
        CALL    putchar
        
        LD      A,80H               ; print ROM2 byte from processor addresses 8000H...BFFFH
        OR      D
        LD      H,A
        LD      L,E
        LD      A,(HL)
        CALL    print_byte
        
        INC     DE                  ; next address
        
        LD      A,E                 ; 16 bytes per row
        AND     0FH
        JR      NZ,byte_loop
        
        LD      A,E                 ; new row: is 16k block changing also (is DE==4000H)?
        OR      A
        JR      NZ,row_loop
        LD      A,D
        CP      40H
        JR      NZ,row_loop

        LD      A,(a14_mask)        ; block changes: was this already the upper 16k block?
        CP      40H
        JR      Z,stop
        
        LD      A,40H               ; upper 16k block in use
        LD      (a14_mask),A
        LD      A,90H               ; ROM2 A14 = PC4 <-- 1
        OUT     (PPI_PC),A
       
        JP      block_loop
        
stop:
        JP      $                   ; stop here
        
; ------------------------------------------------------------------------
; Print CR LF

print_cr_lf:
        LD      A,CR
        CALL    putchar
        
        LD      A,LF
        CALL    putchar

        RET
        
; ------------------------------------------------------------------------
; Print byte in A as two hex chars

print_byte:
        PUSH    AF
        RRA
        RRA
        RRA
        RRA
        AND     0FH
        CALL    tohex
        CALL    putchar

        POP     AF
        AND     0FH
        CALL    tohex
        CALL    putchar
        
        RET
        
; ------------------------------------------------------------------------
; Print word in HL as four hex chars

print_addr:
        PUSH    HL
        LD      A,H
        CALL    print_byte
        
        POP     HL
        LD      A,L
        CALL    print_byte
        
        RET
        
; ------------------------------------------------------------------------
; Convert A to ASCII hex, return in A

tohex:
        OR      30H
        CP      3AH
        RET     C
        ADD     A,7
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
        
        LD      A,95H               ; clk/16, 8-N-1, tx + rx int disable
        OUT     (UART_CONTROL),A

        RET



        
