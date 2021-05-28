/******************************************************************************

  RYP4 (YM2154) sound tests in PSR-70

  This is a serial port UI to modify RYP4 registers.

  SDCC Z80

  8.2.2021

*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "ioregs.h"
#include "minios.h"
#include "def_seqs.h"

/* =====================================================================
------------------------ Constants & macros ------------------------- */

#define PLAY_OFF    0
#define PLAY_ON     1
#define PLAY_CONT   2

#define EI      __asm EI __endasm;

/* =====================================================================
--------------------------  Typedefs  ------------------------------- */

/* =====================================================================
------------------------  Global variables  ------------------------- */

uint8_t play_mode = PLAY_OFF;

SEQ_ITEM_T init_seq[100];
SEQ_ITEM_T trig_seq[5];

uint8_t reg_tbl[128];

uint8_t cur_tempo = 0;
uint8_t reg0E = 0;

/* =====================================================================
------------------------ Function prototypes ------------------------ */

void serial_ui_task( void );
void play_task( void );
void init_reg_tbl( void );
void start_test( void );
void update_seqs( uint8_t regnr, uint8_t regval );
void set_reg_to_seq( SEQ_ITEM_T *seq, uint8_t regnr, uint8_t regval, uint8_t from );
void set_default_seqs( void );
void print_op_status( void );
void write_RYP_seq( SEQ_ITEM_T *seq );
void write_RYP_reg( uint8_t regnr, uint8_t regval );
uint8_t read_RYP_reg( uint8_t regnr );
void delayloop( int ms );

void init_hw( void );

/* =====================================================================
Main program
--------------------------------------------------------------------- */

int main()
{
    delayloop(20);
    init_hw();
    init_minios();
    EI;

    printf("\r\n*** Drumtest ***\r\n");

    init_reg_tbl();
    set_default_seqs();

    while(1)
    {
        serial_ui_task();
        play_task();
    }
}

/* =====================================================================
Serial UI task
--------------------------------------------------------------------- */

void serial_ui_task( void )
{
    char *line;
    char *nextp;
    uint8_t regnr,regval;

    // if input line not ready, do nothing
    line = get_input_line();
    if (line == NULL)
        return;

    switch (line[0])
    {
    case 'r':   // Register set
        regnr = (uint8_t)strtol(&line[1], &nextp, 16);
        if (*nextp == '\0')
            printf("No regval?\r\n");
        else
        {
            regval = (uint8_t)strtol(nextp, NULL, 16);
            printf("Set %02X=%02X\r\n",regnr,regval);
            update_seqs(regnr,regval);
            write_RYP_reg(regnr,regval);
        }
        break;

    case 'v':   // register Value, from table
        regnr = (uint8_t)strtol(&line[1], NULL, 16);
        printf("Value %02X=%02X\r\n",regnr,reg_tbl[regnr]);
        break;

    case 'g':   // register Get, from RYP
        regnr = (uint8_t)strtol(&line[1], NULL, 16);
        regval = read_RYP_reg(regnr);
        printf("Read %02X=%02X\r\n",regnr,regval);
        break;

    case 'p':
        printf("Single play\r\n");
        play_mode = PLAY_ON;
        break;

    case 'c':
        printf("Continuous play\r\n");
        play_mode = PLAY_CONT;
        break;

    case 's':
        printf("Stop play\r\n");
        play_mode = PLAY_OFF;
        break;

    case 'd':
        printf("Init all seqs\r\n");
        set_default_seqs();
        break;

    case 't':
        printf("Start test\r\n");
        start_test();
        break;

    case 'f':
        printf("Tempo %d\r\n",cur_tempo);
        break;

    case 'e':
        printf("Reg 0E=%02X\r\n",reg0E);
        break;

    case 'h':
        printf("Commands: r,g,v,p,c,s,d,t,f,e\r\n");
        break;
    }
}

/* =====================================================================
Note play task
--------------------------------------------------------------------- */

void play_task( void )
{
    static bool init_done = false;
    static HTIMER delay_timer;
    static uint8_t prev_play_mode = PLAY_OFF;
    static bool cont_mode = false;

    if (!init_done)
    {
        delay_timer = create_timer();
        start_timer(delay_timer,10);

        init_done = true;
        return;
    }

    if (cont_mode)
    {
        if (timeout(delay_timer))
        {
            start_timer(delay_timer,100);
            write_RYP_seq(trig_seq);
        }
    }

    if (play_mode == prev_play_mode)
        return;

    switch (play_mode)
    {
    case PLAY_ON:
        write_RYP_seq(trig_seq);
        cont_mode = false;
        play_mode = PLAY_OFF;
        break;

    case PLAY_OFF:
        cont_mode = false;
        break;

    case PLAY_CONT:
        cont_mode = true;
        break;
    }

    prev_play_mode = play_mode;
}

