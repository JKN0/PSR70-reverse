sdcc -mz80 -c minios.c 
sdcc -mz80 --code-loc 0x0110 --data-loc 0xE000 drumtest.c minios.rel
packihx drumtest.ihx > _drumtest.hex
