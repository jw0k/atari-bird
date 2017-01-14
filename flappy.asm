    icl "equates.asm"

.IFDEF INCLUDE_CASLOADER
    icl "casloader.asm"
.ENDIF

PROGSTART = $600
ANTICDLSTART = $B000
SCREENSTART = $B060 ;($B060 - ~$B400) remember about 12 bit screen memory counter in ANTIC (4k boundary)
PLAYERSTORE = $B400
PLAYERS = $B800 ;this value will be written to PMBASE; it must be on 2K boundary (1K for double-line player resolution)

;screen width in characters;
;normally screen is 32 characters wide in narrow mode, however we need 4 sentinel characters
;before the left edge of the screen and 4 after the right to support pipe clipping
SCRW = 40

CHARSET = $6000; $6000-$ABFF

/*
PCOLR0 = $2C0 ;COLPM0 = $D012, color of player 0 and missile 0
PCOLR1 = $2C1 ;COLPM1 = $D013, color of player 1 and missile 1
PCOLR2 = $2C2 ;COLPM2 = $D014, color of player 2 and missile 2
PCOLR3 = $2C3 ;COLPM3 = $D015, color of player 3 and missile 3

COLOR4 = $2C8 ;COLBK = $D01A
COLOR0 = $2C4 ;COLPF0 = $D016
COLOR1 = $2C5 ;COLPF1 = $D017
COLOR2 = $2C6 ;COLPF2 = $D018
COLOR3 = $2C7 ;COLPF3 = $D019, this is also the color of the fifth player
*/

/*
DOSVEC = $0A
MEMLO = $02E7 ;=$0700; bottom of free memory
APPMHI = $E ;top of BASIC program. screen handler will not write memory below it

RAMTOP = $6A ;=160 ($A0); RAM size in pages (1 byte);
RAMSIZ = $2E4 ;=160 ($A0); RAM size in pages (1 byte);
;lowering RAMTOP or RAMSIZ can be used to reserve RAM (OS will place DL&screen below RAMTOP/RAMSIZ)

BASIC_MEMTOP = $90 ;pointer to the top of BASIC program
OS_MEMTOP = $2E5 ;pointer to last byte of free ram. display list start 1 byte after
SAVMSC = $58 ;pointer to the first byte of screen data
TXTMSC = $294 ;pointer to the first byte of text window data
*/

;-------RMT stuff------
STEREOMODE = 0

    icl "rmtplayr.a65"
    opt h-
    ins "sunset1.rmt" ;sunset1.rmt loads at $4800
    opt h+

MODUL = $4800
;----------------------

    org PROGSTART

codestart

    ;disable ANTIC's bullshit
    mva #$00 NMIEN
    mva #$00 DMACTL

    jsr generateScreenData
    jsr generateCharset
    jsr clearPlayer

    ldx #<MODUL
	ldy #>MODUL
	lda #0 ;starting song line
	jsr RASTERMUSICTRACKER ;init

    mva #>PLAYERS PMBASE

    mva #$00 COLPM0
    mva #$00 COLPM1
    mva #$FA COLPM2 ;1C, 2B, FA
    mva #$0E COLPM3 ;0E, DE

    ;mva #$01 SIZEP0
    ;mva #$01 SIZEP1
    ;mva #$01 SIZEP2
    mva #$01 SIZEP3

    mva #1 PRIOR ;players on top of the playfield

    ;set new address of antic's display list
    mwa	#antic_dl DLISTL

    mva #>CHARSET CHBASE
    mva #$0E COLPF0 ;chmury, bardzo jasna rura;   01
    mva #$B8 COLPF1 ;trawa, okna, jasna rura;     10
    mva #$98 COLPF2 ;niebo, budynki;              11
    mva #$B4 COLPF3 ;ciemna trawa, rura;          11 (+high bit ustawiony w screen data)
    mva #$00 COLBK  ;tlo, ciemna rura;            00

    mwa #DLI VDSLST ;set vector of DLI handler

    ;mva #$21 DMACTL ;set narrow playfield (while keeping instruction DMA enabled)
    mva #%00111001 DMACTL ;set narrow playfield (while keeping instruction DMA enabled), enable player DMA, enable missile DMA, single line resolution
    ;bits 0-1 playfield on/off/width
    ;bit 2 - missile DMA
    ;bit 3 - player DMA
    ;bit 4 - one line player res
    ;bit 5 - instr DMA

    mva #$02 GRACTL ;turn on players in GTIA

    sei ;turn off IRQs
    mva #$FE PORTB ;disable ROM ($C000-$CFFF, $D800-$FFFF)
    mwa #NMI $FFFA ;set 6502 NMI vector
    mwa #IRQ $FFFE ;set 6502 IRQ vector
    mva #$40 IRQEN ;enable only keyboard interrupts in POKEY (PIA interrupts are not used by OS)
    mva #$80 NMIEN ;turn on NMIs (only DLI, no VBI!)
    cli ;turn on IRQs

loop
    jmp loop


;=============================================================
;---------------- generate charset ---------------------------
;=============================================================
generateCharset
                pha
                txa
                pha

                ldx #0

                .rept 6,#
                ;-------- generate charset #0 --------
                ;merge charset0 with left pipe edge
                ;ldx #0 ;x already 0
@               lda charset:1,x
                and #$C0
                ora #$06
                sta charset:1+8*32,x
                inx
                bne @-

                ;merge charset0 with right pipe edge
                ;ldx #0 ;x already 0 at this point
@               lda charset:1,x
                and #$03
                sta charset:1+8*64,x
                inx
                bne @-

                // $06
                // $AF
                // $FF
                // $00
                ;-------------------------------------


                ;-------- generate charset #1 & #3 ---
                ;copy background
                ;ldx #0 ;x already 0 at this point
@               lda charset:1,x
                sta charset:1a,x
                inx
                bne @-

                ;merge charset0 with left pipe edge (offset 1)
                ;ldx #0 ;x already 0
@               lda charset:1,x
                and #$F0
                ora #$01
                sta charset:1a+8*32,x
                inx
                bne @-

                ;merge charset0 with right pipe edge (offset 3)
                ;ldx #0 ;x already 0 at this point
@               lda charset:1,x
                and #$0F
                sta charset:1a+8*64,x
                inx
                bne @-
                ;-------------------------------------


                ;-------- generate charset #2 --------
                ;copy background
                ;ldx #0 ;x already 0 at this point
@               lda charset:1,x
                sta charset:1b,x
                inx
                bne @-

                ;merge charset0 with left pipe edge (offset 2)
                ;ldx #0 ;x already 0
@               lda charset:1,x
                and #$FC
                sta charset:1b+8*32,x
                inx
                bne @-

                ;merge charset0 with right pipe edge (offset 2)
                ;ldx #0 ;x already 0
@               lda charset:1,x
                and #$3F
                sta charset:1b+8*64,x
                inx
                bne @-
                ;-------------------------------------
                .endr


                ;------- copy other pipe elements -----
                ;ldx #0 ;x already 0
@               lda charset0+8*96,x
                sta charset1+8*96,x
                sta charset2+8*96,x
                sta charset3+8*96,x
                sta charset4+8*96,x
                sta charset5+8*96,x
                inx
                cpx #(8*10)
                bne @-

                ldx #0
