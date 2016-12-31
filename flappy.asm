PROGSTART = $1000
ANTICDLSTART = $B000
SCREENSTART = $B060 ;remember about 12 bit screen memory counter in ANTIC (4k boundary)

;screen width in characters;
;normally screen is 32 characters in narrow mode, however we need 4 sentinel characters
;before the left edge of the screen and 4 after the right to support pipe clipping
SCRW = 40

CHARSET = $6000; $6000-$ABFF
;PIPES = $9C00 ; $9C00-9F20

CHBAS = $02F4
CHBASE = $D409

VCOUNT = $D40B

NMIEN = $D40E
VDSLST = $0200

DMACTL = $D400
SDMCTL = $022F

COLOR4 = $2C8 ;COLBK = $D01A
COLOR0 = $2C4 ;COLPF0 = $D016
COLOR1 = $2C5 ;COLPF1 = $D017
COLOR2 = $2C6 ;COLPF2 = $D018
COLOR3 = $2C7 ;COLPF3 = $D019

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

RTCLOK1 = $12
RTCLOK2 = $13
RTCLOK3 = $14
SDLSTL = $230 ;display list pointer
HSCROL = $D404
VSCROL = $D405
WSYNC = $D40A

SETVBV = $E45C
XITVBV = $E462

PORTA = $D300
STICK0 = $278


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

    jsr generateScreenData
    jsr generateCharset

    // mva #40 pipeX
    // jsr drawPipe

    ldx #<MODUL
	ldy #>MODUL
	lda #0 ;starting song line
	jsr RASTERMUSICTRACKER ;init

    ;wait for vblank
    lda RTCLOK3
    cmp RTCLOK3
    beq *-2 ;jump 2 bytes backwards (to the first byte of cmp instruction)

    mva #$21 SDMCTL ;set narrow playfield (while keeping instruction DMA enabled)

    ;ldy #<VBI
	;ldx #>VBI
	;lda #$7 ;6 - immediate VBI, 7 - deferred VBI
	;jsr SETVBV

    ;set new address of antic's display list
    mwa	#antic_dl SDLSTL

    mva #>CHARSET CHBAS
    mva #$0E COLOR0 ;chmury, bardzo jasna rura;   01
    mva #$B8 COLOR1 ;trawa, okna, jasna rura;     10
    mva #$98 COLOR2 ;niebo, budynki;              11
    mva #$B4 COLOR3 ;ciemna trawa, rura;          11 (+high bit ustawiony w screen data)
    mva #$00 COLOR4 ;tlo, ciemna rura;            00

    mwa #DLI VDSLST
    mva #$C0 NMIEN ;enable dli (and keep vbi enabled)

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
;------------------ generate sides (up)  ---------------------
;=============================================================
generateSidesUp
                pha
                txa
                pha
                tya
                pha

                ;pipeXOffset - offset (dla 0 nie, dla 1, 2 i 3)
                ldy pipeXOffset
                bne @+
                jmp finishGenerateSidesUp

@               lda row
                sec
                sbc #15
                asl
                tax
                lda genSidesUpAddrs,x
                sta genJmpUp+1
                lda genSidesUpAddrs+1,x
                sta genJmpUp+2

                ;pipeX-4 - index charactera
                lda pipeX ;0 <= pipeX <= 35
                asl
                asl
                asl ;multiply by 8
                tax

genJmpUp        jmp $FFFF

                .rept 6,#
