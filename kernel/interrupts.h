#ifndef INTS_H
#define INTS_H

#include <stdint.h>

struct __attribute__((packed)) idtr {
    uint16_t limit;
    uint32_t base;
};

struct __attribute__((packed)) idt_entry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t zero;
    uint8_t type_attr;
    uint16_t offset_high;
};

void idt_init(void);

#endif
