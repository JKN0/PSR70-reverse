/******************************************************************************

  Mini-OS
  =======
  
  Minimal "OS" for Z80 / PSR-70
  
  13.2.2020

*****************************************************************************/

#include <stdbool.h>

#define INVALID_HANDLE		99

typedef uint8_t HTIMER;

void init_minios(void);

HTIMER create_timer(void);
void free_timer( HTIMER ht);
void start_timer( HTIMER ht, uint16_t ms_value );
void stop_timer( HTIMER ht);
bool timeout( HTIMER ht);
void delay( uint16_t ms_value );

char *get_input_line(void);

