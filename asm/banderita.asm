;==================================================
;    D I B U J A R   B A N D E R I T A  (nivel)
;--------------------------------------------------
dibujar_banderita:
	ld	h,$50	; Tercer tercio
	ld	l,$e0	; A la izquierda la primera, etc...
	
	ld	a,(nivel)
	ld	b,a

	bucle_cuantas_banderitas:
		ld	de,banderita

		push	bc

		ld	b,$08

		bucle_dibuja_banderita
			ld	a,(de)
			ld	(hl),a

			inc	l
			inc	de

			ld	a,(de)
			ld	(hl),a

			dec	l
			inc 	h
			inc	de
		djnz	bucle_dibuja_banderita

		pop	bc

		ld	a,h
		sub	$08
		ld	h,a

		;------------------------
		push	hl

		ld	h,$5a
		ld	a,%01000111	; Color blanco grisaceo
		ld	(hl),a		; (palo banderita)

		inc	l
		ld	a,%01000010	; Color Rojo brillante
		ld	(hl),a		; (banderita)
		
		pop	hl

		;------------------------
		inc	l
		inc	l

	djnz	bucle_cuantas_banderitas
ret

