;===========================================================================
;---                    SUB - L E E R   T E C L A D O                    ---
;---                                                                     ---  
;---         Izquierda --------> '5' o Cursor JoyStick Izquierda         ---
;---         Derecha ----------> '8' o Cursor JoyStick Derecha           ---
;---         Disparo ----------> 'Spc'                                   ---
;---                                                                     ---
;---    Las teclas 5 y 8 coinciden con los cursores IZ y DE y con ...    ---
;---    ... un Joystick tipo Cursor-Joystick                             ---   
;---------------------------------------------------------------------------
leer_teclado:
	ld	a,(explo_nave_timer)
	or	a
	ret	nz

	ld	a,$7f		; Carg en A, puerto $7f (Semifila SPC...B)
	in	a,($fe)		; Lee (in a) el puerto de entrada $fe
	bit	0,a		; Bit 4 es la tecla 'SPC'
	jr	nz, tecla_iz	; NO pulsada... salta a la siguiente...
	
	jr	inicia_el_disparo
	
	tecla_iz:
	ld	a,$f7		; Carg en A, puerto $f7 (Semifila 1...5)
	in	a,($fe)		; Lee (in a) el puerto de entrada $fe
	bit	4,a		; Bit 4 es la tecla 'Cursor IZ'
	jr	nz, tecla_de	; NO pulsada... salta a la siguiente...
	
	;-----------------------------------------------------
	; Si llega hasta aqui, hemos pulsado Izquierda
	;-----------------------------------------------------
	ld	a,(nave_x)
	cp	LIMITE_IZ
	ret	z
	
	dec	a
	ld	(nave_x),a	
	ret

	tecla_de:
		ld	a,$ef		; Carg en A, puerto $ef (Semifila 0...6)
		in	a,($fe)		; Lee (in a) el puerto de entrada $fe
		bit	2,a		; Bit 2 es la tecla 'Cursor DE'
		ret	nz		; Ya se retorna si NO se pulsado ninguna tecla...

		;-----------------------------------------------------
		; Si llega hasta aqui, hemos pulsado Derecha
		;-----------------------------------------------------
		ld	a,(nave_x)
		cp	LIMITE_DE
		ret	z

		inc	a
		ld	(nave_x),a
		ret

;===========================================================================
;		  I N I C I A   E L   D I S P A R O
;---------------------------------------------------------------------------
inicia_el_disparo:
	ld	a,(settings)
	bit	0,a
	ret	nz

	set	0,a	; Ponemos el Bit0 a 1 (Para NO permitir mas disparos)
	ld	(settings),a

	ld	a,NAVE_Y
	ld	h,a
	ld	(disparo_y),a

	ld	a,(nave_x)
	sub	$20
	ld	l,a
	ld	(disparo_x),a

	ld	b,$08

bucle_disparo_inicial:
	ld	(hl),$01	; 0000 0001
	inc	h
	djnz	bucle_disparo_inicial

	ret

