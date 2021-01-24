; ========================================================================
; Yamaha PSR-70 sound tests for YM3806 reverse engineering project.

; First sound producing version! 4.2.2020

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

; ------------------------------------------------------------------------
; Main program, starts from reset

        DI
        LD      SP,0FFFFH
        
        LD      HL,200
        CALL    delay
        
        CALL    init_ppi
        CALL    init_uart

        LD      HL,start_text
        CALL    print
        
        LD      HL,status_text
        CALL    print
        
        LD      A,(0C000H)
        CALL    print_byte
        CALL    print_cr_lf
        
        LD      A,0C8H               ; PC7 reset, PC6 analog board something, PC3 ??
        OUT     (PPI_PC),A

; startup
        LD      L,01DH
        LD      E,010H
        CALL    write_YM3806

        LD      L,05DH
        LD      E,020H
        CALL    write_YM3806

        LD      L,055H
        LD      E,01EH
        CALL    write_YM3806

        LD      L,04DH
        LD      E,022H
        CALL    write_YM3806

        LD      L,045H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05DH
        LD      E,081H
        CALL    write_YM3806

        LD      L,055H
        LD      E,082H
        CALL    write_YM3806

        LD      L,04DH
        LD      E,083H
        CALL    write_YM3806

        LD      L,045H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09DH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,095H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,08DH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,085H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0BDH
        LD      E,080H
        CALL    write_YM3806

        LD      L,0B5H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0ADH
        LD      E,002H
        CALL    write_YM3806

        LD      L,0A5H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0DDH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D5H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CDH
        LD      E,004H
        CALL    write_YM3806

        LD      L,0C5H
        LD      E,000H
        CALL    write_YM3806

        LD      L,015H
        LD      E,072H
        CALL    write_YM3806

        LD      L,01EH
        LD      E,020H
        CALL    write_YM3806

        LD      L,01FH
        LD      E,020H
        CALL    write_YM3806

        LD      L,05EH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,056H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,04EH
        LD      E,020H
        CALL    write_YM3806

        LD      L,046H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05EH
        LD      E,081H
        CALL    write_YM3806

        LD      L,056H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04EH
        LD      E,081H
        CALL    write_YM3806

        LD      L,046H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09EH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,096H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,08EH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,086H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0BEH
        LD      E,040H
        CALL    write_YM3806

        LD      L,0B6H
        LD      E,040H
        CALL    write_YM3806

        LD      L,0AEH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0A6H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0FEH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F6H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0EEH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0E6H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0DEH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D6H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CEH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C6H
        LD      E,000H
        CALL    write_YM3806

        LD      L,016H
        LD      E,07CH
        CALL    write_YM3806

        LD      L,05FH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,057H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,04FH
        LD      E,020H
        CALL    write_YM3806

        LD      L,047H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05FH
        LD      E,081H
        CALL    write_YM3806

        LD      L,057H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04FH
        LD      E,081H
        CALL    write_YM3806

        LD      L,047H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09FH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,097H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,08FH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,087H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0BFH
        LD      E,040H
        CALL    write_YM3806

        LD      L,0B7H
        LD      E,040H
        CALL    write_YM3806

        LD      L,0AFH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0A7H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0FFH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F7H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0EFH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0E7H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0DFH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D7H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CFH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C7H
        LD      E,000H
        CALL    write_YM3806

        LD      L,017H
        LD      E,07CH
        CALL    write_YM3806

        LD      L,0FFH
        LD      E,008H
        CALL    write_YM3806

        LD      L,0EFH
        LD      E,000H
        CALL    write_YM3806

        LD      L,005H
        LD      E,007H
        CALL    write_YM3806

        LD      L,018H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E0H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0E8H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F0H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F8H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E0H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0E8H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F0H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F8H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,058H
        LD      E,020H
        CALL    write_YM3806

        LD      L,050H
        LD      E,020H
        CALL    write_YM3806

        LD      L,048H
        LD      E,020H
        CALL    write_YM3806

        LD      L,040H
        LD      E,020H
        CALL    write_YM3806

        LD      L,058H
        LD      E,080H
        CALL    write_YM3806

        LD      L,050H
        LD      E,081H
        CALL    write_YM3806

        LD      L,048H
        LD      E,083H
        CALL    write_YM3806

        LD      L,040H
        LD      E,081H
        CALL    write_YM3806

        LD      L,098H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,090H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,088H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,080H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0B8H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0B0H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A8H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A0H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0D8H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D0H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C8H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C0H
        LD      E,000H
        CALL    write_YM3806

        LD      L,010H
        LD      E,0BDH
        CALL    write_YM3806

        LD      L,019H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E1H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0E9H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F1H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F9H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,001H
        CALL    write_YM3806

        LD      L,0E1H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0E9H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F1H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F9H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,059H
        LD      E,020H
        CALL    write_YM3806

        LD      L,051H
        LD      E,020H
        CALL    write_YM3806

        LD      L,049H
        LD      E,020H
        CALL    write_YM3806

        LD      L,041H
        LD      E,020H
        CALL    write_YM3806

        LD      L,059H
        LD      E,080H
        CALL    write_YM3806

        LD      L,051H
        LD      E,081H
        CALL    write_YM3806

        LD      L,049H
        LD      E,083H
        CALL    write_YM3806

        LD      L,041H
        LD      E,081H
        CALL    write_YM3806

        LD      L,099H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,091H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,089H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,081H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0B9H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0B1H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A9H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A1H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0D9H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D1H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C9H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C1H
        LD      E,000H
        CALL    write_YM3806

        LD      L,011H
        LD      E,0BDH
        CALL    write_YM3806

        LD      L,01AH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E2H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0EAH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F2H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0FAH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,002H
        CALL    write_YM3806

        LD      L,0E2H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0EAH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F2H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0FAH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,05AH
        LD      E,020H
        CALL    write_YM3806

        LD      L,052H
        LD      E,020H
        CALL    write_YM3806

        LD      L,04AH
        LD      E,020H
        CALL    write_YM3806

        LD      L,042H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05AH
        LD      E,080H
        CALL    write_YM3806

        LD      L,052H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04AH
        LD      E,083H
        CALL    write_YM3806

        LD      L,042H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09AH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,092H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,08AH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,082H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0BAH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0B2H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0AAH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A2H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0DAH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D2H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CAH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C2H
        LD      E,000H
        CALL    write_YM3806

        LD      L,012H
        LD      E,0BDH
        CALL    write_YM3806

        LD      L,01BH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E3H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0EBH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F3H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0FBH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,003H
        CALL    write_YM3806

        LD      L,0E3H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0EBH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F3H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0FBH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,05BH
        LD      E,020H
        CALL    write_YM3806

        LD      L,053H
        LD      E,020H
        CALL    write_YM3806

        LD      L,04BH
        LD      E,020H
        CALL    write_YM3806

        LD      L,043H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05BH
        LD      E,080H
        CALL    write_YM3806

        LD      L,053H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04BH
        LD      E,083H
        CALL    write_YM3806

        LD      L,043H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09BH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,093H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,083H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0BBH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0B3H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0ABH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A3H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0DBH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D3H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CBH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C3H
        LD      E,000H
        CALL    write_YM3806

        LD      L,013H
        LD      E,0BDH
        CALL    write_YM3806

        LD      L,01CH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E4H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0ECH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F4H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0FCH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,004H
        CALL    write_YM3806

        LD      L,0E4H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0ECH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F4H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0FCH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,05CH
        LD      E,020H
        CALL    write_YM3806

        LD      L,054H
        LD      E,020H
        CALL    write_YM3806

        LD      L,04CH
        LD      E,020H
        CALL    write_YM3806

        LD      L,044H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05CH
        LD      E,080H
        CALL    write_YM3806

        LD      L,054H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04CH
        LD      E,083H
        CALL    write_YM3806

        LD      L,044H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09CH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,094H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,08CH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,084H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0BCH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0B4H
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0ACH
        LD      E,09FH
        CALL    write_YM3806

        LD      L,0A4H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,0DCH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0D4H
        LD      E,000H
        CALL    write_YM3806

        LD      L,0CCH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0C4H
        LD      E,000H
        CALL    write_YM3806

        LD      L,014H
        LD      E,0BDH
        CALL    write_YM3806

        LD      L,01DH
        LD      E,000H
        CALL    write_YM3806

        LD      L,0E5H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0EDH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0F5H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0FDH
        LD      E,00BH
        CALL    write_YM3806

        LD      L,005H
        LD      E,005H
        CALL    write_YM3806

        LD      L,0E5H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0EDH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F5H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0FDH
        LD      E,00FH
        CALL    write_YM3806

        LD      L,05DH
        LD      E,020H
        CALL    write_YM3806

        LD      L,055H
        LD      E,020H
        CALL    write_YM3806

        LD      L,04DH
        LD      E,020H
        CALL    write_YM3806

        LD      L,045H
        LD      E,020H
        CALL    write_YM3806

        LD      L,05DH
        LD      E,080H
        CALL    write_YM3806

        LD      L,055H
        LD      E,081H
        CALL    write_YM3806

        LD      L,04DH
        LD      E,083H
        CALL    write_YM3806

        LD      L,045H
        LD      E,081H
        CALL    write_YM3806

        LD      L,09DH
        LD      E,01FH
        CALL    write_YM3806

        LD      L,095H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,08DH
        LD      E,01FH
        CALL    write_YM3806

        LD      HL,500
        CALL    delay

