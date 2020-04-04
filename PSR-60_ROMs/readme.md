# Yamaha PSR-60 ROM files

The binary files are downloaded from http://dbwbp.com/index.php/9-misc/37-synth-eprom-dumps by courtesy of Edward d-tech.

PSR-60 has same main CPU board as PSR-70 but different keyboard (4 octaves) and front panel, so it is interesting
to compare the softwares. Main ROM (IC109, EPROM in PSR-70) is different, but judged from disassembly is mostly 
the same. ROM2 (IC110) is identical. It contains the sound definitions, so the sounds are identical.

It is worth noticing that ROM2 resides in addresses 8000H...BFFFH in Z80 address space, but the disassembly listing starts from 0.
