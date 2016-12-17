;important: every charset first page must be divisible by 2. (e.g. $6000, $6200, $8400, etc.)

;ORG CHARSET; 15 mode lines, (sky: $FF, grass: $AA)
    ORG CHARSET
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA

    ;sky+pipe (offset 0)
    dta $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
    dta $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $03,$03,$03,$03,$03,$03,$03,$03

    ;sky+endUp (offset 0) (actually - no sky for offset 0)
    dta $00,$1A,$1A,$1A,$1A,$1A,$15,$00
    dta $00,$BF,$BF,$BF,$BF,$BF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$6B,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00

    ;sky+endDown (offset 0) (actually - no sky for offset 0)
    dta $00,$15,$1A,$1A,$1A,$1A,$1A,$00
    dta $00,$55,$BF,$BF,$BF,$BF,$BF,$00
    dta $00,$6B,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00


    ;sky+pipe (offset 1)
    dta $F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1
    dta $AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0

    ;sky+endUp (offset 1)
    dta $C0,$C6,$C6,$C6,$C6,$C6,$C5,$C0
    dta $00,$AF,$AF,$AF,$AF,$AF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$5A,$00
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00
    dta $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F

    ;sky+endDown (offset 1)
    dta $C0,$C5,$C6,$C6,$C6,$C6,$C6,$C0
    dta $00,$55,$AF,$AF,$AF,$AF,$AF,$00
    dta $00,$5A,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00
    dta $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F


    ;sky+pipe (offset 2)
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    dta $6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
    dta $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F

    ;sky+endUp (offset 2)
    dta $F0,$F1,$F1,$F1,$F1,$F1,$F1,$F0
    dta $00,$AB,$AB,$AB,$AB,$AB,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$56,$00
    dta $00,$FC,$FC,$FC,$FC,$FC,$BC,$00
    dta $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F

    ;sky+endDown (offset 2)
    dta $F0,$F1,$F1,$F1,$F1,$F1,$F1,$F0
    dta $00,$55,$AB,$AB,$AB,$AB,$AB,$00
    dta $00,$56,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$BC,$FC,$FC,$FC,$FC,$FC,$00
    dta $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F


    ;sky+pipe (offset 3)
    dta $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
    dta $BF,$BF,$BF,$BF,$BF,$BF,$BF,$BF
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    dta $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F

    ;sky+endUp (offset 3)
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    dta $00,$6A,$6A,$6A,$6A,$6A,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$AF,$00
    dta $03,$03,$03,$03,$03,$03,$03,$03

    ;sky+endDown (offset 3)
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    dta $00,$55,$6A,$6A,$6A,$6A,$6A,$00
    dta $00,$55,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$AF,$FF,$FF,$FF,$FF,$FF,$00
    dta $03,$03,$03,$03,$03,$03,$03,$03




    ;grass+pipe (offset 0)
    dta $86,$86,$86,$86,$86,$86,$86,$86
    dta $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $02,$02,$02,$02,$02,$02,$02,$02

    ;grass+endUp (offset 0) (actually - no grass for offset 0)
    dta $00,$1A,$1A,$1A,$1A,$1A,$15,$00
    dta $00,$BF,$BF,$BF,$BF,$BF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$6B,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00

    ;grass+endDown (offset 0) (actually - no grass for offset 0)
    dta $00,$15,$1A,$1A,$1A,$1A,$1A,$00
    dta $00,$55,$BF,$BF,$BF,$BF,$BF,$00
    dta $00,$6B,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00


    ;grass+pipe (offset 1)
    dta $A1,$A1,$A1,$A1,$A1,$A1,$A1,$A1
    dta $AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0

    ;grass+endUp (offset 1)
    dta $80,$86,$86,$86,$86,$86,$85,$80
    dta $00,$AF,$AF,$AF,$AF,$AF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$5A,$00
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00
    dta $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A

    ;grass+endDown (offset 1)
    dta $80,$85,$86,$86,$86,$86,$86,$80
    dta $00,$55,$AF,$AF,$AF,$AF,$AF,$00
    dta $00,$5A,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00
    dta $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A


    ;grass+pipe (offset 2)
    dta $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
    dta $6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
    dta $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A

    ;grass+endUp (offset 2)
    dta $A0,$A1,$A1,$A1,$A1,$A1,$A1,$A0
    dta $00,$AB,$AB,$AB,$AB,$AB,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$56,$00
    dta $00,$FC,$FC,$FC,$FC,$FC,$BC,$00
    dta $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A

    ;grass+endDown (offset 2)
    dta $A0,$A1,$A1,$A1,$A1,$A1,$A1,$A0
    dta $00,$55,$AB,$AB,$AB,$AB,$AB,$00
    dta $00,$56,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$BC,$FC,$FC,$FC,$FC,$FC,$00
    dta $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A


    ;grass+pipe (offset 3)
    dta $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
    dta $BF,$BF,$BF,$BF,$BF,$BF,$BF,$BF
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    dta $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A

    ;grass+endUp (offset 3)
    dta $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
    dta $00,$6A,$6A,$6A,$6A,$6A,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$AF,$00
    dta $02,$02,$02,$02,$02,$02,$02,$02

    ;grass+endDown (offset 3)
    dta $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
    dta $00,$55,$6A,$6A,$6A,$6A,$6A,$00
    dta $00,$55,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$AF,$FF,$FF,$FF,$FF,$FF,$00
    dta $02,$02,$02,$02,$02,$02,$02,$02


