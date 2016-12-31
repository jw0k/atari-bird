PROGSTART = $600
ANTICDLSTART = $B000
SCREENSTART = $B060 ;remember about 12 bit screen memory counter in ANTIC (4k boundary)

;screen width in characters;
;normally screen is 32 characters wide in narrow mode, however we need 4 sentinel characters
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

drawRowBAddrs       dta a(drawRowB0),a(drawRowB1),a(drawRowB2),a(drawRowB3),a(drawRowB4)

drawRowAddrsEnd     dta a(drawRowEnd0),a(drawRowEnd1),a(drawRowEnd2),a(drawRowEnd3),a(drawRowEnd4),a(drawRowEnd5)
                    dta a(drawRowEnd6),a(drawRowEnd7),a(drawRowEnd8),a(drawRowEnd9),a(drawRowEnd10),a(drawRowEnd11)
                    dta a(drawRowEnd12),a(drawRowEnd13),a(drawRowEnd14)

drawRowBAddrsEnd    dta a(drawRowBEnd0),a(drawRowBEnd1),a(drawRowBEnd2),a(drawRowBEnd3),a(drawRowBEnd4)

genSidesAddrs     dta a(genSides0),a(genSides1),a(genSides2),a(genSides3),a(genSides4),a(genSides5)

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
                mva #0 pipe1Or2
                jsr prepareDataForPipe1

                mva #0 row
                jsr drawPipe
                mva #1 row
                jsr drawPipe
                mva #2 row
                jsr drawPipe
                mva #3 row
                mva #76 upOrDown
                jsr drawPipeEnd
                mva #0 upOrDown
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
                mva #76 upOrDown
                jsr generateSides
                jsr drawPipeEnd
                mva #0 upOrDown
                mva #18 row
                jsr drawPipe
                mva #19 row
                mva #76 upOrDown
                jsr generateSides
                jsr drawPipeEnd
                mva #0 upOrDown
                mva #20 row
                mva #76 upOrDown
                jsr generateSides
                jsr drawPipeEnd
                mva #0 upOrDown
                mva #21 row
                mva #76 upOrDown
                jsr drawPipeEnd
                mva #0 upOrDown

                mva pipe2X pipeX
                mva #32 pipe1Or2
                jsr prepareDataForPipe2

                mva #0 row
                jsr drawPipeEnd
                mva #1 row
                jsr drawPipeEnd
                mva #2 row
                jsr drawPipeEnd
                mva #3 row
                jsr drawPipe
                mva #4 row
                jsr drawPipe
                mva #5 row
                jsr drawPipe
                mva #6 row
                jsr drawPipeEnd
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
                jsr drawPipeEnd
                mva #14 row
                jsr drawPipeEnd
                mva #15 row
                jsr drawPipe
                mva #16 row
                jsr drawPipe
                mva #17 row
                jsr drawPipe
                mva #18 row
                jsr generateSides
                jsr drawPipeEnd
                mva #19 row
                jsr generateSides
                jsr drawPipeEnd
                mva #20 row
                jsr generateSides
                jsr drawPipeEnd
                mva #21 row
                jsr drawPipeEnd

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