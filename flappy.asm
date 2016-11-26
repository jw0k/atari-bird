PROGSTART = $2000
ANTICDLSTART = $9000
SCREENSTART = $9081 ;remember about 12 bit screen memory counter in ANTIC (4k boundary)
CHARSET0 = $6000
PIPES = $8D00

CHBAS = $02F4
CHBASE = $D409

NMIEN = $D40E
VDSLST = $0200

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

    ldx #<MODUL
	ldy #>MODUL
	lda #0 ;starting song line
	jsr RASTERMUSICTRACKER ;init

    ;wait for vblank
    lda RTCLOK3
    cmp RTCLOK3
    beq *-2 ;jump 2 bytes backwards (to the first byte of cmp instruction)

    ldy #<VBI
	ldx #>VBI
	lda #$7 ;6 - immediate VBI, 7 - deferred VBI
	jsr SETVBV

    ;set new address of antic's display list
    mwa	#antic_dl SDLSTL
    
    mva #>CHARSET0 CHBAS
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
;---------------- VBLANK routine -----------------------------
;=============================================================
VBI             jsr RASTERMUSICTRACKER+3 ;play

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
                inc COLOR3

                ;left
@               lda STICK0
                and #$04
                bne @+
                dec COLOR3
                

@               jmp XITVBV ;end vbi


;=============================================================
;---------------- DLI routine --------------------------------
;=============================================================
DLI         pha
            
            lda currCharset
            clc
            adc #4
            cmp #(>CHARSET0+$2C)
            bne @+
            lda #>CHARSET0
@           sta currCharset
            sta WSYNC
            sta CHBASE
            pla
            rti            
currCharset dta >CHARSET0

;=============================================================
;------------- draw background -------------------------------
;=============================================================
drawBackground  nop
                rti

;=============================================================
;------------- draw pipe at pipeX, pipeBlocks ----------------
;=============================================================
drawPipe    nop
            rti
pipeX       dta 0
pipeBlocks  dta 0
                
    run codestart

codeend = *

    org ANTICDLSTART
    ;antic has 10 bit program counter (it's best when antic's dl starts on 1k boundary)
antic_dl ;mode2 = 40x24 characters (960 bytes) for normal width, 48x24 characters (1152 bytes for wide width or hscrol enabled)
    dta $70,$70,$70 ;generate 24 blank lines (8 blank lines times 3)

    dta $44
    dta a(SCREENSTART)
    dta $84
    
    .rept 10
    dta $04
    dta $84
    .endr
    
    dta $70,$70

    dta $41 ;jump and wait for vblank
    dta a(antic_dl) ;display list address

 
    icl "background.asm"
    icl "pipes.asm"


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