@               lda charset0a+8*96,x
                sta charset1a+8*96,x
                sta charset2a+8*96,x
                sta charset3a+8*96,x
                sta charset4a+8*96,x
                sta charset5a+8*96,x
                inx
                cpx #(8*18)
                bne @-

                ldx #0
@               lda charset0b+8*96,x
                sta charset1b+8*96,x
                sta charset2b+8*96,x
                sta charset3b+8*96,x
                sta charset4b+8*96,x
                sta charset5b+8*96,x
                inx
                cpx #(8*9)
                bne @-
                ;----------------------------------------

                pla
                tax
                pla
                rts

;=============================================================
;---------------- generate screen data -----------------------
;=============================================================
generateScreenData
                pha
                txa
                pha

                ;fill 15 mode lines (15*40 = 600 characters)
                ;480 = 256 + 256 + 88

                lda #0
                ldx #0
@               sta SCREENSTART, x
                inx
                bne @-

                ;ldx #0
@               sta SCREENSTART+256, x
                inx
                bne @-

                ;ldx #0
@               sta SCREENSTART+512, x
                inx
                cpx #88
                bne @-

                .rept 5, (#*SCRW)
                lda #0
                ldx #0
@               sta SCREENSTART+600+:1+4, x
                clc
                adc #1
                inx
                cpx #32
                bne @-
                .endr

                lda #$80
                ldx #0
@               sta SCREENSTART+800+4, x
                clc
                adc #1
                inx
                cpx #32
                bne @-

                lda #1
                ldx #31
@               sta SCREENSTART+840+4, x
                dex
                bpl @-

                pla
                tax
                pla
                rts

;=============================================================
;------------ prepare data for pipe1  ------------------------
;=============================================================
prepareDataForPipe1
                pha

                ;up
                lda #114
                sta pipeEndsCharNums+42
                lda #115
                sta pipeEndsCharNums+46
                lda #105
                sta pipeEndsCharNums+47
                lda #106
                sta pipeEndsCharNums+51
                lda #116
                sta pipeEndsCharNums+52
                lda #117
                sta pipeEndsCharNums+56

                lda #114+128
                sta pipeEndsCharNums+61
                lda #115+128
                sta pipeEndsCharNums+65
                lda #105+128
                sta pipeEndsCharNums+66
                lda #106+128
                sta pipeEndsCharNums+70
                lda #116+128
                sta pipeEndsCharNums+71
                lda #117+128
                sta pipeEndsCharNums+75


                ;down
                lda #114
                sta pipeEndsCharNums+42+76
                lda #115
                sta pipeEndsCharNums+46+76
                lda #105
                sta pipeEndsCharNums+47+76
                lda #106
                sta pipeEndsCharNums+51+76
                lda #116
                sta pipeEndsCharNums+52+76
                lda #117
                sta pipeEndsCharNums+56+76

                lda #114+128
                sta pipeEndsCharNums+61+76
                lda #115+128
                sta pipeEndsCharNums+65+76
                lda #105+128
                sta pipeEndsCharNums+66+76
                lda #106+128
                sta pipeEndsCharNums+70+76
                lda #116+128
                sta pipeEndsCharNums+71+76
                lda #117+128
                sta pipeEndsCharNums+75+76

                pla
                rts

;=============================================================
;------------ prepare data for pipe2  ------------------------
;=============================================================
prepareDataForPipe2
                pha

                ;up
                lda #114+4
                sta pipeEndsCharNums+42
                lda #115+4
                sta pipeEndsCharNums+46
                lda #105+4
                sta pipeEndsCharNums+47
                lda #106+4
                sta pipeEndsCharNums+51
                lda #116+4
                sta pipeEndsCharNums+52
                lda #117+4
                sta pipeEndsCharNums+56

                lda #114+4+128
                sta pipeEndsCharNums+61
                lda #115+4+128
                sta pipeEndsCharNums+65
                lda #105+4+128
                sta pipeEndsCharNums+66
                lda #106+4+128
                sta pipeEndsCharNums+70
                lda #116+4+128
                sta pipeEndsCharNums+71
                lda #117+4+128
                sta pipeEndsCharNums+75

                ;down
                lda #114+4
                sta pipeEndsCharNums+42+76
                lda #115+4
                sta pipeEndsCharNums+46+76
                lda #105+4
                sta pipeEndsCharNums+47+76
                lda #106+4
                sta pipeEndsCharNums+51+76
                lda #116+4
                sta pipeEndsCharNums+52+76
                lda #117+4
                sta pipeEndsCharNums+56+76

                lda #114+4+128
                sta pipeEndsCharNums+61+76
                lda #115+4+128
                sta pipeEndsCharNums+65+76
                lda #105+4+128
                sta pipeEndsCharNums+66+76
                lda #106+4+128
                sta pipeEndsCharNums+70+76
                lda #116+4+128
                sta pipeEndsCharNums+71+76
                lda #117+4+128
                sta pipeEndsCharNums+75+76

                pla
                rts

;=============================================================
;------------------ generate sides ---------------------------
;=============================================================
generateSides
                pha
                txa
                pha
                tya
                pha

                ;pipeXOffset - offset (dla 0 nie, dla 1, 2 i 3)
                lda pipeXOffset
                bne @+
                jmp finishGenerateSides

@               lda upOrDown
                bne @+
                mva #6 oraVal1
                mva #5 oraVal2
                jmp @+1
@               mva #5 oraVal1
                mva #6 oraVal2

@               lda row
                sec
                sbc #15
                asl
                tax
                lda genSidesAddrs,x
                sta genJmp+1
                lda genSidesAddrs+1,x
                sta genJmp+2

                ;pipeX-4 - index charactera
                lda pipeX ;0 <= pipeX <= 35
                asl
                asl
                asl ;multiply by 8
                tax

                lda pipeXOffset
                ldy pipe1Or2

genJmp          jmp $FFFF

                .rept 6,#
genSides:1      cmp #3
                jeq @+1
                cmp #2
                jeq @+

                ;offset 1
                ;right
                lda charset:1 + 0,x
                and #$3F
                sta charset:1a + 8*115 + 0,y
                lda charset:1 + 1,x
                and #$3F
                sta charset:1a + 8*115 + 1,y
                lda charset:1 + 2,x
                and #$3F
                sta charset:1a + 8*115 + 2,y
                lda charset:1 + 3,x
                and #$3F
                sta charset:1a + 8*115 + 3,y
                lda charset:1 + 4,x
                and #$3F
                sta charset:1a + 8*115 + 4,y
                lda charset:1 + 5,x
                and #$3F
                sta charset:1a + 8*115 + 5,y
                lda charset:1 + 6,x
                and #$3F
                sta charset:1a + 8*115 + 6,y
                lda charset:1 + 7,x
                and #$3F
                sta charset:1a + 8*115 + 7,y

                lda pipeX
                sec
                sbc #4
                asl
                asl
                asl
                tax

                ;left
                lda charset:1 + 0,x
                and #$C0
                sta charset:1a + 8*114 + 0,y
                lda charset:1 + 1,x
                and #$C0
                ora oraVal1
                sta charset:1a + 8*114 + 1,y
                lda charset:1 + 2,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 2,y
                lda charset:1 + 3,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 3,y
                lda charset:1 + 4,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 4,y
                lda charset:1 + 5,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 5,y
                lda charset:1 + 6,x
                and #$C0
                ora oraVal2
                sta charset:1a + 8*114 + 6,y
                lda charset:1 + 7,x
                and #$C0
                sta charset:1a + 8*114 + 7,y
                jmp finishGenerateSides


@               ;offset2
                ;right
                lda charset:1 + 0,x
                and #$0F
                sta charset:1b + 8*106 + 0,y
                lda charset:1 + 1,x
                and #$0F
                sta charset:1b + 8*106 + 1,y
                lda charset:1 + 2,x
                and #$0F
                sta charset:1b + 8*106 + 2,y
                lda charset:1 + 3,x
                and #$0F
                sta charset:1b + 8*106 + 3,y
                lda charset:1 + 4,x
                and #$0F
                sta charset:1b + 8*106 + 4,y
                lda charset:1 + 5,x
                and #$0F
                sta charset:1b + 8*106 + 5,y
                lda charset:1 + 6,x
                and #$0F
                sta charset:1b + 8*106 + 6,y
                lda charset:1 + 7,x
                and #$0F
                sta charset:1b + 8*106 + 7,y

                lda pipeX
                sec
                sbc #4
                asl
                asl
                asl
                tax

                ;left
                lda charset:1 + 0,x
                and #$F0
                sta charset:1b + 8*105 + 0,y
                lda charset:1 + 1,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 1,y
                lda charset:1 + 2,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 2,y
                lda charset:1 + 3,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 3,y
                lda charset:1 + 4,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 4,y
                lda charset:1 + 5,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 5,y
                lda charset:1 + 6,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 6,y
                lda charset:1 + 7,x
                and #$F0
                sta charset:1b + 8*105 + 7,y
                jmp finishGenerateSides


@               ;offset3
                ;right
                lda charset:1 + 0,x
                and #$03
                sta charset:1a + 8*117 + 0,y
                lda charset:1 + 1,x
                and #$03
                sta charset:1a + 8*117 + 1,y
                lda charset:1 + 2,x
                and #$03
                sta charset:1a + 8*117 + 2,y
                lda charset:1 + 3,x
                and #$03
                sta charset:1a + 8*117 + 3,y
                lda charset:1 + 4,x
                and #$03
                sta charset:1a + 8*117 + 4,y
                lda charset:1 + 5,x
                and #$03
                sta charset:1a + 8*117 + 5,y
                lda charset:1 + 6,x
                and #$03
                sta charset:1a + 8*117 + 6,y
                lda charset:1 + 7,x
                and #$03
                sta charset:1a + 8*117 + 7,y

                lda pipeX
                sec
                sbc #4
                asl
                asl
                asl
                tax

                ;left
                lda charset:1 + 0,x
                and #$FC
                sta charset:1a + 8*116 + 0,y
                lda charset:1 + 1,x
                and #$FC
                sta charset:1a + 8*116 + 1,y
                lda charset:1 + 2,x
                and #$FC
                sta charset:1a + 8*116 + 2,y
                lda charset:1 + 3,x
                and #$FC
                sta charset:1a + 8*116 + 3,y
                lda charset:1 + 4,x
                and #$FC
                sta charset:1a + 8*116 + 4,y
                lda charset:1 + 5,x
                and #$FC
                sta charset:1a + 8*116 + 5,y
                lda charset:1 + 6,x
                and #$FC
                sta charset:1a + 8*116 + 6,y
                lda charset:1 + 7,x
                and #$FC
                sta charset:1a + 8*116 + 7,y
                jmp finishGenerateSides

                .endr

finishGenerateSides:

                pla
                tay
                pla
                tax
                pla
                rts

oraVal1
                dta 0
oraVal2
                dta 0


;=============================================================
;------------ draw pipe end segment (up or down)  ------------
;---- to draw up segment: mva #0 upOrDown --------------------
;---- to draw down segment: mva #76 upOrDown -----------------
;=============================================================
drawPipeEnd
                pha
                txa
                pha
                tya
                pha

                ldy upOrDown

                lda row
                cmp #15
                jmi rows0to14End
                cmp #20
                jmi rows15to19End
                jeq row20End

row21End:       ldx pipeX

                lda pipeXOffset
                cmp #3
                jeq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                ;offset==0
                lda pipeEndsCharNums + 0,y
                sta SCREENSTART + SCRW*21 + 0,x
                lda pipeEndsCharNums + 1,y
                sta SCREENSTART + SCRW*21 + 1,x
                lda pipeEndsCharNums + 2,y
                sta SCREENSTART + SCRW*21 + 2,x
                lda pipeEndsCharNums + 3,y
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipeEnd

@               ;offset==1
                lda pipeEndsCharNums + 4,y
                sta SCREENSTART + SCRW*21 + 0,x
                lda pipeEndsCharNums + 5,y
                sta SCREENSTART + SCRW*21 + 1,x
                lda pipeEndsCharNums + 6,y
                sta SCREENSTART + SCRW*21 + 2,x
                lda pipeEndsCharNums + 7,y
                sta SCREENSTART + SCRW*21 + 3,x
                lda pipeEndsCharNums + 8,y
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeEnd

@               ;offset==2
                lda pipeEndsCharNums + 9,y
                sta SCREENSTART + SCRW*21 + 0,x
                lda pipeEndsCharNums + 10,y
                sta SCREENSTART + SCRW*21 + 1,x
                lda pipeEndsCharNums + 11,y
                sta SCREENSTART + SCRW*21 + 2,x
                lda pipeEndsCharNums + 12,y
                sta SCREENSTART + SCRW*21 + 3,x
                lda pipeEndsCharNums + 13,y
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeEnd

@               ;offset==3
                lda pipeEndsCharNums + 14,y
                sta SCREENSTART + SCRW*21 + 0,x
                lda pipeEndsCharNums + 15,y
                sta SCREENSTART + SCRW*21 + 1,x
                lda pipeEndsCharNums + 16,y
                sta SCREENSTART + SCRW*21 + 2,x
                lda pipeEndsCharNums + 17,y
                sta SCREENSTART + SCRW*21 + 3,x
                lda pipeEndsCharNums + 18,y
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeEnd

rows0to14End:   asl
                tax
                lda drawRowAddrsEnd,x
                sta rowJmpEnd+1
                lda drawRowAddrsEnd+1,x
                sta rowJmpEnd+2

                ldx pipeX

                lda pipeXOffset
rowJmpEnd       jmp $FFFF

                .rept 15,#
drawRowEnd:1    cmp #3
                jeq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                ;offset==0
                lda pipeEndsCharNums + 19,y
                sta SCREENSTART + SCRW*# + 0,x
                lda pipeEndsCharNums + 20,y
                sta SCREENSTART + SCRW*# + 1,x
                lda pipeEndsCharNums + 21,y
                sta SCREENSTART + SCRW*# + 2,x
                lda pipeEndsCharNums + 22,y
                sta SCREENSTART + SCRW*# + 3,x
                jmp finishDrawPipeEnd

@               ;offset==1
                lda pipeEndsCharNums + 23,y
                sta SCREENSTART + SCRW*# + 0,x
                lda pipeEndsCharNums + 24,y
                sta SCREENSTART + SCRW*# + 1,x
                lda pipeEndsCharNums + 25,y
                sta SCREENSTART + SCRW*# + 2,x
                lda pipeEndsCharNums + 26,y
                sta SCREENSTART + SCRW*# + 3,x
                lda pipeEndsCharNums + 27,y
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeEnd

@               ;offset==2
                lda pipeEndsCharNums + 28,y
                sta SCREENSTART + SCRW*# + 0,x
                lda pipeEndsCharNums + 29,y
                sta SCREENSTART + SCRW*# + 1,x
                lda pipeEndsCharNums + 30,y
                sta SCREENSTART + SCRW*# + 2,x
                lda pipeEndsCharNums + 31,y
                sta SCREENSTART + SCRW*# + 3,x
                lda pipeEndsCharNums + 32,y
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeEnd

@               ;offset==3
                lda pipeEndsCharNums + 33,y
                sta SCREENSTART + SCRW*# + 0,x
                lda pipeEndsCharNums + 34,y
                sta SCREENSTART + SCRW*# + 1,x
                lda pipeEndsCharNums + 35,y
                sta SCREENSTART + SCRW*# + 2,x
                lda pipeEndsCharNums + 36,y
                sta SCREENSTART + SCRW*# + 3,x
                lda pipeEndsCharNums + 37,y
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeEnd

                .endr

                jmp finishDrawPipeEnd

rows15to19End:  sec
                sbc #15
                asl
                tax
                lda drawRowBAddrsEnd,x
                sta rowBJmpEnd+1
                lda drawRowBAddrsEnd+1,x
                sta rowBJmpEnd+2

                ldx pipeX

                lda pipeXOffset
rowBJmpEnd      jmp $FFFF

                .rept 5,#
drawRowBEnd:1   cmp #3
                jeq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                ;offset==0
                lda pipeEndsCharNums + 38,y
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda pipeEndsCharNums + 39,y
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda pipeEndsCharNums + 40,y
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda pipeEndsCharNums + 41,y
                sta SCREENSTART + SCRW*(15+#) + 3,x
                jmp finishDrawPipeEnd

@               ;offset==1
                lda pipeEndsCharNums + 42,y
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda pipeEndsCharNums + 43,y
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda pipeEndsCharNums + 44,y
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda pipeEndsCharNums + 45,y
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda pipeEndsCharNums + 46,y
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeEnd

@               ;offset==2
                lda pipeEndsCharNums + 47,y
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda pipeEndsCharNums + 48,y
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda pipeEndsCharNums + 49,y
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda pipeEndsCharNums + 50,y
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda pipeEndsCharNums + 51,y
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeEnd

@               ;offset==3
                lda pipeEndsCharNums + 52,y
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda pipeEndsCharNums + 53,y
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda pipeEndsCharNums + 54,y
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda pipeEndsCharNums + 55,y
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda pipeEndsCharNums + 56,y
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeEnd
                .endr

row20End:       ldx pipeX

                lda pipeXOffset
                cmp #3
                jeq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                ;offset==0
                lda pipeEndsCharNums + 57,y
                sta SCREENSTART + SCRW*20 + 0,x
                lda pipeEndsCharNums + 58,y
                sta SCREENSTART + SCRW*20 + 1,x
                lda pipeEndsCharNums + 59,y
                sta SCREENSTART + SCRW*20 + 2,x
                lda pipeEndsCharNums + 60,y
                sta SCREENSTART + SCRW*20 + 3,x
                jmp finishDrawPipeEnd

@               ;offset==1
                lda pipeEndsCharNums + 61,y
                sta SCREENSTART + SCRW*20 + 0,x
                lda pipeEndsCharNums + 62,y
                sta SCREENSTART + SCRW*20 + 1,x
                lda pipeEndsCharNums + 63,y
                sta SCREENSTART + SCRW*20 + 2,x
                lda pipeEndsCharNums + 64,y
                sta SCREENSTART + SCRW*20 + 3,x
                lda pipeEndsCharNums + 65,y
                sta SCREENSTART + SCRW*20 + 4,x
                jmp finishDrawPipeEnd

@               ;offset==2
                lda pipeEndsCharNums + 66,y
                sta SCREENSTART + SCRW*20 + 0,x
                lda pipeEndsCharNums + 67,y
                sta SCREENSTART + SCRW*20 + 1,x
                lda pipeEndsCharNums + 68,y
                sta SCREENSTART + SCRW*20 + 2,x
                lda pipeEndsCharNums + 69,y
                sta SCREENSTART + SCRW*20 + 3,x
                lda pipeEndsCharNums + 70,y
                sta SCREENSTART + SCRW*20 + 4,x
                jmp finishDrawPipeEnd

@               ;offset==3
                lda pipeEndsCharNums + 71,y
                sta SCREENSTART + SCRW*20 + 0,x
                lda pipeEndsCharNums + 72,y
                sta SCREENSTART + SCRW*20 + 1,x
                lda pipeEndsCharNums + 73,y
                sta SCREENSTART + SCRW*20 + 2,x
                lda pipeEndsCharNums + 74,y
                sta SCREENSTART + SCRW*20 + 3,x
                lda pipeEndsCharNums + 75,y
                sta SCREENSTART + SCRW*20 + 4,x
                ;jmp finishDrawPipeEnd

finishDrawPipeEnd:
                pla
                tay
                pla
                tax
                pla
                rts


;=============================================================
;---------------- undraw pipe  -------------------------------
;=============================================================
undrawPipe
                pha
                txa
                pha

                ldx pipeX

                lda #0
                .rept 15
                sta SCREENSTART + SCRW*# + 3, x
                sta SCREENSTART + SCRW*# + 4, x
                .endr

                lda pipeX
                .rept 5
                sta SCREENSTART + SCRW*(15+#) + 4, x
                .endr
                sec
                sbc #1
                .rept 5
                sta SCREENSTART + SCRW*(15+#) + 3, x
                .endr

                lda pipeX
                clc
                adc #128
                sta SCREENSTART + SCRW*20 + 4, x
                sec
                sbc #1
                sta SCREENSTART + SCRW*20 + 3, x

                lda #1
                sta SCREENSTART + SCRW*21 + 3, x
                sta SCREENSTART + SCRW*21 + 4, x

                pla
                tax
                pla
                rts

;=============================================================
;---------------- Draw pipe downward -------------------------
;=============================================================
drawPipeDownward
                pha
                txa
                pha

                ldx pipeX

                lda pipeXOffset
                cmp #3
                beq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                mwa #off0dpdAddrs dpdJmp+1
                jmp dpdCont
@               mwa #off1dpdAddrs dpdJmp+1
                jmp dpdCont
@               mwa #off2dpdAddrs dpdJmp+1
                jmp dpdCont
@               mwa #off3dpdAddrs dpdJmp+1

dpdCont         lda row
                asl
                clc
                adc dpdJmp+1
                sta dpdJmp+1
                bcc dpdJmp
                inc dpdJmp+2

dpdJmp          jmp ($FFFF)

                ;offset0
                .rept 15,#
off0dpd:1       lda #2
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #3+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #4+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #5
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                .rept 5,(15+#)
off0dpd:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda add64-1,x
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
off0dpd20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda add192-1,x
                sta SCREENSTART + SCRW*20 + 3,x
off0dpd21       lda #57
                sta SCREENSTART + SCRW*21 + 0,x
                lda #58+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #59+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #60
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipeDownward

                ;offset1
                .rept 15,#
off1dpd:1       lda #14
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #15+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #16+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #17+128
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                .rept 5,(15+#)
off1dpd:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
off1dpd20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
off1dpd21       lda #69
                sta SCREENSTART + SCRW*21 + 0,x
                lda #70+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #71+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #72+128
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipeDownward

                ;offset2
                .rept 15,#
off2dpd:1       lda #28
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #29+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #30+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #31+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda #32
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                .rept 5,(15+#)
off2dpd:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
off2dpd20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
off2dpd21       lda #83
                sta SCREENSTART + SCRW*21 + 0,x
                lda #84+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #85+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #86+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #87
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeDownward

                ;offset3
                .rept 15,#
off3dpd:1       lda #43
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #44+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #45+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda #46
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                .rept 5,(15+#)
off3dpd:1       lda #99+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
off3dpd20       lda #99+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
off3dpd21       lda #98
                sta SCREENSTART + SCRW*21 + 1,x
                lda #99+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #100+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #101
                sta SCREENSTART + SCRW*21 + 4,x
                ;jmp finishDrawPipeDownward

finishDrawPipeDownward
                pla
                tax
                pla
                rts


;=============================================================
;---------------- Draw pipe upward ---------------------------
;=============================================================
drawPipeUpward
                pha
                txa
                pha

                ldx pipeX

                lda pipeXOffset
                cmp #3
                beq @+2
                cmp #2
                beq @+1
                cmp #1
                beq @+

                mwa #off0dpuAddrs dpuJmp+1
                jmp dpuCont
@               mwa #off1dpuAddrs dpuJmp+1
                jmp dpuCont
@               mwa #off2dpuAddrs dpuJmp+1
                jmp dpuCont
@               mwa #off3dpuAddrs dpuJmp+1

dpuCont         lda row
                asl
                clc
                adc dpuJmp+1
                sta dpuJmp+1
                bcc dpuJmp
                inc dpuJmp+2

dpuJmp          jmp ($FFFF)

                ;offset0
off0dpu21       lda #57
                sta SCREENSTART + SCRW*21 + 0,x
                lda #58+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #59+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #60
                sta SCREENSTART + SCRW*21 + 3,x
off0dpu20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda add192-1,x
                sta SCREENSTART + SCRW*20 + 3,x
                .rept 5,(19-#)
off0dpu:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda add64-1,x
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                .rept 15,(14-#)
off0dpu:1       lda #2
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #3+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #4+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #5
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                jmp finishDrawPipeUpward

                ;offset1
off1dpu21       lda #69
                sta SCREENSTART + SCRW*21 + 0,x
                lda #70+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #71+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #72+128
                sta SCREENSTART + SCRW*21 + 3,x
off1dpu20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
                .rept 5,(19-#)
off1dpu:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                .rept 15,(14-#)
off1dpu:1       lda #14
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #15+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #16+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #17+128
                sta SCREENSTART + SCRW*:1 + 3,x
                .endr
                jmp finishDrawPipeUpward

                ;offset2
off2dpu21       lda #83
                sta SCREENSTART + SCRW*21 + 0,x
                lda #84+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #85+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #86+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #87
                sta SCREENSTART + SCRW*21 + 4,x
off2dpu20       lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
                .rept 5,(19-#)
off2dpu:1       lda add32-4,x
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                .rept 15,(14-#)
off2dpu:1       lda #28
                sta SCREENSTART + SCRW*:1 + 0,x
                lda #29+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #30+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #31+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda #32
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                jmp finishDrawPipeUpward

                ;offset3
off3dpu21       lda #98
                sta SCREENSTART + SCRW*21 + 1,x
                lda #99+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #100+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #101
                sta SCREENSTART + SCRW*21 + 4,x
off3dpu20       lda #99+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
                .rept 5,(19-#)
off3dpu:1       lda #99+128
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                .rept 15,(14-#)
off3dpu:1       lda #43
                sta SCREENSTART + SCRW*:1 + 1,x
                lda #44+128
                sta SCREENSTART + SCRW*:1 + 2,x
                lda #45+128
                sta SCREENSTART + SCRW*:1 + 3,x
                lda #46
                sta SCREENSTART + SCRW*:1 + 4,x
                .endr
                ;jmp finishDrawPipeUpward

finishDrawPipeUpward
                pla
                tax
                pla
                rts

pipeX               dta $0
pipeXOffset         dta $0
row                 dta $0

                    ;avoid 6502 indirect jmp bug for all following addresses by aligning to an address divisible by 2
                    .IF (*%2==1)
                    .align *+1,0
                    .ENDIF

off0dpdAddrs        dta a(off0dpd0),a(off0dpd1),a(off0dpd2),a(off0dpd3),a(off0dpd4),a(off0dpd5),a(off0dpd6),a(off0dpd7)
                    dta a(off0dpd8),a(off0dpd9),a(off0dpd10),a(off0dpd11),a(off0dpd12),a(off0dpd13),a(off0dpd14),a(off0dpd15)
                    dta a(off0dpd16),a(off0dpd17),a(off0dpd18),a(off0dpd19),a(off0dpd20),a(off0dpd21)

off1dpdAddrs        dta a(off1dpd0),a(off1dpd1),a(off1dpd2),a(off1dpd3),a(off1dpd4),a(off1dpd5),a(off1dpd6),a(off1dpd7)
                    dta a(off1dpd8),a(off1dpd9),a(off1dpd10),a(off1dpd11),a(off1dpd12),a(off1dpd13),a(off1dpd14),a(off1dpd15)
                    dta a(off1dpd16),a(off1dpd17),a(off1dpd18),a(off1dpd19),a(off1dpd20),a(off1dpd21)

off2dpdAddrs        dta a(off2dpd0),a(off2dpd1),a(off2dpd2),a(off2dpd3),a(off2dpd4),a(off2dpd5),a(off2dpd6),a(off2dpd7)
                    dta a(off2dpd8),a(off2dpd9),a(off2dpd10),a(off2dpd11),a(off2dpd12),a(off2dpd13),a(off2dpd14),a(off2dpd15)
                    dta a(off2dpd16),a(off2dpd17),a(off2dpd18),a(off2dpd19),a(off2dpd20),a(off2dpd21)

off3dpdAddrs        dta a(off3dpd0),a(off3dpd1),a(off3dpd2),a(off3dpd3),a(off3dpd4),a(off3dpd5),a(off3dpd6),a(off3dpd7)
                    dta a(off3dpd8),a(off3dpd9),a(off3dpd10),a(off3dpd11),a(off3dpd12),a(off3dpd13),a(off3dpd14),a(off3dpd15)
                    dta a(off3dpd16),a(off3dpd17),a(off3dpd18),a(off3dpd19),a(off3dpd20),a(off3dpd21)

off0dpuAddrs        dta a(off0dpu0),a(off0dpu1),a(off0dpu2),a(off0dpu3),a(off0dpu4),a(off0dpu5),a(off0dpu6),a(off0dpu7)
                    dta a(off0dpu8),a(off0dpu9),a(off0dpu10),a(off0dpu11),a(off0dpu12),a(off0dpu13),a(off0dpu14),a(off0dpu15)
                    dta a(off0dpu16),a(off0dpu17),a(off0dpu18),a(off0dpu19),a(off0dpu20),a(off0dpu21)

off1dpuAddrs        dta a(off1dpu0),a(off1dpu1),a(off1dpu2),a(off1dpu3),a(off1dpu4),a(off1dpu5),a(off1dpu6),a(off1dpu7)
                    dta a(off1dpu8),a(off1dpu9),a(off1dpu10),a(off1dpu11),a(off1dpu12),a(off1dpu13),a(off1dpu14),a(off1dpu15)
                    dta a(off1dpu16),a(off1dpu17),a(off1dpu18),a(off1dpu19),a(off1dpu20),a(off1dpu21)

off2dpuAddrs        dta a(off2dpu0),a(off2dpu1),a(off2dpu2),a(off2dpu3),a(off2dpu4),a(off2dpu5),a(off2dpu6),a(off2dpu7)
                    dta a(off2dpu8),a(off2dpu9),a(off2dpu10),a(off2dpu11),a(off2dpu12),a(off2dpu13),a(off2dpu14),a(off2dpu15)
                    dta a(off2dpu16),a(off2dpu17),a(off2dpu18),a(off2dpu19),a(off2dpu20),a(off2dpu21)

off3dpuAddrs        dta a(off3dpu0),a(off3dpu1),a(off3dpu2),a(off3dpu3),a(off3dpu4),a(off3dpu5),a(off3dpu6),a(off3dpu7)
                    dta a(off3dpu8),a(off3dpu9),a(off3dpu10),a(off3dpu11),a(off3dpu12),a(off3dpu13),a(off3dpu14),a(off3dpu15)
                    dta a(off3dpu16),a(off3dpu17),a(off3dpu18),a(off3dpu19),a(off3dpu20),a(off3dpu21)

drawRowAddrsEnd     dta a(drawRowEnd0),a(drawRowEnd1),a(drawRowEnd2),a(drawRowEnd3),a(drawRowEnd4),a(drawRowEnd5)
                    dta a(drawRowEnd6),a(drawRowEnd7),a(drawRowEnd8),a(drawRowEnd9),a(drawRowEnd10),a(drawRowEnd11)
                    dta a(drawRowEnd12),a(drawRowEnd13),a(drawRowEnd14)

drawRowBAddrsEnd    dta a(drawRowBEnd0),a(drawRowBEnd1),a(drawRowBEnd2),a(drawRowBEnd3),a(drawRowBEnd4)

genSidesAddrs       dta a(genSides0),a(genSides1),a(genSides2),a(genSides3),a(genSides4),a(genSides5)

pipeEndsCharNums ;first 76 numbers for up-end and next 76 for down-end
    dta 61,62+128,63+128,64+128                 ;row 21 offset 0 (up)
    dta 73,74+128,75+128,76+128,77              ;row 21 offset 1 (up)
    dta 88,89+128,90+128,91+128,92              ;row 21 offset 2 (up)
    dta 102,103+128,104+128,105+128,106         ;row 21 offset 3 (up)

    dta 6,7+128,8+128,9+128                     ;rows 0-14 offset 0 (up)
    dta 18,19+128,20+128,21+128,22              ;rows 0-14 offset 1 (up)
    dta 33,34+128,35+128,36+128,37              ;rows 0-14 offset 2 (up)
    dta 47,48+128,49+128,50+128,51              ;rows 0-14 offset 3 (up)

    dta 98,99+128,100+128,101+128               ;rows 15-19 offset 0 (up)
    dta 114,102+128,103+128,104+128,115         ;rows 15-19 offset 1 (up)
    dta 105,99+128,100+128,101+128,106          ;rows 15-19 offset 2 (up)
    dta 116,105+128,106+128,107+128,117         ;rows 15-19 offset 3 (up)

    dta 98,99+128,100+128,101+128               ;row 20 offset 0 (up)
    dta 114+128,102+128,103+128,104+128,115+128 ;row 20 offset 1 (up)
    dta 105+128,99+128,100+128,101+128,106+128  ;row 20 offset 2 (up)
    dta 116+128,105+128,106+128,107+128,117+128 ;row 20 offset 3 (up)


    dta 65,66+128,67+128,68+128                 ;row 21 offset 0 (down)
    dta 78,79+128,80+128,81+128,82              ;row 21 offset 1 (down)
    dta 93,94+128,95+128,96+128,97              ;row 21 offset 2 (down)
    dta 107,108+128,109+128,110+128,111         ;row 21 offset 3 (down)

    dta 10,11+128,12+128,13+128                 ;rows 0-14 offset 0 (down)
    dta 23,24+128,25+128,26+128,27              ;rows 0-14 offset 1 (down)
    dta 38,39+128,40+128,41+128,42              ;rows 0-14 offset 2 (down)
    dta 52,53+128,54+128,55+128,56              ;rows 0-14 offset 3 (down)

    dta 102,103+128,104+128,105+128             ;rows 15-19 offset 0 (down)
    ;dta 118,108+128,109+128,110+128,119         ;rows 15-19 offset 1 (down)
    ;dta 107,102+128,103+128,104+128,108         ;rows 15-19 offset 2 (down)
    ;dta 120,111+128,112+128,113+128,121         ;rows 15-19 offset 3 (down)
    dta 114,108+128,109+128,110+128,115         ;rows 15-19 offset 1 (down)
    dta 105,102+128,103+128,104+128,106         ;rows 15-19 offset 2 (down)
    dta 116,111+128,112+128,113+128,117         ;rows 15-19 offset 3 (down)

    dta 102,103+128,104+128,105+128             ;row 20 offset 0 (down)
    ;dta 118+128,108+128,109+128,110+128,119+128 ;row 20 offset 1 (down)
    ;dta 107+128,102+128,103+128,104+128,108+128 ;row 20 offset 2 (down)
    ;dta 120+128,111+128,112+128,113+128,121+128 ;row 20 offset 3 (down)
    dta 114+128,108+128,109+128,110+128,115+128 ;row 20 offset 1 (down)
    dta 105+128,102+128,103+128,104+128,106+128 ;row 20 offset 2 (down)
    dta 116+128,111+128,112+128,113+128,117+128 ;row 20 offset 3 (down)

upOrDown
    dta 0 ;set to 0 if you want to draw up-end, set to 76 if you want to draw down-end

pipe1Or2
    dta 0 ;set to 0 if you want to generate sides for pipe 1, set to 32 if you want to generate sides for pipe 2

add32               dta 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
add64               dta 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
add160              dta 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183
                    dta 184,185,186,187,188,189,190,191
add192              dta 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215
                    dta 216,217,218,219,220,221,222,223

;=============================================================
;---------------- Clear player -------------------------------
;=============================================================
clearPlayer
                pha
                txa
                pha

                lda #0
                ldx #0

@               sta PLAYERS+$400,X
                inx
                bne @-

@               sta PLAYERS+$500,X
                inx
                bne @-

@               sta PLAYERS+$600,X
                inx
                bne @-

@               sta PLAYERS+$700,X
                inx
                bne @-

                pla
                tax
                pla
                rts

;=============================================================
;---------------- Draw player --------------------------------
;=============================================================
drawPlayer
                pha
                txa
                pha

                lda playerX
                sta HPOSP0
                sta HPOSP3
                clc
                adc #7
                sta HPOSP1
                sta HPOSP2

                lda oldPlayerY
                sta epSta1+1
                sta epSta2+1
                sta epSta3+1
                sta epSta4+1

                lda #0

                ldx #17
epSta1          sta PLAYERS+$400,X
                dex
                bpl epSta1

                ldx #17
epSta2          sta PLAYERS+$500,X
                dex
                bpl epSta2

                ldx #17
epSta3          sta PLAYERS+$600,X
                dex
                bpl epSta3

                ldx #17
epSta4          sta PLAYERS+$700,X
                dex
                bpl epSta4


                lda playerY
                sta oldPlayerY

                ldx playerWing
                cpx #2
                beq wing2
                cpx #1
                beq wing1


wing0           sta w0Sta1+1
                sta w0Sta2+1
                sta w0Sta3+1
                sta w0Sta4+1

                ldx #17
@               lda PLAYERSTORE,X
w0Sta1          sta PLAYERS+$400,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+18,X
w0Sta2          sta PLAYERS+$500,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+36,X
w0Sta3          sta PLAYERS+$600,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+54,X
w0Sta4          sta PLAYERS+$700,X
                dex
                bpl @-

                jmp finishDrawPlayer


wing1           sta w1Sta1+1
                sta w1Sta2+1
                sta w1Sta3+1
                sta w1Sta4+1

                ldx #17
@               lda PLAYERSTORE+72,X
w1Sta1          sta PLAYERS+$400,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+18,X
w1Sta2          sta PLAYERS+$500,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+36,X
w1Sta3          sta PLAYERS+$600,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+90,X
w1Sta4          sta PLAYERS+$700,X
                dex
                bpl @-

                jmp finishDrawPlayer


wing2           sta w2Sta1+1
                sta w2Sta2+1
                sta w2Sta3+1
                sta w2Sta4+1

                ldx #17
@               lda PLAYERSTORE+108,X
w2Sta1          sta PLAYERS+$400,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+18,X
w2Sta2          sta PLAYERS+$500,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+36,X
w2Sta3          sta PLAYERS+$600,X
                dex
                bpl @-

                ldx #17
@               lda PLAYERSTORE+126,X
w2Sta4          sta PLAYERS+$700,X
                dex
                bpl @-


finishDrawPlayer
                pla
                tax
                pla
                rts

oldPlayerY      dta 40
playerX         dta 64
playerY         dta 32
playerWing      dta 1 ;0-wing up, 1-wing level, 2-wing down

;=============================================================
;---------------- Check collision with pipe ------------------
;=============================================================
checkCollision
                pha
                txa
                pha
                tya
                pha

                ;start with no collision
                lda #0
                sta collision

                ;calculate real X value of pipe (pipe's left edge)
                lda pipe1X
                sec
                sbc #4 ;subtract 4 due to sentinel characters
                asl
                asl
                clc
                adc pipe1XOffset
                sta pipeRealX

                ;check if player is within the vertical stripe of the pipe, if not then exit; also calculate playerRealX
                lda playerX
                sec
                sbc #64 ;subtract 64 and add 12 (bird width-1)
                sta playerRealX
                clc
                adc #12
                cmp pipeRealX
                jmi finishCheckCollision
                sec
                ;subtract 64 and subtract 16 (pipe width), so subtract 80 in total, but we've already subtracted 52 so only 28 left
                sbc #28
                cmp pipeRealX
                jpl finishCheckCollision

                ;player is within vertical stripe. calculate Y value of first free line of the opening...
                lda pipe1UpperEndRow
                clc
                adc #1 ;calculate first empty row
                asl
                asl
                asl ;calculate first empty line
                sta firstFreeLine

                ;...and calculate [last free line + 1]
                lda pipe1UpperEndRow
                clc
                adc gap
                asl
                asl
                asl
                sta firstNonFreeLine

                ;check if player collides with upper or lower part of the pipe; also calculate playerRealY
                lda playerY
                sec
                sbc #32
                sta playerRealY
                cmp firstFreeLine
                bmi collisionUp ;player collides with the upper part
                clc
                adc #17 ;add bird height-1
                cmp firstNonFreeLine
                jpl collisionDown ;player collides with the lower part
                jmp finishCheckCollision

collisionUp
                ;playerRealY in A

                ;get iy1 and iy2, clamp iy2 if needed
                sta iy1
                dec firstFreeLine ;it becomes lastNonFreeLine
                lda firstFreeLine
                sta iy2
                lda playerY
                sec
                sbc #15
                cmp iy2
                bpl @+
                sta iy2

                ;get and clamp ix1 and ix2
@               lda pipeRealX
                sta ix1
                lda playerRealX
                cmp ix1
                bmi @+
                sta ix1
@               lda pipeRealX
                clc
                adc #15
                sta ix2
                lda playerX
                sec
                sbc #52 ;subtract 64 and add 12
                cmp ix2
                bpl check9Pixels
                sta ix2

check9Pixels    ;check if any of the following pixels has "1" in collisionMask to approximate pixel-perfect collision:

                ;(ix1,         iy1)       (ix1/2+ix2/2,         iy1)      (ix2,         iy1)
                ;(ix1, iy1/2+iy2/2)       (ix1/2+ix2/2, iy1/2+iy2/2)      (ix2, iy1/2+iy2/2)
                ;(ix1,         iy2)       (ix1/2+ix2/2,         iy2)      (ix2,         iy2)

                ;where ix1,ix2,iy1,iy2 denote intersection rectangle between player and pipe


                ;make ix1,ix2,iy1,iy2 relative to the player
                lda ix1
                sec
                sbc playerRealX
                sta ix1
                lda ix2
                sec
                sbc playerRealX
                sta ix2
                lda iy1
                sec
                sbc playerRealY
                sta iy1
                lda iy2
                sec
                sbc playerRealY
                sta iy2


                ;check (ix1,iy1) and (ix2,iy1)
                ldx iy1
                lda times13,X
                clc
                adc ix1
                tax
                stx coltemp
                lda collisionMask,X
                jne setCol
                ldx iy1
                lda times13,X
                clc
                adc ix2
                tax
                lda collisionMask,X
                jne setCol

                ;check the pixel halfway in between (ix1,iy1) and (ix2,iy1)
                lsr coltemp
                txa
                lsr
                clc
                adc coltemp
                tax
                lda collisionMask,X
                jne setCol

                ldy #2
                ;check (ix1,iy2) and (ix2,iy2)
colTwice        ldx iy2
                lda times13,X
                clc
                adc ix1
                tax
                lda collisionMask,X
                jne setCol
                ldx iy2
                lda times13,X
                clc
                adc ix2
                tax
                lda collisionMask,X
                bne setCol

                ;check the pixel halfway in between (ix1,iy2) and (ix2,iy2)
                ldx iy2
                lda times13,X
                clc
                adc ix1
                lsr
                sta coltemp
                lda times13,X
                clc
                adc ix2
                lsr
                clc
                adc coltemp
                tax
                lda collisionMask,X
                bne setCol

                ;repeat for iy halfway between iy1 and iy2
                lda iy1
                lsr
                sta coltemp
                lda iy2
                lsr
                clc
                adc coltemp
                sta iy2
                dey
                bne colTwice

                jmp finishCheckCollision

collisionDown
                ;playerRealBottomEdge in A
                sta iy2
                lda firstNonFreeLine
                sta iy1
                lda playerRealY
                cmp iy1
                bmi @+
                sta iy1

@               lda pipeRealX
                sta ix1
                lda playerRealX
                cmp ix1
                bmi @+
                sta ix1
@               lda pipeRealX
                clc
                adc #15
                sta ix2
                lda playerX
                sec
                sbc #52 ;subtract 64 and add 12
                cmp ix2
                bpl @+
                sta ix2
@               jmp check9Pixels

setCol
                lda #1
                sta collision

finishCheckCollision
                pla
                tay
                pla
                tax
                pla
                rts

collision        dta 0 ;0-no collision, 1-collision with first pipe
firstNonFreeLine dta 0
firstFreeLine    dta 0
pipeRealX        dta 0
playerRealX      dta 0
playerRealY      dta 0
coltemp          dta 0

ix1              dta 0
ix2              dta 0
iy1              dta 0
iy2              dta 0

times13          dta 0,13,26,39,52,65,78,91,104,117,130,143,156,169,182,195,208,221


;=============================================================
;---------------- Game loop ----------------------------------
;=============================================================
gameLoop
                pha

                jsr RASTERMUSICTRACKER+3 ;play

                jsr undrawPipe
                mva pipe1X pipeX
                jsr undrawPipe
                ;jsr generateScreenData


                ;right
                lda PORTA
                and #$08
                bne @+
                ;adb pipe1XOffset #$01
                ;inc pipe1UpperEndRow
                inc playerX
                inc playerWing
                lda playerWing
                cmp #3
                bne @+
                lda #0
                sta playerWing

                ;left
@               lda PORTA
                and #$04
                bne @+
                ;sbb pipe1XOffset #$01
                ;dec pipe1UpperEndRow
                dec playerX
                dec playerWing
                lda playerWing
                cmp #255
                bne @+
                lda #2
                sta playerWing

                ;down
@               lda PORTA
                and #$02
                bne @+
                inc playerY

                ;up
@               lda PORTA
                and #$01
                bne @+
                dec playerY

@               lda pipe1XOffset
                cmp #4
                bne @+
                inc pipe1X
                inc pipe2X
                mva #0 pipe1XOffset
                jmp @+1
@               cmp #255
                bne @+
                dec pipe1X
                dec pipe2X
                mva #3 pipe1XOffset

@               mva #0 currentCharset

                lda pipe1XOffset
                bne @+
                ;pipe1XOffset==0
                mwa #charsetAddrsForOffset0 chbaseLoad+1
                jmp chbaseCalcEnd
@               lda pipe1XOffset
                cmp #2
                bne @+
                ;pipe1XOffset=2
                mwa #charsetAddrsForOffset2 chbaseLoad+1
                jmp chbaseCalcEnd
@               ;pipe1XOffset==1 or 3
                mwa #charsetAddrsForOffset1and3 chbaseLoad+1

chbaseCalcEnd:

                mva pipe1X pipeX
                mva pipe1XOffset pipeXOffset
                mva #0 pipe1Or2
                jsr prepareDataForPipe1

                mva #0 upOrDown
                ldx pipe1UpperEndRow
                stx row
                cpx #15
                bmi @+
                cpx #21
                bpl @+
                jsr generateSides ;only generate sides for rows: 15,16,17,18,19 or 20
@               jsr drawPipeEnd

                dex
                stx row
                jsr drawPipeUpward

                mva #76 upOrDown
                lda pipe1UpperEndRow
                clc
                adc gap
                tax
                stx row
                cpx #15
                bmi @+
                cpx #21
                bpl @+
                jsr generateSides
@               jsr drawPipeEnd

                inx
                stx row
                jsr drawPipeDownward


                mva pipe2X pipeX
                mva #32 pipe1Or2
                jsr prepareDataForPipe2

                mva #0 upOrDown
                ldx pipe2UpperEndRow
                stx row
                cpx #15
                bmi @+
                cpx #21
                bpl @+
                jsr generateSides
@               jsr drawPipeEnd

                dex
                stx row
                jsr drawPipeUpward

                mva #76 upOrDown
                lda pipe2UpperEndRow
                clc
                adc gap
                tax
                stx row
                cpx #15
                bmi @+
                cpx #21
                bpl @+
                jsr generateSides
@               jsr drawPipeEnd

                inx
                stx row
                jsr drawPipeDownward


                jsr drawPlayer


                jsr checkCollision
                lda collision
                beq @+
                mva #$5E COLPF2
                jmp finishGameLoop
@               mva #$98 COLPF2


finishGameLoop
                lda VCOUNT
                cmp #30
                bcs @+

                cmp maxVCount
                bmi @+
                sta maxVCount

@               pla
                rts

pipe1X              dta 10
pipe1XOffset        dta $0
pipe2X              dta 26
pipe1UpperEndRow    dta 5
pipe2UpperEndRow    dta 13
gap                 dta 6

maxVCount           dta $0

;=============================================================
;---------------- DLI routine --------------------------------
;=============================================================
DLI             pha
                txa
                pha

                ldx currentCharset
chbaseLoad      lda charsetAddrsForOffset0,x
                sta WSYNC
                sta CHBASE
                inx
                stx currentCharset
                cpx #8
                bne @+
                jsr gameLoop

@               pla
                tax
                pla
                rti

currentCharset              dta $0
charsetAddrsForOffset0      dta >CHARSET+$04,>CHARSET+$10,>CHARSET+$1C,>CHARSET+$28,>CHARSET+$34,>CHARSET+$40,>CHARSET,>CHARSET
charsetAddrsForOffset1and3  dta >CHARSET+$08,>CHARSET+$14,>CHARSET+$20,>CHARSET+$2C,>CHARSET+$38,>CHARSET+$44,>CHARSET,>CHARSET
charsetAddrsForOffset2      dta >CHARSET+$0C,>CHARSET+$18,>CHARSET+$24,>CHARSET+$30,>CHARSET+$3C,>CHARSET+$48,>CHARSET,>CHARSET

;=============================================================
;---------------- NMI handler (we turn off the OS) -----------
;=============================================================
NMI
                ;our only NMI source is DLI. we disable VBI in ANTIC at startup, because we don't need it.
                ;all of the processing related to the game loop is done in the last DLI handler (after last visible scanline)
                jmp (VDSLST)

;=============================================================
;---------------- IRQ handler (we turn off the OS) -----------
;=============================================================
IRQ             cld
                pha

                lda IRQST
                and #$40 ;check if the source of irq is keyboard (except break key)
                bne @+ ;it is not (bits in IRQST are 0 when active and 1 when inactive)

                ;handle key press

                mva #$00 IRQEN ;acknowledge IRQ to make POKEY stop asserting IRQ line
                mva #$40 IRQEN ;restore IRQEN value (only keyboard interrupt enabled)

                mva KBCODE CH ;store pressed key

@               pla
                rti

    run codestart

codeend = *

    org ANTICDLSTART
    ;antic has 10 bit program counter (it's best when antic's dl starts on 1k boundary)
antic_dl
    dta $70,$70,$70 ;generate 24 blank lines (8 blank lines times 3)

    .rept 14,#
    dta $44
    dta a(SCREENSTART + SCRW*# + 4)
    .endr

    .rept 7,#
    dta $C4
    dta a(SCREENSTART + SCRW*(#+14) + 4)
    .endr

    dta $44
    dta a(SCREENSTART + SCRW*21 + 4)

    dta $70,$F0

    dta $41 ;jump and wait for vblank
    dta a(antic_dl) ;display list address


    icl "player.asm"
    icl "background.asm"