genSidesUp:1    cpy #3
                jeq @+1
                cpy #2
                jeq @+

                ;offset 1
                ;right
                lda charset:1 + 0,x
                and #$3F
                sta charset:1a + 8*115 + 0
                lda charset:1 + 1,x
                and #$3F
                sta charset:1a + 8*115 + 1
                lda charset:1 + 2,x
                and #$3F
                sta charset:1a + 8*115 + 2
                lda charset:1 + 3,x
                and #$3F
                sta charset:1a + 8*115 + 3
                lda charset:1 + 4,x
                and #$3F
                sta charset:1a + 8*115 + 4
                lda charset:1 + 5,x
                and #$3F
                sta charset:1a + 8*115 + 5
                lda charset:1 + 6,x
                and #$3F
                sta charset:1a + 8*115 + 6
                lda charset:1 + 7,x
                and #$3F
                sta charset:1a + 8*115 + 7

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
                sta charset:1a + 8*114 + 0
                lda charset:1 + 1,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 1
                lda charset:1 + 2,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 2
                lda charset:1 + 3,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 3
                lda charset:1 + 4,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 4
                lda charset:1 + 5,x
                and #$C0
                ora #$06
                sta charset:1a + 8*114 + 5
                lda charset:1 + 6,x
                and #$C0
                ora #$05
                sta charset:1a + 8*114 + 6
                lda charset:1 + 7,x
                and #$C0
                sta charset:1a + 8*114 + 7
                jmp finishGenerateSidesUp


@               ;offset2
                ;right
                lda charset:1 + 0,x
                and #$0F
                sta charset:1b + 8*106 + 0
                lda charset:1 + 1,x
                and #$0F
                sta charset:1b + 8*106 + 1
                lda charset:1 + 2,x
                and #$0F
                sta charset:1b + 8*106 + 2
                lda charset:1 + 3,x
                and #$0F
                sta charset:1b + 8*106 + 3
                lda charset:1 + 4,x
                and #$0F
                sta charset:1b + 8*106 + 4
                lda charset:1 + 5,x
                and #$0F
                sta charset:1b + 8*106 + 5
                lda charset:1 + 6,x
                and #$0F
                sta charset:1b + 8*106 + 6
                lda charset:1 + 7,x
                and #$0F
                sta charset:1b + 8*106 + 7

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
                sta charset:1b + 8*105 + 0
                lda charset:1 + 1,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 1
                lda charset:1 + 2,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 2
                lda charset:1 + 3,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 3
                lda charset:1 + 4,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 4
                lda charset:1 + 5,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 5
                lda charset:1 + 6,x
                and #$F0
                ora #$01
                sta charset:1b + 8*105 + 6
                lda charset:1 + 7,x
                and #$F0
                sta charset:1b + 8*105 + 7
                jmp finishGenerateSidesUp


@               ;offset3
                ;right
                lda charset:1 + 0,x
                and #$03
                sta charset:1a + 8*117 + 0
                lda charset:1 + 1,x
                and #$03
                sta charset:1a + 8*117 + 1
                lda charset:1 + 2,x
                and #$03
                sta charset:1a + 8*117 + 2
                lda charset:1 + 3,x
                and #$03
                sta charset:1a + 8*117 + 3
                lda charset:1 + 4,x
                and #$03
                sta charset:1a + 8*117 + 4
                lda charset:1 + 5,x
                and #$03
                sta charset:1a + 8*117 + 5
                lda charset:1 + 6,x
                and #$03
                sta charset:1a + 8*117 + 6
                lda charset:1 + 7,x
                and #$03
                sta charset:1a + 8*117 + 7

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
                sta charset:1a + 8*116 + 0
                lda charset:1 + 1,x
                and #$FC
                sta charset:1a + 8*116 + 1
                lda charset:1 + 2,x
                and #$FC
                sta charset:1a + 8*116 + 2
                lda charset:1 + 3,x
                and #$FC
                sta charset:1a + 8*116 + 3
                lda charset:1 + 4,x
                and #$FC
                sta charset:1a + 8*116 + 4
                lda charset:1 + 5,x
                and #$FC
                sta charset:1a + 8*116 + 5
                lda charset:1 + 6,x
                and #$FC
                sta charset:1a + 8*116 + 6
                lda charset:1 + 7,x
                and #$FC
                sta charset:1a + 8*116 + 7
                jmp finishGenerateSidesUp

                .endr

finishGenerateSidesUp:

                pla
                tay
                pla
                tax
                pla
                rts

