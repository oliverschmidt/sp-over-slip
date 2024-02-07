/*

MIT License

Copyright (c) 2024 Oliver Schmidt (https://a2retro.de/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#include <string.h>
#include <stdio.h>
#include <pico/stdlib.h>

#include "sp.h"

#include "slip.h"

#define DRIVES      2
#define BLOCK_SIZE  512

#define SUCCESS     0x00
#define IO_ERROR    0x27
#define WRITE_PROT  0x2B

void slip_init(void) {
    printf("slip_init\r\n");
}

void __time_critical_func(slip_reset)(void) {
    printf("slip_reset\r\n");
}

void slip_status(uint8_t unit) {
    printf("slip_status(unit=$%02X)\r\n", unit);

    sp_buffer[0] = IO_ERROR;
    return;
/*
    sp_buffer[0] = SUCCESS;
    sp_buffer[1] = blocks % 0x100;
    sp_buffer[2] = blocks / 0x100;
*/
}

void slip_read(uint8_t unit, uint16_t block) {
    printf("slip_read(unit=$%02X,block=$%04X)\r\n", unit, block);

    sp_buffer[0] = IO_ERROR;
    return;
/*
    sp_buffer[0] = SUCCESS;
    memcpy((void *)&sp_buffer[1], source, BLOCK_SIZE);
*/
}

void slip_write(uint8_t unit, uint16_t block, const uint8_t *data) {
    printf("slip_write(unit=$%02X,block=$%04X)\r\n", unit, block);

    sp_buffer[0] = IO_ERROR;
    return;
/*
    sp_buffer[0] = SUCCESS;
    memcpy(target, data, BLOCK_SIZE);
*/
}
