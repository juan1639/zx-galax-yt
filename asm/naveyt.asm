org	$8000

;----------------------   C O N S T A N T E S   ---------------------------
NAVE_Y		equ	$50
LIMITE_IZ	equ	$a0
LIMITE_DE	equ	$be

;==========================================================================
;---			C O M I E N Z O   P R O G R A M A		---
;---									---
;---      		    CLS + ATRIBUTOS GENERALES                   ---
;--------------------------------------------------------------------------
call	sub_cls
call 	sub_cls_attr
call	sub_attr_generales
call	sub_attr_zonas

;==========================================================================
;---                                                                    ---
;---	               B U C L E    P R I N C I P A L                   ---
;---                                                                    ---
;==========================================================================
bucle_principal:
	call	espacio
	call	disparo
	call	leer_teclado
	call 	dibuja_nave
	halt
	halt			; A mas cantidad de halts... mas lento
	
jr	bucle_principal
jr	$

;==========================================================================
;=====                                                                =====
;=====                        S U B R U T I N A S                     =====
;=====                                                                =====
;==========================================================================
;---		             SUB - DIBUJA NAVE                          ---
;---                                                                    ---
;---  HL---> Coordenadas Jugador        ...  B---> Bucle Scanlines      ---
;---  DE---> Puntero direcciones Sprite ...  				---
;==========================================================================
dibuja_nave:
	ld	a,NAVE_Y
	ld	h,a
	ld	a,(nave_x)
	ld	l,a

	ld	de,sprites

	ld	b,$10

	bucle_dibuja_nave:
		dec	l

		ld	a,0
		ld	(hl),a

		inc	l

		ld	a,(de)
		ld	(hl),a

		inc	l
		inc	de

		ld	a,(de)
		ld	(hl),a

		inc	l

		ld	a,0
		ld	(hl),a

		dec	l
		dec	l

		call	check_next_fila

		inc	de
	
		djnz	bucle_dibuja_nave
		ret

check_next_fila:
	ld	a,h
	and	%00000111
	cp	%00000111 ; $07 decimal 7
	jr	nz, next_scanline

	ld	a,h
	xor	%00000111
	ld	h,a

	ld	a,l
	add	a,$20
	ld	l,a
	ret

	next_scanline:
	inc	h	
	ret

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
	res	5,l		; l = FFFC CCCC
	ld	a,l
	add	a,$0e
	ld	l,a
	ret

;===========================================================================
;---                    S U B - ATRIBUTOS POR ZONAS                      ---
;---------------------------------------------------------------------------
sub_attr_zonas:
	ld	a,%01000110
	ld	hl,$5880
	ld	(hl),a
	ld	de,$5881
	ld	bc,$7f
	ldir

	ld	a,%01000101
	ld	hl,$5900
	ld	(hl),a
	ld	de,$5901
	ld	bc,$7f
	ldir

	ld	a,%01000010
	ld	hl,$5980
	ld	(hl),a
	ld	de,$5981
	ld	bc,$7f
	ldir
ret

;===========================================================================
;---                    S U B - ATRIBUTOS GENERALES                      ---
;---------------------------------------------------------------------------
sub_attr_generales:
	ld	hl,$5aa0
	ld	b,$20

bucle_attr_generales:
	ld	a,%00000010
	ld	(hl),a

	ld	a,l
	add	a,$20
	ld	l,a

	ld	a,%00000101
	ld	(hl),a

	ld	a,l
	sub	$20
	ld	l,a

	inc	l
	djnz	bucle_attr_generales
	ret

;===========================================================================
;---                    S U B - C L S  ATRIBUTOS                         ---
;---------------------------------------------------------------------------
sub_cls_attr:

; flash 0 ----- bit 7
; bright 0 ---- bit 6
; paper 1  ---- bits 5,4,3
; ink 7 ------- bits 2,1,0

	ld	a,%01000111
	ld	hl,$5800
	ld	(hl),a
	ld	de,$5801
	ld	bc,$02ff
	ldir
ret

;==========================================================================
;---		               SUB -  C L S                             ---
;--------------------------------------------------------------------------
sub_cls:
	ld	a,$00
	ld	hl,$4000
	ld	(hl),a
	ld	de,$4001
	ld	bc,$17ff
	ldir
ret

;=============================================================================
;---                                                                       ---
;---                           S P R I T E S                               ---
;---                                                                       ---
;-----------------------------------------------------------------------------
sprites:
DEFB	  1,128,  3,192,  7,224, 15,240
DEFB	 15,240,  9,144, 73,146, 65,130
DEFB	229,167,237,183,253,191,252, 63
DEFB	246,111,230,103,224,  7, 64,  2

;--------------------- $24 / 36 Estrellas ------------------------------------
estrellas:						
defb	$42,$4f,2,$47,$67,8,$4a,$83,64,$55,$10,32,$50,$14,32,$4f,$28,1
defb	$56,$05,4,$40,$a0,32,$44,$3b,64,$46,$39,32,$49,$ed,16,$4d,$eb,32
defb	$46,$c2,16,$53,$11,16,$40,$67,8,$43,$98,4,$46,$0f,2,$54,$47,36
defb	$4b,$09,16,$4f,$0c,32,$41,$e4,64,$45,$28,32,$50,$04,8,$4e,$6d,4
defb	$49,$32,32,$44,$88,64,$43,$c6,16,$53,$11,8,$4a,$29,64,$4b,$06,16
defb	$4e,$87,128,$47,$68,16,$45,$72,32,$42,$91,64,$55,$0b,8,$57,$2c,32

;-----------------------------------------------------------------------------
;---		    V A R I A B L E S  en  M E M O R I A                   ---
;-----------------------------------------------------------------------------
nave_x		defb	$af	; Posicion X de la nave (l de hl)
; NAVE_Y esta declarada como constante (porque solo se mueve en horizontal)

disparo_x	defb	$8f	; Posicion X del disparo (l de hl)
disparo_y	defb	$50	; Posicion Y del disparo (h de hl)

settings	defb	$00	; Bits (flags) de los diferentes estados. Bits utilizados:

; Bit 0 ... 0=Disparo permitido		| 1=Disparo NO permitido (0110 1001)
; Bit 1

;------------------------------------------------------------------------------
end	$8000

