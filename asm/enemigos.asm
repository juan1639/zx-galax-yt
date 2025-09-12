;---------------------------------------------------------------------------
;---                   M O V E R   M A R C I A N O S                     ---
;---                                                                     ---
;---------------------------------------------------------------------------
mover_marcianos:
	ld	a,(marciano_y)
	ld	h,a
	ld	a,(marciano_x)
	ld	l,a
	
	;-------------------------------
	ld	b,$18

bucle_todos_los_marcianos:
	ld	de,marcianos_sprites
	push	bc

	ld	b,$08

	bucle_dibuja_marciano:
		ld	a,(de)
		ld	(hl),a
	
		inc	l
		inc 	de

		ld	a,(de)
		ld	(hl),a

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a

		dec	l
		dec 	l

		inc	h
		inc	de
	djnz	bucle_dibuja_marciano

		;------------------------------
		; Attr Marciano
		;------------------------------
		;ld	hl,$5824
		;ld	a,%01000100
		;ld	(hl),a

		;inc	l
		;ld	a,%01000100
		;ld	(hl),a

		;inc	l
		;ld	a,%01000100
		;ld	(hl),a

		ld	a,h
		sub	$08
		ld	h,a
		
		inc	l
		inc	l
		inc 	l
		inc	l
		
		pop	bc
		ld	a,b

		cp	$11
		call	z,incrementar_l

		cp	$09
		call	z,decrementar_l

djnz	bucle_todos_los_marcianos
ret

;--------------------------------------
incrementar_l:
	inc	l
	ld	a,l
	add	a,$20
	ld	l,a
	ret

decrementar_l:
	dec	l
	ld	a,l
	add	a,$20
	ld	l,a
	ret

