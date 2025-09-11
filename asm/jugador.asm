;==========================================================================
;---		             SUB - DIBUJA NAVE                          ---
;---                                                                    ---
;---  HL---> Coordenadas Jugador        ...  B---> Bucle Scanlines      ---
;---  DE---> Puntero direcciones Sprite ...  				---
;==========================================================================
dibuja_nave:
	ld	a,NAVE_Y
	ld	h,a
	ld	a,(nave_x)
	ld	l,a

	ld	de,sprites

	ld	b,$10

	bucle_dibuja_nave:
		dec	l

		ld	a,0
		ld	(hl),a

		inc	l

		ld	a,(de)
		ld	(hl),a

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a

		inc	l

		ld	a,0
		ld	(hl),a

		dec	l
		dec	l

		call	check_next_fila

		inc	de
	
		djnz	bucle_dibuja_nave
		ret

check_next_fila:
	ld	a,h
	and	%00000111
	cp	%00000111 ; $07 decimal 7
	jr	nz, next_scanline

	ld	a,h
	xor	%00000111
	ld	h,a

	ld	a,l
	add	a,$20
	ld	l,a
	ret

	next_scanline:
	inc	h	
	ret
