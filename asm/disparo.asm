;===========================================================================
;		  R E C O R R I D O   D E L   D I S P A R O
;---------------------------------------------------------------------------
disparo:
	ld	a,(settings)
	bit	0,a
	ret	z

	;-------------------------------
	; Borra disparo
	;-------------------------------
		ld	a,(disparo_y)	; Borrar CoorY (vieja)
		ld	h,a
		ld	a,(disparo_x)	; Borrar CoorX (vieja)
		ld	l,a

		;---------------- Sonido disparo ----------------
		ld	a,$01
		call	sonido

		;------------------------------------------------
		ld	b,$08

		bucle_borra_disparo:
		ld	(hl),$00
		inc	h
		djnz	bucle_borra_disparo

	;-------------------------------
	; Dibuja disparo
	;-------------------------------
		ld	a,h
		sub	$08
		ld	h,a
		ld	(disparo_y),a	; Actualizamos la nueva coorY (para dibujar)

		call 	check_tercio_anterior
		ld	a,h
		cp	$38
		jr	z, desactivar_disparo	; FIN del disparo (fin 1er tercio)

		ld	b,$08

	bucle_dibuja_disparo:
		ld	(hl),$01
		inc	h
		djnz	bucle_dibuja_disparo
	
		ret

	desactivar_disparo:
		ld	a,(settings)
		res	0,a
		ld	(settings),a
		ret

;---------------------------------------------------------------------------
; 			   Check Tercio Anterior
;---------------------------------------------------------------------------
check_tercio_anterior:
	ld	a,l
	and	%11100000
	jr	z,restar_tercio

	ld	a,l
	sub	$20
	ld	l,a
	ld	(disparo_x),a

	ret		; Retornamos SIN restar tercio (normal)

	restar_tercio:
		ld	a,l
		add	a,$e0		; Sumar para colocarnos en la ultima FILA...
		ld	l,a		; ... del tercio
		ld	(disparo_x),a

		ld	a,h
		sub	$08
		ld	h,a		; Restamos 8 a h, obteniendo 'nuevo' tercio
		ld	(disparo_y),a

		ret		; Retornamos RESTANDO tercio
