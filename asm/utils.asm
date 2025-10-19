;================================================
;	Poner Atributos (SOLO PARA MARCIANOS)
;------------------------------------------------
poner_atributos:
	ld	a,h

	cp	$40
	jr	z,attr_58

	cp	$48
	jr	z,attr_59

	jr	attr_5a
	jr	$

attr_58:
	ld	h,$58
	jr	terminar_y_poner_attr

attr_59:
	ld	h,$59
	jr	terminar_y_poner_attr

attr_5a:
	ld	h,$5a

terminar_y_poner_attr:
	; --------------------------------
	; 1er caracter marciano
	;---------------------------------
	call	check_colision_en_celda
	
	ld	a,(de)
	ld	(hl),a

	; --------------------------------
	; 2do caracter marciano
	;---------------------------------
	inc	l
	inc	de

	call	check_colision_en_celda

	ld	a,(de)
	ld	(hl),a

	; --------------------------------
	; 3er caracter marciano
	;---------------------------------
	inc	l
	inc	de

	call check_colision_en_celda

	ld	a,(de)
	ld	(hl),a

	ret

;================================================
;	Leer Atributos
;------------------------------------------------
leer_atributos:
	ld	a,h

	cp	$40
	jr	z,leer_attr_58

	cp	$48
	jr	z,leer_attr_59

	jr	leer_attr_5a
	jr	$

leer_attr_58:
	ld	h,$58
	ret

leer_attr_59:
	ld	h,$59
	ret

leer_attr_5a:
	ld	h,$5a
	ret

jr	$

;=================================================
; Check colision entre disparo y marciano
;
;-------------------------------------------------
check_colision_en_celda:
	ld	a,(hl)
	cp	%01000011	; (67) hay un attr magenta brillante? (disparo)
	ret	nz

	ld	a,(de)
	cp	%01000100	; (68) hay un attr verde brillante? (marciano)
	ret	nz

	;----------------------------
	; Llegados aqui, hay colision
	;----------------------------
	ld	a,(settings)
	set	2,a

	;--------------------------------------
	; Aprovechamos tb para desactivar...
	; ...el disparo (para que no atraviese)
	;--------------------------------------
	res	0,a
	ld	(settings),a
	ret

;==================================================
; 	      S U M A R   P U N T O S
;--------------------------------------------------
sumar_puntos:
	ld	a,(num_puntos + 1)
	add	a,$0a			; 10 puntos (sumar)
	ld	(num_puntos + 1),a

	jr	c,sumar_puntos_carry
ret

sumar_puntos_carry:
	ld	a,(num_puntos)
	inc	a
	ld	(num_puntos),a
ret

;==================================================
;      RESTAR MARCIANO (A num_marcianos)
;--------------------------------------------------
restar_marciano:
	ld	a,(num_marcianos)
	dec	a
	ld	(num_marcianos),a
ret

;==================================================
; 
; 	DISPARO MARCIANO (DISPARO CAYENDO)
;
;--------------------------------------------------
disparo_marciano:
	ld	a,(settings)
	bit	5,a
	ret	z

	;-------------------------------
	; Borra disparo marciano
	;-------------------------------
		ld	a,(disparo_marciano_y)	; Borrar CoorY (vieja)
		ld	h,a
		ld	a,(disparo_marciano_x)	; Borrar CoorX (vieja)
		ld	l,a

		;------------- Sonido disparo marciano ----------
		;ld	a,$02
		;call	sonido

		;------------------------------------------------
		ld	b,$08

		bucle_borra_disparo_marciano:
			ld	(hl),$00
			inc	h
		djnz	bucle_borra_disparo_marciano

		;-------------------------------
		; Dibuja disparo marciano
		;-------------------------------
		ld	a,h
		sub	$08
		ld	h,a
		ld	(disparo_marciano_y),a	; Actualizamos la nueva coorY (para dibujar)

		call 	check_tercio_siguiente
		ld	a,h
		cp	$58
		jr	z, desactivar_disparo_marciano	; FIN del disparo marciano (fin 3er tercio)

		;-----------------------------------------------------------------------
		; Al final la deteccion de colision la haremos al reves, en la...
		; ... rutina de los enemigos (para poder identificar al enemigo abatido)
		;-----------------------------------------------------------------------
		;push	hl
		;call	check_impacto_marciano
		;pop	hl
		;-----------------------------------------------------------------------

		;--------------------------------------
		ld	b,$08

		bucle_dibuja_disparo_marciano:
			ld	(hl),$03
			inc	h
		djnz	bucle_dibuja_disparo_marciano

		ld	a,h
		sub	$08
		ld	h,a
		
		ret

