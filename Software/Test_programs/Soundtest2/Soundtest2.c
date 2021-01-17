/******************************************************************************

  YM3806 sound tests in PSR-70
  
  This is a serial port UI to modify YM3806 registers.
  
  SDCC Z80

  15.2.2020

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
#define PLAY_VAR    3

#define EI      __asm EI __endasm;

/* =====================================================================
--------------------------  Typedefs  ------------------------------- */

typedef struct timer_t {
    uint8_t state;
    uint16_t tick;
} TIMER_T;

/* =====================================================================
------------------------  Global variables  ------------------------- */

uint8_t play_mode = PLAY_OFF;

SEQ_ITEM_T init_seq[450];
SEQ_ITEM_T note_on_seq[25];
SEQ_ITEM_T note_off_seq[10];

uint8_t reg05 = 0x79;
uint8_t reg00 = 0;

/* =====================================================================
------------------------ Function prototypes ------------------------ */

void serial_ui_task( void );
void play_task( void );
void start_test( void );
void update_seqs( uint8_t regnr, uint8_t regval );
void set_reg_to_seq( SEQ_ITEM_T *seq, uint8_t regnr, uint8_t regval, uint8_t from );
void print_reg_from_seqs( uint8_t regnr );
bool print_reg_from_seq( SEQ_ITEM_T *seq, uint8_t regnr );
void set_default_seqs( void );
void print_op_status( void );
void write_YM3806_seq( SEQ_ITEM_T *seq );
void write_YM3806_reg( uint8_t regnr, uint8_t regval );
uint8_t read_YM3806_reg( uint8_t regnr );
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
    
	printf("\r\n*** Soundtest2 ***\r\n");
    
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
    case 'r':
        regnr = (uint8_t)strtol(&line[1], &nextp, 16);
        if (*nextp == '\0')
            printf("No regval?\r\n");
        else
        {
            regval = (uint8_t)strtol(nextp, NULL, 16);
            printf("Set %02X=%02X\r\n",regnr,regval);
            if (regnr == 0x05)
            {
                reg05 = regval;
                write_YM3806_reg(regnr,regval);
            }
            else if (regnr == 0xE1 || regnr == 0xE9 || regnr == 0xF1 || regnr == 0xF9)
            {
                set_reg_to_seq(init_seq,regnr,regval,0);
                set_reg_to_seq(note_off_seq,regnr,regval,0);
                printf("Setting only to init_seq and note_off_seq\r\n");
            }
            else
            {
                update_seqs(regnr,regval);
                write_YM3806_reg(regnr,regval);
            }
        }
        break;
        
    case 'f':
        regnr = (uint8_t)strtol(&line[1], &nextp, 16);
        if (*nextp == '\0')
            printf("No regval?\r\n");
        else
        {
            regval = (uint8_t)strtol(nextp, NULL, 16);

            if (regnr == 0xE1 || regnr == 0xE9 || regnr == 0xF1 || regnr == 0xF9)
            {
                set_reg_to_seq(note_on_seq,regnr,regval,1);
                printf("Set %02X=%02X to note_on_seq\r\n",regnr,regval);
            }
            else
            {
                printf("Reg %02X is not in note_on_seq\r\n",regnr);
            }
        }
        break;
        
    case 'g':
        regnr = (uint8_t)strtol(&line[1], NULL, 16);
        print_reg_from_seqs(regnr);
        if (regnr == 0x05)
            printf("internal: %02X\r\n",reg05);
        break;
        
    case 'm':
        regnr = (uint8_t)strtol(&line[1], NULL, 16);
        regval = read_YM3806_reg(regnr);
        printf("Read %02X=%02X\r\n",regnr,regval);
        break;
        
    case 'i':
        printf("Reg00=%02X\r\n",reg00);
        break;
        
    case 'p':
        printf("Start play\r\n");
        play_mode = PLAY_ON;
        break;
        
    case 's':
        printf("Stop play\r\n");
        play_mode = PLAY_OFF;
        break;
        
    case 'c':
        printf("Continuous play\r\n");
        play_mode = PLAY_CONT;
        break;
        
    case 'v':
        printf("Varying notes play\r\n");
        play_mode = PLAY_VAR;
        break;
        
    case 'd':
        printf("Init all seqs\r\n");
        set_default_seqs();
        break;
        
    case 'l':
        print_op_status();
        break;
        
    case 't':
        printf("Start test\r\n");
        start_test();
        break;
        
    case 'h':
        printf("Commands: r,g,l,p,s,c,d\r\n");
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
	static bool var_mode = false;
	static bool note_on = false;
	static uint8_t oct = 2;
    uint8_t regval;

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
            note_on = !note_on;
            
            if (note_on)
            {
                start_timer(delay_timer,100);

                if (var_mode)
                {
                    regval = (oct << 4) | 0x04;
                    set_reg_to_seq(note_on_seq,0x21,regval,0);
                    
                    oct++;
                    if (oct > 7)
                        oct = 2;
                }

                write_YM3806_seq(note_on_seq);
            }
            else
            {
                start_timer(delay_timer,50);
                write_YM3806_seq(note_off_seq);
            }
        }
    }
    
    if (play_mode == prev_play_mode)
        return;

    switch (play_mode)
    {
    case PLAY_ON:
        set_reg_to_seq(note_on_seq,0x21,0x44,0);
        write_YM3806_seq(note_on_seq);
        cont_mode = false;
        break;
        
    case PLAY_OFF:
        write_YM3806_seq(note_off_seq);
        cont_mode = false;
        break;
        
    case PLAY_CONT:
        cont_mode = true;
        var_mode = false;
        note_on = false;
        set_reg_to_seq(note_on_seq,0x21,0x44,0);
        break;
        
    case PLAY_VAR:
        cont_mode = true;
        var_mode = true;
        note_on = false;
        oct = 2;
        break;
    }
    
    prev_play_mode = play_mode;
}

