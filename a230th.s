; Apple 30th Anniversary Tribute for Apple II by Dave Schmenk
; Original at https://www.applefritter.com/node/24600#comment-60100
; Disassembled, Commented, and ported to Apple II by J.B. Langston
; Assemble with `64tass -b -o a2apple30th.bin -L a2apple30th.lst`

; https://gist.github.com/jblang/5b9e9ba7e6bbfdc64ad2a55759e401d5

KEYBD	= $C000			; keyboard register
STROBE	= $C010			; keyboard strobe register
PTR	= $06			; pointer to current image

*       = $0C00

	org $8000
	lda	#$FF
	pha
	lda	#$00
	pha
FIRSTIMG
	lda	#<IMAGES	; load location of first image
	sta	PTR
	lda	#>IMAGES
	sta	PTR+1
NEXTIMG
	jsr	NEWLINE
NEXTRUN
	ldy	#$00
	lda	(PTR),y		; load run length and character offset
	beq	CENTER 		; $00 indicates end of current image
	lsr	a		; get run length from upper nybble
	lsr	a
	lsr	a
	lsr	a
	tax
	lda	(PTR),y		; get offset from lower nybble
	and	#$0F
	tay
	lda	CHARS,y		; load char at offset
RPTCHAR
	jsr	ECHO		; output character
	dex			; repeat for specified run length
	bne	RPTCHAR
	inc	PTR		; process the next run of characters
	bne	NEXTRUN
	inc	PTR+1
	bne	NEXTRUN
CENTER
	iny			; calculate number of spaces needed
	sec			; to center the caption
	lda	#$28		; screen width (40 decimal)
	sbc	(PTR),y		; subtract caption length
	lsr	a		; divide by 2
	tax			; and use as counter
	lda	#$A0		; output space
NEXTSP
	jsr	ECHO
	dex			; repeat for calculated number of times
	bne	NEXTSP
	lda	(PTR),y		; reload caption length
	tax
NEXTCAP
	iny	
	lda	(PTR),y		; output char from caption
	jsr	ECHO
	dex			; repeat for remaining chars
	bne	NEXTCAP
	iny
	tya			; y contains length of current image
	clc
	adc	PTR		; add it to image start pointer
	sta	PTR		; to find the start of the next image
	lda	#$00
	adc	PTR+1
	sta	PTR+1
	lda	#$10		; delay for a while
	jsr	DELAY
	jsr	NEWLINE		; output a newline
	ldy	#$00		; reset current image pointer
	lda	(PTR),y		; check for $00 end sentinel
	beq	FIRSTIMG	; back to first image if at the end
	bne	NEXTIMG		; otherwise next image
DELAY
	pha			; save registers
	txa
	pha
	tya
	pha
	ldy	#$FF		; loop 256 times
OUTER
	ldx	#$FF		; loop 256 times
INNER
	lda	KEYBD		; check for key press
	bpl	NOKEY		; if none, continue waiting
	pla			; restore registers
	tay
	pla
	tax
	pla
	sta	STROBE		; clear keyboard status bit
	rts			; return early
NOKEY
	dex			; no key pressed, continue waiting
	bne	INNER
	dey
	bne	OUTER
	pla			; restore registers
	tay
	pla
	tax
	pla
	sec
	sbc	#$01		; continue delay until count down to 0
	bne	DELAY
	lda	#$00
	rts
NEWLINE
	pha			; output a newline
	lda	#$8D
	jsr	ECHO
	pla
	rts

ECHO
        ora     #$80            ; disable flashing/reverse video
        jmp     $FDED		; monitor char out routine


CHARS
	db	$A0, $AE, $BA, $AC	;  .:,
	db	$BB, $A1, $AD, $DE	; ;!-^
	db	$AB, $BD, $BF, $A6	; +=/&
	db	$AA, $A5, $A3, $C0	; *%#@

;; Images are run-length encoded with one run per byte
;; Run ength in the upper nybble
;; Offset into the character table above in the lower nybble
;; End of image data is indicated by a $00 byte
;; Next byte contains length of caption
;; Remaining bytes contain caption text
;; Last image is indicated by $00 byte after caption

