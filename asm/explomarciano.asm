;========================================================
; D I B U J A R  la explosion del marciano (si procede)
; 
;--------------------------------------------------------
frames_explo_marciano:
	ld	a,(explo_marciano_timer)
	or	a
	ret	z	; Retorna si no procede dibujar explosion

	;-------------------------------------------
	; Decrementar cuenta atras (siguiente frame)
	;-------------------------------------------
	dec	a
	ld	(explo_marciano_timer),a

	;-------------------------------------------
	; Seleccionar frame explo a dibujar
	;-------------------------------------------
	ld	de,bytes_explo_marciano

	inc	a
	ld	b,a

	bucle_selecc_frame_explo:
		call	sumar_de_24
	djnz	bucle_selecc_frame_explo

	;---------------------------------------
	; Asignar coor hl para dibujar explosion
	;---------------------------------------
	ld	a,(explo_marciano_y)
	ld	h,a

	ld	a,(explo_marciano_x)
	ld	l,a
	
	;--------------------------------------
	ld	b,$08

	bucle_dibuja_explo:
		ld	a,(de)
		ld	(hl),a

		inc	l
		inc	de
		
		ld	a,(de)
		ld	(hl),a

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a

		dec	l
		dec	l

		inc	h
		inc	de
	djnz	bucle_dibuja_explo
		
	ret
