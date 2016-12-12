;important: every charset first page must be divisible by 2. (e.g. $6000, $6200, $8400, etc.)

;ORG CHARSET here: 15 mode lines, (sky: $FF, grass: $AA)
    ORG CHARSET
    dta $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    dta $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA

;charset #15
    ORG CHARSET + $0400
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

;ORG CHARSET + $0800 (charset #15a)
;ORG CHARSET + $0C00 (charset #15b)

;charset #16
    ORG CHARSET + $1000
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

;ORG CHARSET + $1400 (charset #16a)
;ORG CHARSET + $1800 (charset #16b)

;charset #17
    ORG CHARSET + $1C00
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

;ORG CHARSET + $2000 (charset #17a)
;ORG CHARSET + $2400 (charset #17b)

;charset #18
    ORG CHARSET + $2800
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

;ORG CHARSET + $2C00 (charset #18a)
;ORG CHARSET + $3000 (charset #18b)

;charset #19
    ORG CHARSET + $3400
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

;ORG CHARSET + $3800 (charset #19a)
;ORG CHARSET + $3C00 (charset #19b)

;charset #20
    ORG CHARSET + $4000
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

;ORG CHARSET + $4400 (charset #20a)
;ORG CHARSET + $4800 (charset #20b)
