# Yamaha PSR-70 keyboard reverse engineering project

Project's goal is to reverse engineer and document Yamaha OPQ (YM3806/YM3533) and RYP4 (YM2154) chips used in PSR-70 and a few other Yamaha keyboards.

Current status of the project:
- PSR-70 hardware has been reversed far enough to understand the basics, memory and I/O maps. 
- Program ROMs have been read out, disassembled and analyzed.
- Various test programs have been written and can be run in the PSR-70 hardware using EPROM emulator.
- Using information gathered in previous steps, decent understanding of the OPQ and RYP4 chips has been gained.
- Programmers guide V 1.1 for the OPQ has been written (file Guides/OPQ_ProgGuide.pdf).
- Programmers guide V 1.0 for the RYP4 has been written (file Guides/RYP4_ProgGuide.pdf).

Main chips in the PSR-70 are:
- NEC D70008 = Z80-CPU
- EPROM 27256, 32 KB program memory
- 4 x TC5517 static RAM 2 KB, total 8 KB of RAM
- HD63A50 UART, midi interface
- 82C55 parallel-I/O, keyboard scanning
- YM3806 OPQ FM synthesizer
- YM2154 RYP4 PCM drum chip
- 2 x YM2190 serial ROM 32 KB, drum samples for YM2154
- 2 x YM3012 2 channel DAC
- Unknown Yamaha chip IG14330, handles communication to front panel buttons/leds
- Yamaha 32 KB mask-ROM, contains sound data and parts of the firmware


Files:

- Hardware: 
  - Block diagram
  - Reverse engineered address and I/O decoders
  - Adress and I/O maps
  - Photo of the main board

- Software
  - EPROM (IC109)
    - Intel hex dump
    - Disassembly listing
  - ROM2 (IC110)
    - Hex dump
    - Disassembly listing
  - Test programs
    - Assembly
        - Two Hello world versions
        - ROM2 dumper program
        - First sound test program
    - Soundtest2
        - Serial UI for testing the OPQ (YM3806)
    - Drumtest
        - Serial UI for testing the RYP4 (YM2154

- Guides
  - OPQ Programmer's Guide
  - RYP4 Programmer's Guide

- PSR-60_ROMs (for reference)
  - PSR-60 IC109 binary
  - PSR-60 IC109 hex dump
  - PSR-60 IC109 disassembly listing
  - PSR-60 IC110 binary
  - PSR-60 IC110 hex dump
  - PSR-60 IC110 disassembly listing

PSR-60 ROM files are courtesy of Edward from d-tech.

More details of the reverse engineering project: 
https://retroandreverse.blogspot.com/search/label/PSR-70%20reverse%20engineering

