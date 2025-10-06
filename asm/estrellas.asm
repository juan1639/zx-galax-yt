;===========================================================================
;---                  E S P A C I O   E S T R E L L A S                  ---
;---                                                                     ---
;---     HL: Coordenadas Estrellas  ...  B: Bucle de $24/36 estrellas    ---
;---     DE: Puntero direcciones de Coordenadas de cada estrella         ---
;---------------------------------------------------------------------------
espacio:
	ld	de,estrellas	; Situar DE en direccion 'estrellas'
	ld	b,$24		; Bucle de 36 estrellas ($24)

bucle_estrellas:
	ld	a,(de)
	ld	h,a
	inc	de
	ld	a,(de)
	ld	l,a
	ld	(hl),$00	; Borrar estrella

	call	next_scan
	call	check_limite

	inc	de
	ld	a,(de)
	ld	(hl),a		; Dibujar estrella en nueva posicion (+1 scan abajo)

	dec	de
	ld	a,l
	ld	(de),a

	dec	de
	ld	a,h
	ld	(de),a		; Actualizar la nueva PosXY en hl

	inc	de
	inc	de
	inc 	de

	djnz	bucle_estrellas
	ret

;---------------------------------------------------------------------------
;---                 SUB - N E X T   S C A N L I N E                     ---
;---                                                                     ---
;---   Entrada: HL --> Salida: HL ( Siguiente Scanline, teniendo en...   ---
;---            ...cuenta el posible cambio de Caracter o Tercio)        ---
;---------------------------------------------------------------------------
next_scan:
	inc	h		; Incrementamos h (scanline)

	ld	a,h	; 010T TSSS FFFC CCCC | (hl) | $4000 | 01000000 00000000

	and	%00000111	; check si hemos alcanzado el supuesto scan 8
	ret	nz		; Si es antes del scanline 7, hemos terminado...

	;------------   Checkear tercio   -------------
	ld	a,l		; FFFC CCCC
	add	a,$20		; 0010 0000
	ld	l,a
	ret	c		; Carry=1 ... entonces cambio de Tercio y ret

	;------------   Siguiente Fila    -------------
	ld	a,h	; 0100 1000 restamos 0000 1000 = 0100 0000
	sub	$08
	ld	h,a
	ret

;----------------------------------------------------------------
;	Checkea el limite bajo (un hipotetico 4to tercio)
;----------------------------------------------------------------
check_limite:
	ld	a,h
	;cp	%01011000	; Check hipotetico 4to Tercio
	and	%00011000
	cp	%00011000
	ret	nz

	ld	h,%01000000	; Carga en h $4000
	res	7,l
	res	6,l
	set	5,l		; l = FFFC CCCC
	ld	a,l
	add	a,$0e
	ld	l,a
	ret
