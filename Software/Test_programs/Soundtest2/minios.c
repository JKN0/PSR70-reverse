/******************************************************************************

  Mini-OS
  =======
  
  Minimal "OS" for Z80 / PSR-70
  
  Includes:
    - Real-time interrupt (from YM3806) + timer functions
    - UART interrupt + send/receive functions

  13.2.2020

*****************************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "ioregs.h"
#include "minios.h"

/* =====================================================================
------------------------ Constants & macros ------------------------- */

#define MAX_TIMERS			10
#define FREE 				0
#define NOT_RUNNING			0xFFFFFFFF

#define INBUF_LEN  			20
#define OUTBUF_LEN  		256

#define CYCLIC_INC(p)   { p++; if (p >= (outbuf+OUTBUF_LEN)) p = outbuf; }

/* =====================================================================
------------------------  Global variables  ------------------------- */

static volatile uint32_t tick_ctr = 0;

static uint32_t timers[MAX_TIMERS];

static char outbuf[OUTBUF_LEN];
static char *outbuf_top = outbuf;
static char *outbuf_bot = outbuf;
static bool outbuf_full = false;

static char inbuf[INBUF_LEN];
static bool cr_received = false;

extern uint8_t reg00;

/* =====================================================================
------------------------ Function prototypes ------------------------ */

void putc_poll(char ch);

/* =====================================================================
MiniOS init
- SysTick
- USART1
- interrupts
--------------------------------------------------------------------- */

void init_minios(void)
{
    memset(timers,0,sizeof(timers));
}

/* =====================================================================
Allocate new timer, return handle
--------------------------------------------------------------------- */

HTIMER create_timer( void )
{
	uint8_t i;

    for (i = 0; i < MAX_TIMERS; i++)
    	if (timers[i] == FREE)
    	{
    		timers[i] = NOT_RUNNING;	// reserve timer
    		return i;
    	}

    return INVALID_HANDLE;
}

/* =====================================================================
Deallocate timer
--------------------------------------------------------------------- */

void free_timer( HTIMER ht)
{
  	timers[ht] = FREE;
}

/* =====================================================================
Start timer
--------------------------------------------------------------------- */

void start_timer( HTIMER ht, uint16_t ms_value)
{
    uint32_t tc;
    
	__critical { tc = tick_ctr; }
    
    timers[ht] = tc + ms_value;
}

/* =====================================================================
Stop timer. Stopped timer will not timeout.
--------------------------------------------------------------------- */

void stop_timer( HTIMER ht)
{
  	timers[ht] = NOT_RUNNING;
}

/* =====================================================================
Test timeout
--------------------------------------------------------------------- */

bool timeout( HTIMER ht)
{
    uint32_t tc;

    __critical { tc = tick_ctr; }
    
	if (tc >= timers[ht])
		return true;

	return false;
}

/* =====================================================================
Delay. Blocks here during delay.
--------------------------------------------------------------------- */

void delay( uint16_t ms_value )
{
    uint32_t tc;
    
    __critical { tc = tick_ctr; }
	uint32_t end_ticks = tc + ms_value;

	while (tc < end_ticks)
        __critical { tc = tick_ctr; };
}

/* =====================================================================
Interrupt handler. Handles three interrupts:
    - RTC from YM3806, 10 ms interval
    - serial tx from UART
    - serial rx from UART
--------------------------------------------------------------------- */

void intser(void) __critical __interrupt(0)
{
	static uint8_t idx = 0;
	uint8_t st;
	char ch;
    
    // RTC
    st = YM3806_status;
    if ((st & 0x05) != 0)
    {
        reg00 = st;
        YM3806_timer = 0x71;
        tick_ctr++;
    }
    
    // UART
    if ((UART_status & 0x80) != 0)
    {
        // --- UART send
        if ((UART_status & 0x02) != 0)
        {   
            // Anything to send?
            if (outbuf_bot != outbuf_top || outbuf_full)
            {
                ch = *outbuf_bot;
                CYCLIC_INC(outbuf_bot);
                outbuf_full = false;

                UART_data = ch;             // Transmit the character
            }
            else
                UART_control = 0x95;        // Suppress interrupt when buffer empty
        }
        
        // --- UART receive
        if ((UART_status & 0x01) != 0)
        {
            ch = UART_data;             // Receive the character
            
            ch &= 0x7F;

            if (ch == '\r')				// if CR -> line ready
            {
                inbuf[idx] = '\0';
                idx = 0;

                putchar('\r');	        // echo CR
                putchar('\n');

                cr_received = true;		    // full line received
            }
            else if (ch == '\b' && idx > 0)	// if BS -> remove char from buf
            {
                idx--;
                putchar('\b');	            // echo BS
                putchar(' ');
                putchar('\b');
            }
            else if (ch >= ' ')				// normal char
            {
                ch |= 0x20;		            // to lowercase

                if (idx < INBUF_LEN-1)		// to buf, if fits
                {
                    inbuf[idx] = ch;
                    idx++;

                    putchar(ch);	        // echo
                }
            }
            
        }
    }
}

/* =====================================================================
Get input line. Return NULL, if not available.
--------------------------------------------------------------------- */

char *get_input_line(void)
{
	if (cr_received)
	{
		cr_received = false;
		return inbuf;
	}

	return NULL;
}

/* =======================================================================
Output one char to tx buffer
----------------------------------------------------------------------- */

int putchar(int ch)
{
    __critical {
        if (!outbuf_full)
        {
            *outbuf_top = ch;

            CYCLIC_INC(outbuf_top);
            if (outbuf_bot == outbuf_top)
                outbuf_full = true;

            UART_control = 0xB5;        // Enable tx int
        }
    }
    
    return 0;
}

/* =======================================================================
Output one char to USART1
----------------------------------------------------------------------- */

void putc_poll(char ch)
{
    while ((UART_status & 0x02) == 0)
    	;

    UART_data = ch;             // Transmit the character
}

/* ============================ EOF ====================================== */
