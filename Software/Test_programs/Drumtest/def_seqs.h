/******************************************************************************

  RYP4 sound tests in PSR-70

  Default sequences for controlling YM2154, taken from the original sw.

  SDCC Z80

  9.2.2021

*****************************************************************************/

typedef struct seq_item_t {
    uint8_t reg;
    uint8_t val;
} SEQ_ITEM_T;

// Initialization sequence
const SEQ_ITEM_T def_init_seq[100] = {
    { 0x01,0x00 },
    { 0x02,0x80 },
    { 0x03,0x00 },
    { 0x04,0x3F },
    { 0x07,0x01 },
    { 0x03,0x40 },
    { 0x10,0x60 },
    { 0x11,0x60 },
    { 0x12,0x60 },
    { 0x13,0x60 },
    { 0x14,0x60 },
    { 0x15,0x60 },
    { 0x18,0x60 },
    { 0x19,0x60 },
    { 0x1A,0x60 },
    { 0x1B,0x60 },
    { 0x1C,0x60 },
    { 0x1D,0x60 },
    { 0x1D,0x60 },
    { 0x3D,0x1E },
    { 0x45,0xC1 },
    { 0x4D,0xFF },
    { 0x0D,0xAD },
    { 0x1C,0x60 },
    { 0x3C,0x0E },
    { 0x44,0xC1 },
    { 0x4C,0x1B },
    { 0x0C,0xAD },
    { 0x1B,0x60 },
    { 0x3B,0x0B },
    { 0x43,0xC0 },
    { 0x4B,0xEB },
    { 0x0B,0xCD },
    { 0x1A,0x60 },
    { 0x3A,0x19 },
    { 0x42,0xC1 },
    { 0x4A,0xEB },
    { 0x0A,0xAD },
    { 0x19,0x60 },
    { 0x39,0x18 },
    { 0x41,0x81 },
    { 0x49,0x9B },
    { 0x09,0xCD },
    { 0x18,0x60 },
    { 0x38,0x00 },
    { 0x40,0x00 },
    { 0x48,0x77 },
    { 0x08,0xED },
    { 0x15,0x60 },
    { 0x25,0x15 },
    { 0x2D,0x81 },
    { 0x35,0x63 },
    { 0x0D,0xA5 },
    { 0x14,0x60 },
    { 0x24,0x1D },
    { 0x2C,0x01 },
    { 0x34,0xFF },
    { 0x0C,0xAA },
    { 0x13,0x60 },
    { 0x23,0x1A },
    { 0x2B,0x81 },
    { 0x33,0xCF },
    { 0x0B,0xC2 },
    { 0x12,0x60 },
    { 0x22,0x00 },
    { 0x2A,0x00 },
    { 0x32,0xF7 },
    { 0x0A,0xAD },
    { 0x11,0x60 },
    { 0x21,0x16 },
    { 0x29,0x41 },
    { 0x31,0x73 },
    { 0x09,0xC6 },
    { 0x10,0x60 },
    { 0x20,0x19 },
    { 0x28,0x81 },
    { 0x30,0xA7 },
    { 0x08,0xE8 },
    { 0x04,0x3F },
    { 0x02,0xE2 },
    { 0x02,0x0F },
    { 0x1B,0x76 },
    { 0x1B,0x76 },
    { 0x3B,0x0B },
    { 0x43,0xC0 },
    { 0x4B,0xEB },
    { 0x0B,0xC2 },
    { 0x04,0x3F },
    { 0x04,0x3F },
    { 0,0 }
};

// Trigger sequence, bass drum (A3)
const SEQ_ITEM_T def_trig_seq[5] = {
    { 0x05,0x00 },
    { 0x10,0x1A },
    { 0x06,0x01 },
    { 0,0 }
};