play_loop:
        ; middle-C key on -----
        
        LD      HL,key_on_text
        CALL    print
        
        LD      L,0E1H
        LD      E,00BH
        CALL    write_YM3806

        LD      L,0E9H
        LD      E,00CH
        CALL    write_YM3806

        LD      L,0F1H
        LD      E,00CH
        CALL    write_YM3806

        LD      L,0F9H
        LD      E,00CH
        CALL    write_YM3806

        LD      L,005H
        LD      E,001H
        CALL    write_YM3806

        LD      L,039H
        LD      E,0CAH
        CALL    write_YM3806

        LD      L,029H
        LD      E,044H
        CALL    write_YM3806

        LD      L,031H
        LD      E,0CAH
        CALL    write_YM3806

        LD      L,021H
        LD      E,044H
        CALL    write_YM3806

        LD      L,0E1H
        LD      E,05FH
        CALL    write_YM3806

        LD      L,0E9H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F1H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,0F9H
        LD      E,00FH
        CALL    write_YM3806

        LD      L,061H
        LD      E,01CH
        CALL    write_YM3806

        LD      L,069H
        LD      E,01EH
        CALL    write_YM3806

        LD      L,071H
        LD      E,020H
        CALL    write_YM3806

        LD      L,079H
        LD      E,01FH
        CALL    write_YM3806

        LD      L,019H
        LD      E,000H
        CALL    write_YM3806

        LD      L,005H
        LD      E,079H
        CALL    write_YM3806

        LD      HL,500
        CALL    delay

        ; middle-C key off ---------
        
        LD      HL,key_off_text
        CALL    print

        LD      L,0F9H
        LD      E,009H
        CALL    write_YM3806

        LD      L,0F1H
        LD      E,009H
        CALL    write_YM3806

        LD      L,0E9H
        LD      E,009H
        CALL    write_YM3806

        LD      L,0E1H
        LD      E,059H
        CALL    write_YM3806

        LD      L,005H
        LD      E,001H
        CALL    write_YM3806        
        
        LD      HL,500
        CALL    delay

        JP      play_loop

start_text:
        DB      0DH,0AH,"-- Soundtest --",0DH,0AH,00H

status_text:
        DB      "YM3806 status: ",00H

key_on_text:
        DB      "Key on - ",00H

key_off_text:
        DB      "off",0DH,0AH,00H

; ------------------------------------------------------------------------
; Write byte to YM3806. L = register, E = value

write_YM3806:
        LD      A,(0C000H)          ; wait for YM3806 ready
        RLA
        JR      C,write_YM3806
        
        LD      H,0C0H              ; write register
        LD      (HL),E

        RET

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
; Send a string to UART

print:        
        LD      A,(HL)
        OR      A
        RET     Z
        CALL    putchar
        INC     HL
        JR      print

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
        

        
