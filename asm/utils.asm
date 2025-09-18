;================================================
;	Poner Atributos
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
	ld	a,(hl)
	cp	%01000011	; Hay en esta posicion color magenta? (disparo)
	jr	z,$		; De momento detener programa

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
; Check si es attr verde brillante (Marciano)...
; ... o si es attr negro (fondo, no hay marciano)
;-------------------------------------------------
check_si_hay_marciano:
	jr	$


