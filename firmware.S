.FEATURE    c_comments
.FEATURE    labels_without_colons

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

LOC0    := $00
LOC1    := $01
CMD     := $42          ; DISK DRIVER COMMAND
UNIT    := $43          ; DISK DRIVER UNIT
BUFL    := $44          ; DISK DRIVER BUFFER
BUFH    := $45
BLOCKL  := $46          ; DISK DRIVER BLOCK
BLOCKH  := $47

MSLOT   := $07F8        ; BUFFER FOR HI SLOT ADDR (SCN)

DATA    := $C088        ; DATA REG
STAT    := $C089        ; STATUS REG

COUT    := $FDED        ; CHARACTER OUT (THRU CSW)
SETKBD  := $FE89        ; SETS KSW TO APPLE KEYBOARD
SETSCR  := $FE93        ; SETS CSW TO APPLE SCREEN
SLOOP   := $FABA        ; CONTINUE SLOT SCAN
SETTXT  := $FB39        ; SET TEXT MODE
HOME    := $FC58        ; CLEAR SCREEN AND HOME CURSOR
BASIC   := $E000        ; BASIC INTERPRETER COLD START

.REPEAT 8, SLOT
.SCOPE

        .ORG $C000|$0100*SLOT

        CPY #$20        ; $Cn01:$20
        LDY #$00        ; $Cn03:$00
        CPY #$03        ; $Cn05:$03
        CPY #$3C        ; $Cn07:$3C

        LDA #>*
        STA $07F8       ; MSLOT
        BIT $CFFF       ; CLRROM
        LDX #$10*SLOT   ; DRIVE 1
        JSR BOOTPRP     ; BOOT PREPARE
        JSR DRIVER      ; READ BLOCK 0 FROM DRIVE 1 TO $0800
        JMP BOOTCNT     ; BOOT CONTNUE

DRIVER  LDA CMD
        STA DATA|$10*SLOT
        LDA UNIT
        STA DATA|$10*SLOT
        LDA BLOCKL
        STA DATA|$10*SLOT
        LDA BLOCKH
        STA DATA|$10*SLOT

        LDY CMD         ; STATUS?
        BNE NOSTATUS

        ; PRODOS STATUS COMMAND
        JSR RETCODE     ; GET RETURN CODE
        BNE :+          ; ERROR?
        LDX DATA|$10*SLOT ; SIZE LO
        LDY DATA|$10*SLOT ; SIZE HI
:       CMP #$01        ; SUCCESS?
        RTS

NOSTATUS DEY            ; READ?
        BNE NOREAD

        ; PRODOS READ COMMAND
        JSR RETCODE     ; GET RETURN CODE
        BNE :+          ; ERROR?
        JSR RDBLOCK     ; READ 512 BYTE BLOCK
        LDA #$00        ; SUCCESS
:       CMP #$01        ; SUCCESS?
        RTS

        ; PRODOS WRITE COMMAND
NOREAD  JSR WRBLOCK     ; WRITE 512 BYTE BLOCK
        JSR RETCODE     ; GET RETURN CODE
        CMP #$01        ; SUCCESS?
        RTS

RETCODE LDA #$01
        STA STAT|$10*SLOT
:       LDA STAT|$10*SLOT
        BPL :-
        LDA DATA|$10*SLOT ; RETURN CODE
        RTS

RDBLOCK LDY #$00
        JSR RDPAGE
        INC BUFH
RDPAGE  LDA DATA|$10*SLOT
        STA (BUFL),Y
        INY
        BNE RDPAGE
        RTS

WRBLOCK LDY #$00
        JSR WRPAGE
        INC BUFH
WRPAGE  LDA (BUFL),Y
        STA DATA|$10*SLOT
        INY
        BNE WRPAGE
        RTS

        .RES $0100-4-<* ; THE 4 BYTES BELOW GO TO THE END OF THE SLOT ROM

        .BYTE $00,$00   ; TOTAL BLOCKS
        .BYTE $F7       ; STATUS BYTE
        .BYTE <DRIVER

.ENDSCOPE
.ENDREP

        .ORG $C800

BOOTPRP STY BLOCKL      ; Y IS 0
        STY BLOCKH
        STY BUFL
        INY             ; 1 MEANS READ
        STY CMD
        LDY #>$0800
        STY BUFH
        STX UNIT        ; DRIVE 1
        RTS

BOOTCNT BCS FAILURE
        LDY $0800       ; NUMBER OF DISK II SECTORS TO READ
        DEY
        BNE FAILURE     ; ... MUST BE 1
        LDY $0801       ; FIRST OPCODE
        BEQ FAILURE     ; ... MUSTN'T BE BRK
        JMP $0801       ; GO FOR IT (X IS STILL DRIVE 1)

FAILURE LDY LOC0        ; POTENTIAL AUTOSTART SCAN ROM PTR LO
        BNE ERREXIT     ; ... MUST POINT TO A SLOT ROM START
        LDY LOC1        ; POTENTIAL AUTOSTART SCAN ROM PTR HI
        CPY MSLOT
        BNE ERREXIT     ; ... MUST POINT TO CURRENT SLOT ROM
        JMP SLOOP       ; LOOKS LIKE AUTOSTART SCAN SO CONTINUE SCAN

ERREXIT JSR SETSCR
        JSR SETKBD
        JSR SETTXT
        JSR HOME
        LDY #$08        ; 'HDD ERROR'
:       LDA ERRTEXT,Y
        JSR COUT
        DEY
        BPL :-
        JMP BASIC

ERRTEXT .BYTE 'R'|$80, 'O'|$80, 'R'|$80, 'R'|$80, 'E'|$80, ' '|$80, 'D'|$80, 'D'|$80, 'H'|$80

        .RES $D000-*
