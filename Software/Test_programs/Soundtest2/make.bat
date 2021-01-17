sdcc -mz80 -c minios.c 
sdcc -mz80 --code-loc 0x0110 --data-loc 0xE000 soundtest2.c minios.rel
packihx soundtest2.ihx > _soundtest2.hex