desactivar_disparo_marciano:
	ld	a,(settings)
	res	5,a
	ld	(settings),a
ret

;---------------------------------------------------------------------------
; 			   Check Tercio Siguiente
;---------------------------------------------------------------------------
check_tercio_siguiente:
	ld	a,l
	and	%11100000
	cp	%11100000	; es la 7ma fila del byte??

	jr	z,sumar_tercio

	ld	a,l
	add	a,$20
	ld	l,a
	ld	(disparo_marciano_x),a

	ret		; Retornamos SIN sumar tercio (normal)

	sumar_tercio:
		ld	a,l
		add	a,$20
		ld	l,a
		ld	(disparo_marciano_x),a

		ld	a,h
		add	a,$08
		ld	h,a		; Sumamos 8 a h, obteniendo 'nuevo' tercio
		ld	(disparo_marciano_y),a

		ret		; Retornamos SUMANDO tercio

;==================================================
; 
;      CHECK SI MARCIANO NOS DISPARA (2)...
; 
;--------------------------------------------------
check_si_marciano_nos_dispara:
	ld	a,(settings)
	bit	5,a		; Hay un disparo marciano activo??
	ret	nz		; ... si lo hay retorna

	push	bc
	call	get_char_coord_lr

	ld	a,(nave_x)
	and 	%00011111
	cp	c

	pop	bc

	ret	nz	; Retorna SI no estamos debajo
	
	;------------------------------------
	; Si estamos justo debajo NOS DISPARA
	;------------------------------------
	ld	a,(settings)
	set	5,a
	ld	(settings),a

	ld	a,h
	ld	(disparo_marciano_y),a

	ld	a,l
	inc	a
	ld	(disparo_marciano_x),a

	;------------------------------------
	ld	b,$08

	bucle_disparo_marciano_inicial:
		ld	(hl),$03	; 0000 0011
		inc	h
	djnz	bucle_disparo_marciano_inicial
ret

;========================================================
; (RUTINA obtenida DE COMPILER SOFTWARE)
; 
; Get_Char_Coordinates_LR(offset)
; Obtener las coordenadas (c,f) que corresponden a una
; direccion de memoria de imagen en baja resolucion.
;
; Entrada:   HL = Direccion de memoria del caracter (c,f)
; Salida:    BC --> B = FILA, C = COLUMNA
;--------------------------------------------------------
get_char_coord_lr:
	;--------------------------------------------
	; HL = 010TT000 FFFCCCCC
	; --> Fila = 000TTFFF y Columna = 000CCCCC
	;--------------------------------------------
	ld a, h                  ; A = H, para extraer los bits de tercio
	and %00011000		 ; A = 000TT000
	ld b, a                  ; B = A = 000TT000

	ld a, l                  ; A = L, para extraer los bits de F (FT)
	and %11100000          	 ; A = A and 11100000 = FFF00000
	rlc a                    ; Rotamos A 3 veces a la izquierda
	rlc a
	rlc a                    ; A = 00000FFF
	or b                     ; A = A or b = 000TTFFF  00000001
	ld b, a                  ; B = A = 000TTFFF
	
	; ------------ Calculo de la columna --------
	ld a, l                  ; A = L, para extraer los bits de columna
	and %00011111            ; Nos quedamos con los ultimos 5 bits de L
	ld c, a                  ; C = Columna
	ret             ; HL = 010TT000 FFFCCCCC

;==================================================
; *** E S T A   R U T I N A   N O   S E   U S A **
; Check si hemos ABATIDO a un MARCIANO...
; ... (leyendo el bit 2 de settings)
;--------------------------------------------------
check_abatido_marciano:
	ret
	ld	a,(settings)
	res	2,a
	ld	(settings),a
	ret

	ret

	ld	a,%01010101
	ld	hl,$4800
	ld	(hl),a
	jr	$