;=============================================================
;---------------- draw pipe end segment (up)  ----------------
;=============================================================
drawPipeUp
                pha
                txa
                pha
                tya
                pha

                lda row
                cmp #15
                jmi rows0to14Up
                cmp #20
                jmi rows15to19Up
                jeq row20Up

row21Up:        ldx pipeX
                ldy pipeXOffset

                cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #61
                sta SCREENSTART + SCRW*21 + 0,x
                lda #62+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #63+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #64+128
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipeUp

@               ;offset==1
                lda #73
                sta SCREENSTART + SCRW*21 + 0,x
                lda #74+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #75+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #76+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #77
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeUp

@               ;offset==2
                lda #88
                sta SCREENSTART + SCRW*21 + 0,x
                lda #89+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #90+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #91+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #92
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeUp

@               ;offset==3
                lda #102
                sta SCREENSTART + SCRW*21 + 0,x
                lda #103+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #104+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #105+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #106
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipeUp

rows0to14Up:
                asl
                tax
                lda drawRowAddrsUp,x
                sta rowJmpUp+1
                lda drawRowAddrsUp+1,x
                sta rowJmpUp+2

                ldx pipeX
                ldy pipeXOffset
rowJmpUp        jmp $FFFF

                .rept 15,#
drawRowUp:1     cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #6
                sta SCREENSTART + SCRW*# + 0,x
                lda #7+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #8+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #9+128
                sta SCREENSTART + SCRW*# + 3,x
                jmp finishDrawPipeUp

@               ;offset==1
                lda #18
                sta SCREENSTART + SCRW*# + 0,x
                lda #19+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #20+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #21+128
                sta SCREENSTART + SCRW*# + 3,x
                lda #22
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeUp

@               ;offset==2
                lda #33
                sta SCREENSTART + SCRW*# + 0,x
                lda #34+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #35+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #36+128
                sta SCREENSTART + SCRW*# + 3,x
                lda #37
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeUp

@               ;offset==3
                lda #47
                sta SCREENSTART + SCRW*# + 0,x
                lda #48+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #49+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #50+128
                sta SCREENSTART + SCRW*# + 3,x
                lda #51
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipeUp

                .endr

                jmp finishDrawPipeUp

rows15to19Up:
                sec
                sbc #15
                asl
                tax
                lda drawRowBAddrsUp,x
                sta rowBJmpUp+1
                lda drawRowBAddrsUp+1,x
                sta rowBJmpUp+2

                ldx pipeX
                ldy pipeXOffset
rowBJmpUp       jmp $FFFF

                .rept 5,#
drawRowBUp:1    cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #98
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #99+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                jmp finishDrawPipeUp

@               ;offset==1
                lda #114
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #102+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #103+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #104+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda #115
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeUp

@               ;offset==2
                lda #105
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #99+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda #106
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeUp

@               ;offset==3
                lda #116
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #105+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #106+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #107+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda #117
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipeUp
                .endr

row20Up:
                ldx pipeX
                ldy pipeXOffset

                cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #98
                sta SCREENSTART + SCRW*20 + 0,x
                lda #99+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*20 + 3,x
                jmp finishDrawPipeUp

@               ;offset==1
                lda #114+128
                sta SCREENSTART + SCRW*20 + 0,x
                lda #102+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #103+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #104+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda #115+128
                sta SCREENSTART + SCRW*20 + 4,x
                jmp finishDrawPipeUp

@               ;offset==2
                lda #105+128
                sta SCREENSTART + SCRW*20 + 0,x
                lda #99+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda #106+128
                sta SCREENSTART + SCRW*20 + 4,x
                jmp finishDrawPipeUp

@               ;offset==3
                lda #116+128
                sta SCREENSTART + SCRW*20 + 0,x
                lda #105+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #106+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #107+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda #117+128
                sta SCREENSTART + SCRW*20 + 4,x
                ;jmp finishDrawPipeUp

