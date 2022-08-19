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

 db $FF, $FF, $AF, $FF
 db $7F, $1E, $1B, $28
 db $1E, $DF, $FF, $5F
 db $1B, $27, $16, $17
 db $16, $1D, $DF, $FF
 db $3F, $1E, $17, $16
 db $57, $1D, $DF, $FF
 db $2F, $1A, $17, $16
 db $67, $1D, $DF, $FF
 db $1F, $18, $16, $87
 db $1E, $DF, $FF, $19
 db $16, $97, $EF, $EF
 db $19, $97, $16, $19
 db $EF, $DF, $1B, $16
 db $A7, $1D, $EF, $DF
 db $C7, $FF, $CF, $19
 db $16, $97, $16, $1B
 db $FF, $BF, $1E, $C7
 db $FF, $1F, $BF, $1A
 db $B7, $1D, $FF, $1F
 db $BF, $B7, $1C, $FF
 db $2F, $AF, $1E, $97
 db $16, $1B, $FF, $3F
 db $AF, $1D, $77, $16
 db $17, $1B, $FF, $4F
 db $AF, $1C, $67, $16
 db $17, $1E, $FF, $5F
 db $AF, $1C, $67, $1A
 db $FF, $7F, $27, $18
 db $19, $1C, $5F, $1D
 db $37, $18, $1C, $3F
 db $1E, $1B, $19, $18
 db $57, $18, $19, $1A
 db $1D, $8F, $37, $16
 db $27, $18, $1D, $9F
 db $1B, $18, $E7, $1A
 db $1E, $5F, $87, $18
 db $1C, $4F, $1D, $19
 db $17, $16, $F7, $16
 db $17, $1A, $4F, $F7
 db $F7, $77, $1D, $2F
 db $F7, $F7, $87, $1B
 db $1F, $00
 db $08 
 str "Liberty"
 db 00 