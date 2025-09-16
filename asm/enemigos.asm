;===========================================================================
;---                   M O V E R   M A R C I A N O S                     ---
;---                                                                     ---
;---------------------------------------------------------------------------
mover_marcianos:
	ld	a,(marciano_y)
	ld	h,a
	ld	a,(marciano_x)
	ld	l,a

	call	gestionar_rotacion

	;---------------------------------------
	ld	b,$18	; Bucle de 24 marcianos

bucle_todos_los_marcianos:
	ld	de,marcianos_sprites

	ld	a,(rota_marciano)
	or	a
	jr	z,rotacion_zero

	push 	bc

	;--------------------------------------
	ld	b,a

	bucle_selecc_rotacion:
		call	sumar_de_24
	djnz	bucle_selecc_rotacion
	
	pop	bc
	
	;------------------------------------------
	; Sabiendo ya la rotacion, podemos dibujar
	;------------------------------------------
	rotacion_zero:
	push	bc

	ld	b,$08	; Bucle de 8 scanlines

	bucle_dibuja_marciano:
		ld	a,(de)
		ld	(hl),a	; 1er byte (izquierda)

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a	; 2do byte

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a	; 3er byte

		dec	l
		dec	l

		inc	h
		inc	de
	djnz	bucle_dibuja_marciano

	ld	a,h
	sub	$08
	ld	h,a

	;---------------------------------
	push	hl
	call	poner_atributos
	pop	hl
	
	;---------------------------------
	inc	l
	inc	l
	inc	l
	inc	l

	pop	bc

	ld	a,b
	cp	$11
	call	z,incrementar_l

	cp	$09
	call	z,decrementar_l
	
djnz 	bucle_todos_los_marcianos
ret

;----------------------------------------------------
; Inc y Dec del registro hl para que la formacion...
; ... de naves quede un poco mas entrelazada
;----------------------------------------------------
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

;-------------------------------------------------
; +24 bytes a DE para cambiar de sprite a dibujar
;-------------------------------------------------
sumar_de_24:
	ld	a,e
	add	a,$18	; Sumar 24 bytes
	ld	e,a
	jr	nc,retornar

	inc	d

retornar:
	ret

;-------------------------------------------------
; 		GESTIONAR ROTACION
;-------------------------------------------------
gestionar_rotacion:
	ld	a,(settings)
	bit	1,a
	jr	nz,hacia_la_izquierda

	;--------------------------------
	; Movimiento hacia la dcha
	;--------------------------------
	ld	a,(rota_marciano)
	cp	$0a
	jr	z,cambio_a_la_izquierda

	inc	a
	ld	(rota_marciano),a
	ret

	;--------------------------------
	; Movimiento hacia la izda
	;--------------------------------
	hacia_la_izquierda:
	ld	a,(rota_marciano)
	cp	$00
	jr	z,cambio_a_la_derecha

	dec	a
	ld	(rota_marciano),a
	ret

;-------------------------------------
cambio_a_la_izquierda:
	ld	a,(settings)
	set	1,a
	ld	(settings),a
	ret

cambio_a_la_derecha:
	ld	a,(settings)
	res	1,a
	ld	(settings),a
	ret


	

	

	