;charset #15
    ORG CHARSET + $0400
charset0
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD
    dta $FF,$FF,$FF,$FF,$FF,$FF,$57,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FD,$F5
    dta $FF,$FF,$FF,$FF,$FF,$FF,$57,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FD,$F5,$D5,$55
    dta $FF,$FF,$FF,$FF,$57,$55,$55,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$7F,$7F
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$F5,$D5
    dta $FF,$FF,$FF,$FF,$FF,$FF,$5F,$57
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $FF,$FF,$FF,$FF,$FF,$FF,$F5,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$7F,$57

    ;here: precalculated 32 characters - background merged with left pipe (offset 0)
    ;here: precalculated 32 characters - background merged with right pipe (offset 0)

    ORG CHARSET + $0400 + 8*96
    dta $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF ;middle-left pipe (offset 0)
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;middle-right pipe (offset 0)

    ;endUp (offset 0)
    dta $00,$1A,$1A,$1A,$1A,$1A,$15,$00
    dta $00,$BF,$BF,$BF,$BF,$BF,$55,$00
    dta $00,$FF,$FF,$FF,$FF,$FF,$6B,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00

    ;endDown (offset 0)
    dta $00,$15,$1A,$1A,$1A,$1A,$1A,$00
    dta $00,$55,$BF,$BF,$BF,$BF,$BF,$00
    dta $00,$6B,$FF,$FF,$FF,$FF,$FF,$00
    dta $00,$C0,$C0,$C0,$C0,$C0,$C0,$00


    ORG CHARSET + $0800
charset0a
    ;here: copied 32 background characters
    ;here: precalculated 32 characters - background merged with left pipe (offset 1)
    ;here: precalculated 32 characters - background merged with right pipe (offset 3)

    ORG CHARSET + $0800 + 8*96
    dta $AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB ;middle-left pipe (offset 1)
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;middle-right pipe (offset 1)
    dta $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0 ;right pipe (offset 1)

    dta $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ;left pipe (offset 3)
    dta $BF,$BF,$BF,$BF,$BF,$BF,$BF,$BF ;middle-left pipe (offset 3)
    dta $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC ;middle-right pipe (offset 3)

    dta $00,$AF,$AF,$AF,$AF,$AF,$55,$00 ;middle-left endUp (offset 1)
    dta $00,$FF,$FF,$FF,$FF,$FF,$5A,$00 ;middle endUp (offset 1)
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00 ;middle-right endUp (offset 1)

    dta $00,$6A,$6A,$6A,$6A,$6A,$55,$00 ;middle-left endUp (offset 3)
    dta $00,$FF,$FF,$FF,$FF,$FF,$55,$00 ;middle endUp (offset 3)
    dta $00,$FF,$FF,$FF,$FF,$FF,$AF,$00 ;middle-right endUp (offset 3)

    dta $00,$55,$AF,$AF,$AF,$AF,$AF,$00 ;middle-left endDown (offset 1)
    dta $00,$5A,$FF,$FF,$FF,$FF,$FF,$00 ;middle endDown (offset 1)
    dta $00,$F0,$F0,$F0,$F0,$F0,$F0,$00 ;middle-right endDown (offset 1)

    dta $00,$55,$6A,$6A,$6A,$6A,$6A,$00 ;middle-left endDown (offset 3)
    dta $00,$55,$FF,$FF,$FF,$FF,$FF,$00 ;middle endDown (offset 3)
    dta $00,$AF,$FF,$FF,$FF,$FF,$FF,$00 ;middle-right endDown (offset 3)

    ;here: 8 runtime-generated characters (left endUp offset 1, right endUp offset 1,
    ;left endUp offset 3, right endUp offset 3, left endDown offset 1, right endDown offset 1,
    ;left endDown offset 3, right endDown offset 3)


    ORG CHARSET + $0C00
