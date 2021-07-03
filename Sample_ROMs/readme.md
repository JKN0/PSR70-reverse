# Sample ROMs YM21908 and YM21909

This directory contains the PSR-70 drum sample ROM files. 

PSR-70 contains two sample ROMs:
- YM21908: basic drum kit
- YM21909: latin percussions

There are three files for each ROM:
- ym2190x.bin: binary contents of the ROM
- ym2190x.hex: the .bin converted to Intel-hex
- ym2190x.wav: the .bin converted to wav-file

Sigrok directory contains the original Sigrok traces taken from the serial bus between the YM2154 and YM2190x while playing the percussions on the PSR-70.
- ROM_signals_all.sr + .pvs: files produced by Sigrok
- ROM_signals_all_overview.png: screen capture of the PulseView
- Keys_samples.txt: the order of the samples in the trace

Sigrok traces have been converted to binary files and corresponding wav-files by Aaron Giles. 

