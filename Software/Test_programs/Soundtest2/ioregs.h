/******************************************************************************

  PSR-70 I/O

  10.2.2020

*****************************************************************************/

// UART (HD6350)
__sfr __at 0x10 UART_control;
__sfr __at 0x10 UART_status;
__sfr __at 0x11 UART_data;

// PPI (8255)
__sfr __at 0x20 PPI_PA;
__sfr __at 0x21 PPI_PB;
__sfr __at 0x22 PPI_PC;
__sfr __at 0x23 PPI_control;

// YM3806
__at 0xC000 unsigned char YM3806_status;
__at 0xC003 unsigned char YM3806_timer;