IMAGES

 db $16, $5F, $19, $17
 db $9F, $15, $19, $7F
 db $16, $19, $CF, $13
 db $6F, $17, $15, $8F
 db $15, $17, $6F, $17
 db $15, $DF, $11, $1C
 db $6F, $15, $13, $1E
 db $6F, $16, $15, $5F
 db $19, $12, $1B, $DF
 db $10, $19, $7F, $15
 db $13, $1C, $5F, $19
 db $16, $1C, $3F, $1B
 db $12, $17, $EF, $10
 db $17, $8F, $15, $13
 db $1B, $1F, $1E, $19
 db $17, $25, $13, $14
 db $19, $1A, $26, $1D
 db $9F, $1C, $1B, $3F
 db $11, $15, $8F, $1D
 db $16, $18, $17, $15
 db $14, $15, $23, $22
 db $21, $15, $18, $7F
 db $1E, $19, $17, $1A
 db $1E, $3F, $11, $14
 db $9F, $1D, $24, $13
 db $45, $24, $12, $13
 db $11, $14, $1B, $4F
 db $1C, $17, $13, $17
 db $1D, $5F, $12, $15
 db $9F, $19, $10, $12
 db $16, $18, $29, $18
 db $39, $15, $13, $12
 db $11, $1D, $1E, $19
 db $15, $12, $16, $1D
 db $7F, $13, $16, $8F
 db $1B, $10, $13, $18
 db $1D, $1C, $18, $15
 db $18, $17, $18, $1A
 db $19, $17, $13, $11
 db $13, $15, $12, $16
 db $1C, $9F, $24, $19
 db $1D, $6A, $14, $11
 db $18, $1E, $1A, $15
 db $14, $18, $1A, $19
 db $18, $26, $27, $12
 db $11, $15, $1C, $BF
 db $14, $15, $17, $12
 db $14, $16, $14, $23
 db $14, $13, $15, $1D
 db $19, $13, $16, $2B
 db $2A, $19, $18, $16
 db $14, $16, $14, $10
 db $16, $CF, $15, $28
 db $14, $1B, $2F, $2E
 db $18, $11, $19, $1A
 db $13, $17, $1C, $29
 db $1A, $16, $12, $14
 db $17, $15, $14, $13
 db $10, $14, $CF, $19
 db $28, $16, $15, $4F
 db $1A, $12, $18, $14
 db $15, $1A, $15, $12
 db $18, $1B, $13, $12
 db $26, $23, $14, $10
 db $11, $18, $1B, $1A
 db $4B, $2C, $1E, $19
 db $18, $1A, $18, $1A
 db $14, $12, $1D, $3F
 db $18, $12, $15, $12
 db $16, $15, $16, $18
 db $2B, $14, $18, $1B
 db $17, $22, $16, $15
 db $11, $10, $12, $23
 db $24, $16, $17, $18
 db $1B, $1C, $15, $17
 db $19, $1B, $15, $24
 db $16, $14, $23, $17
 db $18, $14, $15, $17
 db $1B, $1D, $19, $23
 db $18, $19, $18, $16
 db $13, $16, $18, $11
 db $15, $2C, $1D, $1E
 db $6F, $1E, $17, $1C
 db $17, $12, $21, $14
 db $15, $27, $19, $16
 db $15, $19, $3B, $16
 db $11, $12, $29, $16
 db $15, $12, $15, $18
 db $12, $1B, $BF, $1C
 db $18, $11, $20, $14
 db $3F, $1E, $18, $14
 db $17, $39, $1A, $19
 db $17, $16, $18, $19
 db $16, $14, $11, $12
 db $16, $14, $1A, $BF
 db $18, $32, $13, $12
 db $1D, $2F, $1E, $15
 db $12, $16, $28, $19
 db $1A, $28, $27, $18
 db $15, $13, $31, $12
 db $1C, $BF, $14, $17
 db $13, $17, $14, $10
 db $17, $3F, $14, $11
 db $15, $17, $18, $19
 db $2A, $19, $18, $17
 db $16, $14, $12, $11
 db $22, $13, $CF, $18
 db $24, $19, $11, $15
 db $17, $19, $1E, $1F
 db $1E, $12, $16, $19
 db $18, $29, $17, $16
 db $15, $13, $12, $13
 db $12, $10, $14, $15
 db $11, $1D, $BF, $15
 db $10, $17, $26, $1B
 db $17, $16, $19, $1F
 db $1A, $13, $15, $17
 db $19, $17, $15, $34
 db $13, $32, $11, $12
 db $11, $14, $1D, $BF
 db $11, $14, $19, $15
 db $17, $18, $13, $18
 db $19, $18, $19, $18
 db $23, $16, $24, $25
 db $24, $13, $32, $11
 db $14, $19, $1A, $BF
 db $13, $18, $1A, $26
 db $14, $16, $19, $18
 db $29, $18, $1A, $24
 db $25, $14, $15, $34
 db $13, $22, $11, $17
 db $1A, $17, $1E, $AF, $00
 db $08 
 str "Liberty"
 db 00 