charset0b
    ;here: copied 32 background characters
    ;here: precalculated 32 characters - background merged with left pipe (offset 2)
    ;here: precalculated 32 characters - background merged with right pipe (offset 2)

    ORG CHARSET + $0C00 + 8*96
    dta $6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A ;middle-left pipe (offset 2)
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;middle pipe (offset 2)
    dta $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0 ;middle-right pipe (offset 2)

    dta $00,$AB,$AB,$AB,$AB,$AB,$55,$00 ;middle-left endUp (offset 2)
    dta $00,$FF,$FF,$FF,$FF,$FF,$56,$00 ;middle endUp (offset 2)
    dta $00,$FC,$FC,$FC,$FC,$FC,$BC,$00 ;middle-right endUp (offset 2)

    dta $00,$55,$AB,$AB,$AB,$AB,$AB,$00 ;middle-left endDown (offset 2)
    dta $00,$56,$FF,$FF,$FF,$FF,$FF,$00 ;middle endDown (offset 2)
    dta $00,$BC,$FC,$FC,$FC,$FC,$FC,$00 ;middle-right endDown (offset 2)

    ;here: 4 runtime-generated characters (left endUp offset 2, right endUp offset 2,
    ;left endDown offset 2, right endDown offset 2)


;charset #16
    ORG CHARSET + $1000
charset1
    dta $F5,$D5,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $7F,$5F,$57,$57,$55,$55,$55,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$7D,$75
    dta $FF,$FF,$FF,$FF,$FF,$FF,$5F,$57
    dta $FF,$FF,$FD,$FD,$F5,$D5,$D5,$D5
    dta $D5,$55,$55,$55,$55,$55,$55,$55
    dta $FF,$7F,$5F,$57,$57,$55,$55,$55
    dta $FF,$FF,$FD,$FD,$F5,$D5,$55,$55
    dta $FF,$57,$55,$55,$55,$55,$55,$55
    dta $D5,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $7F,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $7F,$5D,$55,$55,$55,$55,$55,$55
    dta $57,$55,$55,$55,$55,$55,$55,$55
    dta $FF,$7F,$5F,$5F,$57,$55,$55,$55
    dta $FF,$FD,$F5,$F5,$55,$55,$55,$55
    dta $FF,$5D,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $FF,$FF,$7F,$7F,$5F,$5F,$5F,$5F
    dta $FF,$FF,$FF,$FF,$FF,$FF,$D5,$55
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FD,$5D
    dta $FD,$F5,$D5,$D5,$55,$55,$55,$55
    dta $57,$55,$55,$55,$55,$55,$55,$55
    dta $FF,$FF,$7F,$7F,$7F,$5D,$55,$55
    dta $FF,$F5,$D5,$D5,$55,$55,$55,$55
    dta $FD,$7D,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55

    ORG CHARSET + $1400
charset1a

    ORG CHARSET + $1800
charset1b

;charset #17
    ORG CHARSET + $1C00
charset2
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$57
    dta $55,$55,$55,$55,$55,$5F,$5D,$FD
    dta $55,$55,$55,$55,$55,$D5,$D5,$D5
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$5F
    dta $55,$55,$55,$55,$55,$7F,$77,$F7
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$5F
    dta $55,$55,$55,$55,$55,$7F,$77,$F7
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$7F
    dta $55,$55,$55,$55,$55,$FD,$DD,$DD
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$7F
    dta $55,$55,$55,$55,$55,$FD,$DD,$DD
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$57,$57,$FF
    dta $55,$55,$55,$55,$55,$F5,$75,$75
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$55,$55,$55,$55,$55,$55,$55

    ORG CHARSET + $2000