/* =====================================================================
Set test settings
--------------------------------------------------------------------- */

void start_test( void )
{
    update_seqs(0x11,0x7D);          // chorus off
    update_seqs(0x41,0x81);          // factors = 1
    update_seqs(0x49,0x81);
    update_seqs(0x51,0x81);
    update_seqs(0x59,0x81);
    update_seqs(0x61,0xFF);          // levels
    update_seqs(0x69,0xFF);
    update_seqs(0x71,0xFF);
    update_seqs(0x79,0x00);
    
    write_YM3806_seq(init_seq);
}

/* =====================================================================
Update given register value to all sequences. 
--------------------------------------------------------------------- */

void update_seqs( uint8_t regnr, uint8_t regval )
{
    set_reg_to_seq(note_on_seq,regnr,regval,0);
    set_reg_to_seq(init_seq,regnr,regval,0);
    set_reg_to_seq(note_off_seq,regnr,regval,0);
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
Scan all sequences for given reg nr and print if found
--------------------------------------------------------------------- */

void print_reg_from_seqs( uint8_t regnr )
{
    printf("init_seq: ");
    if (print_reg_from_seq(init_seq,regnr) == false)
        printf("none");
    printf("\r\n");
    
    printf("note_on_seq: ");
    if (print_reg_from_seq(note_on_seq,regnr) == false)
        printf("none");
    printf("\r\n");
    
    printf("note_off_seq: ");
    if (print_reg_from_seq(note_off_seq,regnr) == false)
        printf("none");
    printf("\r\n");
}

/* =====================================================================
Print all given register values from given sequence
--------------------------------------------------------------------- */

bool print_reg_from_seq( SEQ_ITEM_T *seq, uint8_t regnr )
{
    bool found = false;
    
    while (seq->reg != 0)
    {
        if (seq->reg == regnr)
        {
            printf("%02X=%02X ",regnr,seq->val);
            found = true;
        }
        
        seq++;
    }
    
    return found;
}

/* =====================================================================
Initialize sequences and YM3806
--------------------------------------------------------------------- */

void set_default_seqs( void )
{
    memcpy(init_seq,def_init_seq,sizeof(def_init_seq));
    memcpy(note_on_seq,def_note_on_seq,sizeof(def_note_on_seq));
    memcpy(note_off_seq,def_note_off_seq,sizeof(def_note_off_seq));
    reg05 = 0x79;
    
    write_YM3806_seq(init_seq);
}

/* =====================================================================
Print summary of operator status
--------------------------------------------------------------------- */

void print_op_status( void )
{
    if ((reg05 & 0x08) != 0)
        printf("OP0: ON,  levels: ");
    else
        printf("OP0: OFF, levels: ");
    print_reg_from_seq(init_seq,0xE1);
    print_reg_from_seq(init_seq,0x61);
    printf("\r\n");
    
    if ((reg05 & 0x10) != 0)
        printf("OP1: ON,  levels: ");
    else
        printf("OP1: OFF, levels: ");
    print_reg_from_seq(init_seq,0xE9);
    print_reg_from_seq(init_seq,0x69);
    printf("\r\n");
    
    if ((reg05 & 0x20) != 0)
        printf("OP2: ON,  levels: ");
    else
        printf("OP2: OFF, levels: ");
    print_reg_from_seq(init_seq,0xF1);
    print_reg_from_seq(init_seq,0x71);
    printf("\r\n");
    
    if ((reg05 & 0x40) != 0)
        printf("OP3: ON,  levels: ");
    else
        printf("OP3: OFF, levels: ");
    print_reg_from_seq(init_seq,0xF9);
    print_reg_from_seq(init_seq,0x79);
    printf("\r\n");
}

/* =====================================================================
Write sequence to YM3806
--------------------------------------------------------------------- */

void write_YM3806_seq( SEQ_ITEM_T *seq )
{
    SEQ_ITEM_T *sp = seq;
    
    while (sp->reg != 0)
    {
        write_YM3806_reg(sp->reg,sp->val);
        sp++;
    }
    
    if (seq == note_on_seq)
    {
        write_YM3806_reg(0x05,reg05);
    }
}

/* =====================================================================
Write one register to YM3806
--------------------------------------------------------------------- */

void write_YM3806_reg( uint8_t regnr, uint8_t regval )
{
    uint8_t *regp = (uint8_t *)(0xC000);
    
    while ((*regp & 0x80) != 0)
        ;
    
    regp = (uint8_t *)(0xC000 + regnr);
    *regp = regval;
}

/* =====================================================================
Read one register from YM3806
--------------------------------------------------------------------- */

uint8_t read_YM3806_reg( uint8_t regnr )
{
    uint8_t *regp = (uint8_t *)(0xC000 + regnr);

    return *regp;
}

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