finishDrawPipeUp:
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
                .rept 15
                lda #0
                sta SCREENSTART + SCRW*# + 0, x
                sta SCREENSTART + SCRW*# + 1, x
                sta SCREENSTART + SCRW*# + 2, x
                sta SCREENSTART + SCRW*# + 3, x
                sta SCREENSTART + SCRW*# + 4, x
                .endr

                .rept 5
                lda pipeX
                sec
                sbc #4
                ldx pipeX
                sta SCREENSTART + SCRW*(15+#) + 0, x
                clc
                adc #1
                sta SCREENSTART + SCRW*(15+#) + 1, x
                clc
                adc #1
                sta SCREENSTART + SCRW*(15+#) + 2, x
                clc
                adc #1
                sta SCREENSTART + SCRW*(15+#) + 3, x
                clc
                adc #1
                sta SCREENSTART + SCRW*(15+#) + 4, x
                .endr

                lda pipeX
                clc
                adc #124
                ldx pipeX
                sta SCREENSTART + SCRW*20 + 0, x
                clc
                adc #1
                sta SCREENSTART + SCRW*20 + 1, x
                clc
                adc #1
                sta SCREENSTART + SCRW*20 + 2, x
                clc
                adc #1
                sta SCREENSTART + SCRW*20 + 3, x
                clc
                adc #1
                sta SCREENSTART + SCRW*20 + 4, x

                lda #1
                sta SCREENSTART + SCRW*21 + 0, x
                sta SCREENSTART + SCRW*21 + 1, x
                sta SCREENSTART + SCRW*21 + 2, x
                sta SCREENSTART + SCRW*21 + 3, x
                sta SCREENSTART + SCRW*21 + 4, x

                pla
                tax
                pla
                rts

;=============================================================
;---------------- draw pipe  ---------------------------------
;=============================================================
drawPipe
                pha
                txa
                pha
                tya
                pha

                lda row
                cmp #15
                bmi rows0to14
                cmp #20
                jmi rows15to19
                jeq row20

row21:          ldx pipeX
                ldy pipeXOffset

                cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #57
                sta SCREENSTART + SCRW*21 + 0,x
                lda #58+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #59+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #60
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda #69
                sta SCREENSTART + SCRW*21 + 0,x
                lda #70+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #71+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #72+128
                sta SCREENSTART + SCRW*21 + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda #83
                sta SCREENSTART + SCRW*21 + 0,x
                lda #84+128
                sta SCREENSTART + SCRW*21 + 1,x
                lda #85+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #86+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #87
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #98
                sta SCREENSTART + SCRW*21 + 1,x
                lda #99+128
                sta SCREENSTART + SCRW*21 + 2,x
                lda #100+128
                sta SCREENSTART + SCRW*21 + 3,x
                lda #101
                sta SCREENSTART + SCRW*21 + 4,x
                jmp finishDrawPipe

rows0to14:      ;w A jest row
                ;calcScreenAddr = SCREENSTART + row*40 + pipeX

                asl
                tax
                lda drawRowAddrs,x
                sta rowJmp+1
                lda drawRowAddrs+1,x
                sta rowJmp+2

                ldx pipeX
                ldy pipeXOffset
rowJmp          jmp $FFFF

                .rept 15,#
drawRow:1       cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda #2
                sta SCREENSTART + SCRW*# + 0,x
                lda #3+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #4+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #5
                sta SCREENSTART + SCRW*# + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda #14
                sta SCREENSTART + SCRW*# + 0,x
                lda #15+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #16+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #17+128
                sta SCREENSTART + SCRW*# + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda #28
                sta SCREENSTART + SCRW*# + 0,x
                lda #29+128
                sta SCREENSTART + SCRW*# + 1,x
                lda #30+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #31+128
                sta SCREENSTART + SCRW*# + 3,x
                lda #32
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #43
                sta SCREENSTART + SCRW*# + 1,x
                lda #44+128
                sta SCREENSTART + SCRW*# + 2,x
                lda #45+128
                sta SCREENSTART + SCRW*# + 3,x
                lda #46
                sta SCREENSTART + SCRW*# + 4,x
                jmp finishDrawPipe

                .endr

                ;offset0 - 2,3,4,5
                ;offset1 - 14,15,16,17
                ;offset2 - 28,29,30,31,32
                ;offset3 - 43,44,45,46

                jmp finishDrawPipe

rows15to19:
                sec
                sbc #15
                asl
                tax
                lda drawRowBAddrs,x
                sta rowBJmp+1
                lda drawRowBAddrs+1,x
                sta rowBJmp+2

                ldx pipeX
                ldy pipeXOffset
rowBJmp         jmp $FFFF

                .rept 5,#
drawRowB:1      cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda add32-4,x
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda add64-1,x
                sta SCREENSTART + SCRW*(15+#) + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda add32-4,x
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda add32-4,x
                sta SCREENSTART + SCRW*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #99+128
                sta SCREENSTART + SCRW*(15+#) + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*(15+#) + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*(15+#) + 3,x
                lda add64+0,x
                sta SCREENSTART + SCRW*(15+#) + 4,x
                jmp finishDrawPipe
                .endr

row20:
                ldx pipeX
                ldy pipeXOffset

                cpy #3
                jeq @+2
                cpy #2
                beq @+1
                cpy #1
                beq @+

                ;offset==0
                lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda add192-1,x
                sta SCREENSTART + SCRW*20 + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda add160-4,x
                sta SCREENSTART + SCRW*20 + 0,x
                lda #96+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #97+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #98+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #99+128
                sta SCREENSTART + SCRW*20 + 1,x
                lda #100+128
                sta SCREENSTART + SCRW*20 + 2,x
                lda #101+128
                sta SCREENSTART + SCRW*20 + 3,x
                lda add192+0,x
                sta SCREENSTART + SCRW*20 + 4,x
                ;jmp finishDrawPipe

finishDrawPipe:
                pla
                tay
                pla
                tax
                pla
                rts



pipeX               dta $0
pipeXOffset         dta $0
row                 dta $0

drawRowAddrs        dta a(drawRow0),a(drawRow1),a(drawRow2),a(drawRow3),a(drawRow4),a(drawRow5)
                    dta a(drawRow6),a(drawRow7),a(drawRow8),a(drawRow9),a(drawRow10),a(drawRow11)
                    dta a(drawRow12),a(drawRow13),a(drawRow14)

drawRowAddrsUp      dta a(drawRowUp0),a(drawRowUp1),a(drawRowUp2),a(drawRowUp3),a(drawRowUp4),a(drawRowUp5)
                    dta a(drawRowUp6),a(drawRowUp7),a(drawRowUp8),a(drawRowUp9),a(drawRowUp10),a(drawRowUp11)
                    dta a(drawRowUp12),a(drawRowUp13),a(drawRowUp14)

drawRowBAddrs       dta a(drawRowB0),a(drawRowB1),a(drawRowB2),a(drawRowB3),a(drawRowB4)

drawRowBAddrsUp     dta a(drawRowBUp0),a(drawRowBUp1),a(drawRowBUp2),a(drawRowBUp3),a(drawRowBUp4)

genSidesUpAddrs     dta a(genSidesUp0),a(genSidesUp1),a(genSidesUp2),a(genSidesUp3),a(genSidesUp4),a(genSidesUp5)

add32               dta 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
add64               dta 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
add160              dta 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183
                    dta 184,185,186,187,188,189,190,191
add192              dta 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215
                    dta 216,217,218,219,220,221,222,223


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

               /*Decimal
                   14
                    |
                10  | 6
                  \ |/
              11-- 15 ---7
                  / |\
                 9  | 5
                    |
                   13*/

                ;right
                lda PORTA
                and #$08
                bne @+
                adb pipe1XOffset #$01
                // jsr drawPipe

                ;left
@               lda PORTA
                and #$04
                bne @+
                sbb pipe1XOffset #$01
                // jsr drawPipe

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

                mva #0 row
                jsr drawPipe
                mva #1 row
                jsr drawPipe
                mva #2 row
                jsr drawPipe
                mva #3 row
                jsr drawPipe
                mva #4 row
                jsr drawPipe
                mva #5 row
                jsr drawPipe
                mva #6 row
                jsr drawPipe
                mva #7 row
                jsr drawPipe
                mva #8 row
                jsr drawPipe
                mva #9 row
                jsr drawPipe
                mva #10 row
                jsr drawPipe
                mva #11 row
                jsr drawPipe
                mva #12 row
                jsr drawPipe
                mva #13 row
                jsr drawPipe
                mva #14 row
                jsr drawPipe
                mva #15 row
                jsr drawPipe
                mva #16 row
                jsr drawPipe
                mva #17 row
                jsr drawPipe
                mva #18 row
                jsr drawPipe
                mva #19 row
                jsr drawPipe
                mva #20 row
                jsr drawPipe
                mva #21 row
                jsr drawPipe

                mva pipe2X pipeX
                mva #0 row
                jsr drawPipeUp
                mva #1 row
                jsr drawPipeUp
                mva #2 row
                jsr drawPipeUp
                mva #3 row
                jsr drawPipe
                mva #4 row
                jsr drawPipe
                mva #5 row
                jsr drawPipe
                mva #6 row
                jsr drawPipeUp
                mva #7 row
                jsr drawPipe
                mva #8 row
                jsr drawPipe
                mva #9 row
                jsr drawPipe
                mva #10 row
                jsr drawPipe
                mva #11 row
                jsr drawPipe
                mva #12 row
                jsr drawPipe
                mva #13 row
                jsr drawPipeUp
                mva #14 row
                jsr drawPipeUp
                mva #15 row
                jsr drawPipe
                mva #16 row
                jsr drawPipe
                mva #17 row
                jsr drawPipe
                mva #18 row
                jsr generateSidesUp
                jsr drawPipeUp
                mva #19 row
                jsr generateSidesUp
                jsr drawPipeUp
                mva #20 row
                jsr generateSidesUp
                jsr drawPipeUp
                mva #21 row
                jsr drawPipeUp

                lda VCOUNT
                cmp #30
                bcs @+

                cmp maxVCount
                bmi @+
                sta maxVCount


@               pla
                rts

pipe1X          dta 5
pipe1XOffset    dta $0
pipe2X          dta 18

maxVCount       dta $0

;=============================================================
;---------------- DLI routine --------------------------------
;=============================================================
DLI             pha
                txa
                pha

                ldx currentCharset
chbaseLoad      lda charsetAddrsForOffset0,x
                inx
                stx currentCharset
                sta WSYNC
                sta CHBASE
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


    icl "background.asm"
    ;icl "pipes.asm"


.macro asr16 addr
    ;shift right high byte preserving the sign bit
    lda :addr + 1
    cmp #$80
    ror :addr + 1

    ;shift right low byte (carry contains lowest bit of high byte now)
    ror :addr
.endm

.macro asl16 addr dst
    lda :addr
    asl
    sta :dst
    lda :addr+1
    rol
    sta :dst+1
.endm

;adds 24 bit values pointed by addr and val and stores the result under addr
.macro adl addr, val
    clc

    lda :addr
    adc :val
    sta :addr

    lda :addr+1
    adc :val+1
    sta :addr+1

    lda :addr+2
    adc :val+2
    sta :addr+2
.endm

;moves 24 bit value to dst
.macro mla val dst
    mva <:val :dst
    mva >:val :dst+1
    mva ^:val :dst+2
.endm

.macro getFromArr16 arrAddr, offset, dst
                asl16 :offset :dst
                adw :dst :arrAddr
                mwa :dst loadOffset1+1
                mwa :dst loadOffset2+1
                adw loadOffset2+1 #$1
loadOffset1     lda $FFFF ;$FFFF will be overwritten by address of calculated table entry
                sta :dst
loadOffset2     lda $FFFF ;$FFFF will be overwritten by (address of calculated table entry)+1
                sta :dst+1
.endm