charset2a

    ORG CHARSET + $2400
charset2b

;charset #18
    ORG CHARSET + $2800
charset3
    dta $55,$F5,$75,$FF,$55,$99,$99,$55
    dta $55,$55,$55,$D5,$D5,$D5,$D5,$D5
    dta $55,$57,$57,$57,$7F,$75,$76,$76
    dta $57,$FF,$5F,$5F,$FF,$5F,$6F,$6F
    dta $55,$66,$66,$55,$66,$66,$55,$66
    dta $D5,$FD,$DD,$FF,$DB,$DB,$D7,$DB
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$5F,$5D,$5D,$FF,$D5,$D9,$D9
    dta $5D,$FD,$7D,$7D,$FD,$7D,$BD,$BD
    dta $57,$9B,$9B,$57,$9B,$9B,$57,$9B
    dta $55,$F5,$75,$FF,$67,$67,$57,$67
    dta $55,$55,$55,$55,$55,$55,$55,$55
    dta $55,$5F,$5D,$5D,$FF,$D5,$D9,$D9
    dta $5D,$FD,$7D,$7D,$FD,$7D,$BD,$BD
    dta $57,$9B,$9B,$57,$9B,$9B,$57,$9B
    dta $55,$F5,$75,$FD,$6D,$6D,$5D,$6D
    dta $55,$55,$55,$55,$57,$57,$57,$57
    dta $55,$7F,$75,$75,$FF,$55,$66,$66
    dta $75,$F6,$F6,$F5,$F6,$F6,$F5,$F6
    dta $5D,$6F,$6D,$5F,$6D,$6D,$5D,$6D
    dta $55,$D5,$D5,$FD,$9D,$9D,$5D,$9D
    dta $55,$55,$55,$55,$57,$57,$57,$57
    dta $55,$7F,$75,$75,$FF,$55,$66,$66
    dta $75,$F6,$F6,$F5,$F6,$F6,$F5,$F6
    dta $5D,$6F,$6D,$5F,$6D,$6D,$5D,$6D
    dta $55,$D5,$D5,$FD,$9D,$9D,$5D,$9D
    dta $55,$55,$55,$55,$5F,$5D,$5D,$5D
    dta $55,$FF,$D7,$D7,$FF,$57,$9B,$9B
    dta $D5,$D9,$D9,$D5,$D9,$D9,$D5,$D9
    dta $75,$BF,$B7,$7F,$B6,$B6,$75,$B6
    dta $55,$55,$55,$F5,$75,$75,$75,$75
    dta $55,$55,$55,$55,$5F,$5D,$5D,$5D

    ORG CHARSET + $2C00
charset3a

    ORG CHARSET + $3000
charset3b

;charset #19
    ORG CHARSET + $3400
charset4
    dta $99,$99,$55,$99,$99,$55,$99,$99
    dta $D5,$D5,$D5,$D5,$D5,$D5,$DA,$EA
    dta $75,$76,$76,$75,$76,$76,$75,$B5
    dta $5F,$FF,$D7,$D7,$D7,$D7,$DA,$EA
    dta $66,$55,$66,$66,$55,$66,$D5,$A6
    dta $DB,$D7,$DB,$DB,$D7,$D7,$A7,$AB
    dta $55,$55,$55,$55,$55,$55,$55,$56
    dta $D5,$DB,$DB,$D7,$DB,$DB,$AB,$AA
    dta $7D,$FD,$5D,$5D,$5D,$5D,$69,$AA
    dta $9B,$57,$9B,$9B,$57,$9B,$9B,$57
    dta $67,$57,$67,$67,$57,$67,$67,$57
    dta $55,$55,$55,$55,$55,$55,$69,$AA
    dta $D5,$DB,$DB,$D7,$DB,$DB,$D7,$D7
    dta $7D,$FD,$5D,$6D,$6D,$5D,$6A,$AA
    dta $9B,$57,$9B,$9B,$57,$9B,$56,$9A
    dta $6D,$5D,$6D,$6D,$5D,$5D,$9D,$AD
    dta $57,$57,$57,$57,$57,$57,$56,$5A
    dta $55,$6F,$6D,$5D,$6D,$6D,$AD,$AA
    dta $F6,$F5,$76,$76,$75,$76,$A6,$A9
    dta $6D,$5D,$6D,$6D,$5D,$6D,$6D,$5D
    dta $9D,$5D,$9D,$9D,$5D,$9D,$9D,$5E
    dta $57,$57,$57,$57,$57,$57,$A7,$AB
    dta $55,$6F,$6D,$5D,$6D,$6D,$7D,$7E
    dta $F6,$F5,$76,$76,$75,$76,$A9,$AA
    dta $6D,$5D,$6D,$6D,$5D,$6D,$7A,$6A
    dta $9D,$5D,$9D,$9D,$5D,$9D,$5D,$9D
    dta $5D,$5D,$5D,$5D,$5D,$5D,$5E,$5A
    dta $57,$BF,$B5,$75,$B5,$B6,$B6,$AA
    dta $D9,$D5,$D9,$D9,$D5,$D9,$95,$A9
    dta $B6,$75,$B6,$B6,$75,$B6,$B6,$75
    dta $75,$75,$75,$75,$75,$75,$76,$7A
    dta $5D,$5D,$5D,$5D,$5D,$5D,$9D,$AD

    ORG CHARSET + $3800