/* =====================================================================
Init register table
--------------------------------------------------------------------- */

void init_reg_tbl( void )
{
    memset(reg_tbl,0x00,sizeof(reg_tbl));
}

/* =====================================================================
Set test settings
--------------------------------------------------------------------- */

void start_test( void )
{
}

/* =====================================================================
Update given register value to all sequences.
--------------------------------------------------------------------- */

void update_seqs( uint8_t regnr, uint8_t regval )
{
    set_reg_to_seq(init_seq,regnr,regval,0);
    set_reg_to_seq(trig_seq,regnr,regval,0);
}

/* =====================================================================
Update given register value to given sequence
--------------------------------------------------------------------- */

void set_reg_to_seq( SEQ_ITEM_T *seq, uint8_t regnr, uint8_t regval, uint8_t from )
{
    uint8_t found_cnt = 0;

    while (seq->reg != 0)
    {
        if (seq->reg == regnr)
        {
            if (found_cnt >= from)
                seq->val = regval;

            found_cnt++;
        }

        seq++;
    }
}

/* =====================================================================
Initialize sequences and YM2154
--------------------------------------------------------------------- */

void set_default_seqs( void )
{
    memcpy(init_seq,def_init_seq,sizeof(def_init_seq));
    memcpy(trig_seq,def_trig_seq,sizeof(def_trig_seq));

    write_RYP_seq(init_seq);
}

/* =====================================================================
Write sequence to YM2154
--------------------------------------------------------------------- */

void write_RYP_seq( SEQ_ITEM_T *seq )
{
    SEQ_ITEM_T *sp = seq;

    while (sp->reg != 0)
    {
        write_RYP_reg(sp->reg,sp->val);
        sp++;
    }
}

/* =====================================================================
Write one register to YM2154
--------------------------------------------------------------------- */

void write_RYP_reg( uint8_t regnr, uint8_t regval )
{
    // Don't know a way to do indirect OUT in SDCC,
    // so this is done in assembly
    __asm

    ; regnr from stack
    ld    hl,#2
    add   hl,sp
    ld    a,(hl)
    or    a,#0x80
    ld    c,a             ; C = regnr | 80H

    ; regval from stack
    ld    iy,#3
    add   iy,sp
    ld    a, 0 (iy)       ; A = regval

    ; out to RYP chip
    out   (c),a

    __endasm;

    reg_tbl[regnr] = regval;
}

/* =====================================================================
Read one register from YM2154
--------------------------------------------------------------------- */

// disable: warning 59: function 'read_RYP_reg' must return value
#pragma save
#pragma disable_warning 59

uint8_t read_RYP_reg( uint8_t regnr )
{
    regnr;

    // Don't know a way to do indirect IN in SDCC,
    // so this is done in assembly
    __asm
    ; regnr from stack
    ld    hl,#2
    add   hl,sp
    ld    a,(hl)
    or    a,#0x80
    ld    c,a         ; C = regnr | 80H

    in    l,(c)       ; return value in L
    __endasm;

    return;
}
#pragma restore

/* =====================================================================
Delay with busy loop
--------------------------------------------------------------------- */

void delayloop( int ms )
{
    int i,j;

    for (i = 0; i < ms; i++)
        for (j = 0; j < 158; j++)
            ;
}

/* =====================================================================
Hardware init
--------------------------------------------------------------------- */

void init_ppi( void )
{
    PPI_control = 0x90;     // 8255 control: mode 0, PA=in, PB=out PC=out
    PPI_PC = 0x80;          // PC7 controls some chip resets, must be high
    delayloop(100);
}

/* ------------------------------------------------------------------ */

void init_uart( void )
{
    UART_control = 0x00;
    UART_control = 0x00;
    UART_control = 0x00;
    UART_control = 0x03;
    delayloop(10);
    UART_control = 0x95;
}

/* ------------------------------------------------------------------ */

void init_hw( void )
{
    init_ppi();
    init_uart();

    YM3806_timer = 0x71;
}

/* ============================ EOF ====================================== */
