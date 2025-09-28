;================================================
;	Poner Atributos (Marcianos)
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
	; 1er Byte marciano
	;---------------------------------
	call	check_colision_en_celda
	
	ld	a,(de)
	ld	(hl),a

	; --------------------------------
	; 2do Byte marciano
	;---------------------------------
	inc	l
	inc	de

	call	check_colision_en_celda
	
	ld	a,(de)
	ld	(hl),a

	; --------------------------------
	; 3er Byte marciano
	;---------------------------------
	inc	l
	inc	de

	call	check_colision_en_celda

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

;===================================================
; Check si coinciden en una delda, magenta (disparo)
; ... y verde brillante (marciano)
;---------------------------------------------------
check_colision_en_celda:
	ld  a,(hl)
    	cp  %01000011     ; ¿magenta en pantalla?
    	ret nz

    	ld  a,(de)
    	cp  %01000100     ; ¿sprite = marciano verde?
    	ret nz
	
	;-----------------------
    	; 	Colisión
	;-----------------------
	ld	a,(settings)
	set	2,a
	ld	(settings),a
    	ret

;=================================================
; Check si hemos ABATIDO a un MARCIANO...
; ... (leyendo el bit 2 de settings)
;-------------------------------------------------
check_abatido_marciano:
	ld	a,(settings)
	bit	2,a
	ret	z

	ld	a,%01010101
	ld	hl,$4800
	ld	(hl),a
	jr	$
