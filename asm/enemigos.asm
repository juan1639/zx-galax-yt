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
	ld	de,marciano_abatido
	ld	a,e
	add	a,b
	ld	e,a

	call	decrementar_si_carry

	ld	a,(de)
	or	a
	jp	nz,marciano_desactivado	; Marciano desactivado (salta)

	;---------------------------------------
	; Situarse en el sprite correspondiente
	; para comenzar a dibujar, etc.
	;---------------------------------------
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
	push	bc
	call	check_si_marciano_nos_dispara
	pop	bc
	pop	hl

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
	
	;---------------------------------
	; Desactivar marciano
	; (si ha sido abatido)
	;---------------------------------
	ld	a,(settings)
	bit	2,a
	jr	z,salta_no_abatido

	res	2,a
	ld	(settings),a

	call	iniciar_explosion_marciano

	;---------------------------
	;    Sumar puntuacion
	;---------------------------
	call	sumar_puntos

	push	de
	push	bc
	call	mostrar_marcadores
	pop	bc
	pop 	de

	;-----------------------------
	; 'Desactivar' marciano actual
	;-----------------------------
	push	de

	ld	de,marciano_abatido
	ld	a,e
	add	a,b
	ld	e,a

	call	decrementar_si_carry

	ld	a,$01
	ld	(de),a

	pop	de

	;---------------------------
	; Restamos 1 marciano
	;---------------------------
	call	restar_marciano

	salta_no_abatido:
djnz 	bucle_todos_los_marcianos
ret

;----------------------------------------------------
; Inc y Dec del registro hl para que la formacion...
; ... de naves quede un poco mas entrelazada
; 
; ************ AL FINAL NO LA USAMOS ***************
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
; +27 bytes a DE para cambiar de sprite a dibujar
;-------------------------------------------------
sumar_de_24:
	ld	a,e
	add	a,$1b	; Sumar 27 bytes (24 + los 3 de attr)
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

;------------------------------------
decrementar_si_carry:
	ret	nc
	
	dec	d
	ret

;========================================================
; Marciano desactivado (hacer esto antes de saltar...
; ...a la siguiente iteracion del bucle
;--------------------------------------------------------
marciano_desactivado:
	inc	l
	inc	l
	inc	l
	inc	l
	inc	de
	inc	de
	inc	de
	inc	de

	jr	salta_no_abatido
jr	$

;========================================================
; INICIAR Explosion Marciano (asignar las coordenadas...
; ... y la cuenta atras de frames de explosion)
;--------------------------------------------------------
iniciar_explosion_marciano:
	ld	a,h
	ld	(explo_marciano_y),a

	ld	a,l
	dec	a
	dec	a
	dec	a
	dec	a
	ld	(explo_marciano_x),a

	ld	a,$0a			; a0 = 10 frames 
	ld	(explo_marciano_timer),a	; Cuenta atras (10 frames)
	ret
