PROGSTART = $2000
ANTICDLSTART = $B000
SCREENSTART = $B040 ;remember about 12 bit screen memory counter in ANTIC (4k boundary)
CHARSET = $6000; $6000-$ABFF
;PIPES = $9C00 ; $9C00-9F20

CHBAS = $02F4
CHBASE = $D409

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

STICK0 = $278


;-------RMT stuff------
STEREOMODE = 0

    icl "rmtplayr.a65"
    opt h-
    ins "blah.rmt" ;blah.rmt loads at $4000
    opt h+

MODUL = $4000
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

    ldy #<VBI
	ldx #>VBI
	lda #$7 ;6 - immediate VBI, 7 - deferred VBI
	jsr SETVBV

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

                ;fill 15 mode lines (15*32 = 480 characters)
                ;480 = 256 + 224

                lda #0
                ldx #0
@               sta SCREENSTART, x
                inx
                bne @-

                ldx #0
@               sta SCREENSTART+256, x
                inx
                cpx #224
                bne @-

                .rept 5, (#*32)
                lda #0
                ldx #0
@               sta SCREENSTART+480+:1, x
                clc
                adc #1
                inx
                cpx #32
                bne @-
                .endr

                lda #$80
                ldx #0
@               sta SCREENSTART+640, x
                clc
                adc #1
                inx
                cpx #32
                bne @-

                lda #1
                ldx #31
@               sta SCREENSTART+672, x
                dex
                bpl @-

                pla
                tax
                pla
                rts

;=============================================================
;---------------- undraw pipe  -------------------------------
;=============================================================
undrawPipe
                pha

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
                sta SCREENSTART + 32*21 + 0,x
                lda #58+128
                sta SCREENSTART + 32*21 + 1,x
                lda #59+128
                sta SCREENSTART + 32*21 + 2,x
                lda #60
                sta SCREENSTART + 32*21 + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda #69
                sta SCREENSTART + 32*21 + 0,x
                lda #70+128
                sta SCREENSTART + 32*21 + 1,x
                lda #71+128
                sta SCREENSTART + 32*21 + 2,x
                lda #72+128
                sta SCREENSTART + 32*21 + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda #83
                sta SCREENSTART + 32*21 + 0,x
                lda #84+128
                sta SCREENSTART + 32*21 + 1,x
                lda #85+128
                sta SCREENSTART + 32*21 + 2,x
                lda #86+128
                sta SCREENSTART + 32*21 + 3,x
                lda #87
                sta SCREENSTART + 32*21 + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #98
                sta SCREENSTART + 32*21 + 1,x
                lda #99+128
                sta SCREENSTART + 32*21 + 2,x
                lda #100+128
                sta SCREENSTART + 32*21 + 3,x
                lda #101
                sta SCREENSTART + 32*21 + 4,x
                jmp finishDrawPipe

rows0to14:      ;w A jest row
                ;calcScreenAddr = SCREENSTART + row*32 + pipeX

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
                sta SCREENSTART + 32*# + 0,x
                lda #3+128
                sta SCREENSTART + 32*# + 1,x
                lda #4+128
                sta SCREENSTART + 32*# + 2,x
                lda #5
                sta SCREENSTART + 32*# + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda #14
                sta SCREENSTART + 32*# + 0,x
                lda #15+128
                sta SCREENSTART + 32*# + 1,x
                lda #16+128
                sta SCREENSTART + 32*# + 2,x
                lda #17+128
                sta SCREENSTART + 32*# + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda #28
                sta SCREENSTART + 32*# + 0,x
                lda #29+128
                sta SCREENSTART + 32*# + 1,x
                lda #30+128
                sta SCREENSTART + 32*# + 2,x
                lda #31+128
                sta SCREENSTART + 32*# + 3,x
                lda #32
                sta SCREENSTART + 32*# + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #43
                sta SCREENSTART + 32*# + 1,x
                lda #44+128
                sta SCREENSTART + 32*# + 2,x
                lda #45+128
                sta SCREENSTART + 32*# + 3,x
                lda #46
                sta SCREENSTART + 32*# + 4,x
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
                lda add32,x
                sta SCREENSTART + 32*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + 32*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + 32*(15+#) + 2,x
                lda add64+3,x
                sta SCREENSTART + 32*(15+#) + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda add32,x
                sta SCREENSTART + 32*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + 32*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + 32*(15+#) + 2,x
                lda #98+128
                sta SCREENSTART + 32*(15+#) + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda add32,x
                sta SCREENSTART + 32*(15+#) + 0,x
                lda #96+128
                sta SCREENSTART + 32*(15+#) + 1,x
                lda #97+128
                sta SCREENSTART + 32*(15+#) + 2,x
                lda #98+128
                sta SCREENSTART + 32*(15+#) + 3,x
                lda add64+4,x
                sta SCREENSTART + 32*(15+#) + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #99+128
                sta SCREENSTART + 32*(15+#) + 1,x
                lda #100+128
                sta SCREENSTART + 32*(15+#) + 2,x
                lda #101+128
                sta SCREENSTART + 32*(15+#) + 3,x
                lda add64+4,x
                sta SCREENSTART + 32*(15+#) + 4,x
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
                lda add160,x
                sta SCREENSTART + 32*20 + 0,x
                lda #96+128
                sta SCREENSTART + 32*20 + 1,x
                lda #97+128
                sta SCREENSTART + 32*20 + 2,x
                lda add192+3,x
                sta SCREENSTART + 32*20 + 3,x
                jmp finishDrawPipe

@               ;offset==1
                lda add160,x
                sta SCREENSTART + 32*20 + 0,x
                lda #96+128
                sta SCREENSTART + 32*20 + 1,x
                lda #97+128
                sta SCREENSTART + 32*20 + 2,x
                lda #98+128
                sta SCREENSTART + 32*20 + 3,x
                jmp finishDrawPipe

@               ;offset==2
                lda add160,x
                sta SCREENSTART + 32*20 + 0,x
                lda #96+128
                sta SCREENSTART + 32*20 + 1,x
                lda #97+128
                sta SCREENSTART + 32*20 + 2,x
                lda #98+128
                sta SCREENSTART + 32*20 + 3,x
                lda add192+4,x
                sta SCREENSTART + 32*20 + 4,x
                jmp finishDrawPipe

@               ;offset==3
                lda #99+128
                sta SCREENSTART + 32*20 + 1,x
                lda #100+128
                sta SCREENSTART + 32*20 + 2,x
                lda #101+128
                sta SCREENSTART + 32*20 + 3,x
                lda add192+4,x
                sta SCREENSTART + 32*20 + 4,x
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

add32               dta 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
add64               dta 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
add160              dta 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183
                    dta 184,185,186,187,188,189,190,191
add192              dta 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215
                    dta 216,217,218,219,220,221,222,223

;=============================================================
;---------------- VBLANK routine -----------------------------
;=============================================================
VBI             jsr RASTERMUSICTRACKER+3 ;play

                ;jsr undrawPipe

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
                lda STICK0
                and #$08
                bne @+
                adb pipe1XOffset #$01
                // jsr drawPipe

                ;left
@               lda STICK0
                and #$04
                bne @+
                sbb pipe1XOffset #$01
                // jsr drawPipe

@               lda pipe1XOffset
                cmp #4
                bne @+
                inc pipe1X
                mva #0 pipe1XOffset
                jmp @+1
@               cmp #255
                bne @+
                dec pipe1X
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

                jmp XITVBV ;end vbi

pipe1X          dta $0
pipe1XOffset    dta $0
pipe2X          dta $0
pipe2XOffset    dta $0

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

                pla
                tax
                pla
                rti

currentCharset              dta $0
charsetAddrsForOffset0      dta >CHARSET+$04,>CHARSET+$10,>CHARSET+$1C,>CHARSET+$28,>CHARSET+$34,>CHARSET+$40,>CHARSET
charsetAddrsForOffset1and3  dta >CHARSET+$08,>CHARSET+$14,>CHARSET+$20,>CHARSET+$2C,>CHARSET+$38,>CHARSET+$44,>CHARSET
charsetAddrsForOffset2      dta >CHARSET+$0C,>CHARSET+$18,>CHARSET+$24,>CHARSET+$30,>CHARSET+$3C,>CHARSET+$48,>CHARSET

;=============================================================
;------------- draw background -------------------------------
;=============================================================
drawBackground  nop
                rts

    run codestart

codeend = *

    org ANTICDLSTART
    ;antic has 10 bit program counter (it's best when antic's dl starts on 1k boundary)
antic_dl
    dta $70,$70,$70 ;generate 24 blank lines (8 blank lines times 3)

    dta $44
    dta a(SCREENSTART)

    .rept 13
    dta $04
    .endr

    .rept 7
    dta $84
    .endr

    dta $04

    dta $70,$70

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