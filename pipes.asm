    org PIPES

pipe            dta $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
                dta $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF
                dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                dta $03,$03,$03,$03,$03,$03,$03,$03



pipeUpEnd1      dta $C6,$C6,$C6,$C0,$00,$1A,$1A,$1A
                dta $AF,$AF,$AF,$00,$00,$BF,$BF,$BF
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $03,$03,$03,$00,$00,$00,$00,$00

pipeUpEnd2      dta $1A,$1A,$1A,$1A,$1A,$1A,$15,$00
                dta $BF,$BF,$BF,$BF,$BF,$BF,$55,$00
                dta $FF,$FF,$FF,$FF,$FF,$FF,$6A,$00
                dta $00,$C0,$C0,$C0,$C0,$C0,$A0,$00



pipeDownEnd2    dta $00,$15,$1A,$1A,$1A,$1A,$1A,$1A
                dta $00,$55,$BF,$BF,$BF,$BF,$BF,$BF
                dta $00,$6A,$FF,$FF,$FF,$FF,$FF,$FF
                dta $00,$A0,$C0,$C0,$C0,$C0,$C0,$00

pipeDownEnd1    dta $1A,$1A,$1A,$00,$C0,$C6,$C6,$C6
                dta $BF,$BF,$BF,$00,$00,$AF,$AF,$AF
                dta $FF,$FF,$FF,$00,$00,$FF,$FF,$FF
                dta $00,$00,$00,$00,$00,$03,$03,$03
