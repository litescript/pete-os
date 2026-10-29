#include "interrupts.h"
extern void isr_breakpoint(void);

static struct idt_entry idt[256];

static void idt_set_entry(uint8_t vector, uint32_t handler) {
    idt[vector].offset_low = (uint16_t)handler;              // lower 16 bits
    idt[vector].offset_high = (uint16_t)(handler >> 16);    // upper 16 bits
    idt[vector].selector = 0x08;
    idt[vector].zero = 0;
    idt[vector].type_attr = 0x8E;
}

void idt_init(void) {
    struct idtr descriptor;
    descriptor.limit = sizeof(idt) - 1;
    descriptor.base = (uint32_t)&idt;

    idt_set_entry(3, (uint32_t)isr_breakpoint);

    __asm__ volatile ("lidt %0" : : "m"(descriptor) : "memory");
}

