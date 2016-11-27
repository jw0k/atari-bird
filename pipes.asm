;TODO: generate shifted values using cpu instead of pre-calculating

;now it is 800 bytes ($0320)

    org PIPES

pipe            dta $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
                dta $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF
                dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                dta $03,$03,$03,$03,$03,$03,$03,$03
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipe1           dta $31,$31,$31,$31,$31,$31,$31,$31
                dta $AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB
                dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                dta $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                dta $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0

pipe2           dta $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                dta $6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A
                dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                dta $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                dta $30,$30,$30,$30,$30,$30,$30,$30

pipe3           dta $03,$03,$03,$03,$03,$03,$03,$03
                dta $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
                dta $BF,$BF,$BF,$BF,$BF,$BF,$BF,$BF
                dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
                dta $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C



pipeUpMid       dta $C6,$C6,$C6,$C0,$00,$1A,$1A,$1A
                dta $AF,$AF,$AF,$00,$00,$BF,$BF,$BF
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $03,$03,$03,$00,$00,$00,$00,$00
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeUpMid1      dta $31,$31,$31,$30,$00,$06,$06,$06
                dta $AB,$AB,$AB,$00,$00,$AF,$AF,$AF
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $C0,$C0,$C0,$00,$00,$C0,$C0,$C0
                dta $C0,$C0,$C0,$00,$00,$00,$00,$00

pipeUpMid2      dta $0C,$0C,$0C,$0C,$00,$01,$01,$01
                dta $6A,$6A,$6A,$00,$00,$AB,$AB,$AB
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $F0,$F0,$F0,$00,$00,$F0,$F0,$F0
                dta $30,$30,$30,$00,$00,$00,$00,$00

pipeUpMid3      dta $03,$03,$03,$03,$00,$00,$00,$00
                dta $1A,$1A,$1A,$00,$00,$6A,$6A,$6A
                dta $BF,$BF,$BF,$00,$00,$FF,$FF,$FF
                dta $FC,$FC,$FC,$00,$00,$FC,$FC,$FC
                dta $0C,$0C,$0C,$00,$00,$00,$00,$00


pipeUpEnd       dta $1A,$1A,$1A,$1A,$1A,$1A,$15,$00
                dta $BF,$BF,$BF,$BF,$BF,$BF,$55,$00
                dta $FF,$FF,$FF,$FF,$FF,$FF,$6A,$00
                dta $00,$C0,$C0,$C0,$C0,$C0,$A0,$00
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeUpEnd1      dta $06,$06,$06,$06,$06,$06,$05,$00
                dta $AF,$AF,$AF,$AF,$AF,$AF,$55,$00
                dta $FF,$FF,$FF,$FF,$FF,$FF,$5A,$00
                dta $C0,$F0,$F0,$F0,$F0,$F0,$A8,$00
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeUpEnd2      dta $01,$01,$01,$01,$01,$01,$01,$00
                dta $AB,$AB,$AB,$AB,$AB,$AB,$55,$00
                dta $FF,$FF,$FF,$FF,$FF,$FF,$56,$00
                dta $F0,$FC,$FC,$FC,$FC,$FC,$AA,$00
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeUpEnd3      dta $00,$00,$00,$00,$00,$00,$00,$00
                dta $6A,$6A,$6A,$6A,$6A,$6A,$55,$00
                dta $FF,$FF,$FF,$FF,$FF,$FF,$55,$00
                dta $FC,$FF,$FF,$FF,$FF,$FF,$AA,$00
                dta $00,$00,$00,$00,$00,$00,$80,$00



pipeDownEnd     dta $00,$15,$1A,$1A,$1A,$1A,$1A,$1A
                dta $00,$55,$BF,$BF,$BF,$BF,$BF,$BF
                dta $00,$6A,$FF,$FF,$FF,$FF,$FF,$FF
                dta $00,$A0,$C0,$C0,$C0,$C0,$C0,$00
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeDownEnd1    dta $00,$05,$06,$06,$06,$06,$06,$06
                dta $00,$55,$AF,$AF,$AF,$AF,$AF,$AF
                dta $00,$5A,$FF,$FF,$FF,$FF,$FF,$FF
                dta $00,$A8,$F0,$F0,$F0,$F0,$F0,$C0
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeDownEnd2    dta $00,$01,$01,$01,$01,$01,$01,$01
                dta $00,$55,$AB,$AB,$AB,$AB,$AB,$AB
                dta $00,$56,$FF,$FF,$FF,$FF,$FF,$FF
                dta $00,$AA,$FC,$FC,$FC,$FC,$FC,$F0
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeDownEnd3    dta $00,$00,$00,$00,$00,$00,$00,$00
                dta $00,$55,$6A,$6A,$6A,$6A,$6A,$6A
                dta $00,$55,$FF,$FF,$FF,$FF,$FF,$FF
                dta $00,$AA,$FF,$FF,$FF,$FF,$FF,$FC
                dta $00,$80,$00,$00,$00,$00,$00,$00

pipeDownMid     dta $1A,$1A,$1A,$00,$C0,$C6,$C6,$C6
                dta $BF,$BF,$BF,$00,$00,$AF,$AF,$AF
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $00,$00,$00,$00,$00,$03,$03,$03
                dta $00,$00,$00,$00,$00,$00,$00,$00

pipeDownMid1    dta $06,$06,$06,$00,$30,$31,$31,$31
                dta $AF,$AF,$AF,$00,$00,$AB,$AB,$AB
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $C0,$C0,$C0,$00,$00,$C0,$C0,$C0
                dta $00,$00,$00,$00,$00,$C0,$C0,$C0

pipeDownMid2    dta $01,$01,$01,$00,$0C,$0C,$0C,$0C
                dta $AB,$AB,$AB,$00,$00,$6A,$6A,$6A
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $F0,$F0,$F0,$00,$00,$F0,$F0,$F0
                dta $00,$00,$00,$00,$00,$30,$30,$30

pipeDownMid3    dta $00,$00,$00,$00,$03,$03,$03,$03
                dta $6A,$6A,$6A,$00,$00,$1A,$1A,$1A
                dta $FF,$FF,$FF,$00,$00,$BF,$BF,$BF
                dta $FC,$FC,$FC,$00,$00,$FC,$FC,$FC
                dta $00,$00,$00,$00,$00,$0C,$0C,$0C
