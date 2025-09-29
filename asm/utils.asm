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

;=================================================
; Check si hemos ABATIDO a un MARCIANO...
; ... (leyendo el bit 2 de settings)
;-------------------------------------------------
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