charset4a

    ORG CHARSET + $3C00
charset4b

;charset #20
    ORG CHARSET + $4000
charset5
    dta $57,$F6,$AE,$AB,$AA,$AB,$AB,$AA
    dta $EA,$AA,$AA,$EF,$FA,$EA,$AA,$AA
    dta $B7,$BE,$BA,$EA,$EA,$BA,$AE,$AE
    dta $FA,$BE,$AB,$AA,$AA,$AA,$AB,$AB
    dta $AE,$AA,$AA,$EF,$BA,$EA,$EA,$AA
    dta $AB,$BE,$EB,$AA,$FA,$BA,$AE,$AE
    dta $5F,$FA,$AA,$AA,$AA,$AA,$AA,$AA
    dta $AA,$EA,$BA,$AE,$AE,$AB,$AB,$AE
    dta $EA,$BA,$BB,$BE,$EB,$AA,$AA,$AA
    dta $D7,$FE,$AA,$AA,$AA,$EA,$BA,$BA
    dta $67,$DE,$BE,$AF,$AA,$AB,$AB,$AE
    dta $AA,$AA,$AA,$BF,$EB,$AA,$AA,$AA
    dta $DB,$BE,$EA,$AA,$AA,$EA,$BA,$BA
    dta $EA,$BA,$AE,$AB,$AB,$AB,$AE,$AE
    dta $BA,$AA,$AB,$BF,$EB,$AA,$AA,$AA
    dta $AD,$FB,$AE,$AA,$EA,$BA,$BA,$BA
    dta $7E,$EB,$AA,$AA,$AA,$AA,$AA,$AA
    dta $AB,$AA,$EA,$BA,$BB,$AE,$AE,$AA
    dta $AB,$EB,$EF,$FA,$AE,$AB,$AA,$AA
    dta $9D,$FB,$AA,$AA,$AA,$AA,$EA,$EA
    dta $9E,$7A,$FA,$AE,$AB,$AE,$BA,$BA
    dta $AB,$AB,$AB,$FA,$AE,$AB,$AA,$AA
    dta $5F,$FA,$AA,$AA,$AA,$AA,$EA,$EA
    dta $AA,$EA,$BA,$AE,$AF,$AE,$AE,$BA
    dta $EA,$BB,$BE,$FE,$AB,$AA,$AA,$AA
    dta $BD,$FB,$BE,$BA,$BA,$EA,$EA,$EA
    dta $FA,$AE,$AB,$AA,$AA,$AA,$AA,$AA
    dta $AE,$AB,$AB,$EB,$EE,$BA,$BA,$AA
    dta $AB,$AF,$BA,$FA,$BE,$AB,$AB,$AA
    dta $75,$EF,$AA,$AA,$AA,$AA,$AA,$AA
    dta $7A,$EA,$EA,$BB,$AE,$BA,$EA,$EA
    dta $AE,$AB,$AF,$EA,$BA,$AE,$AF,$AB

    ORG CHARSET + $4400
charset5a

    ORG CHARSET + $4800
charset5b
