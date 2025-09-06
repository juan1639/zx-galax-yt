org	$8000

;----------------------   C O N S T A N T E S   ---------------------------
NAVE_Y	equ	$50

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
;---         Izquierda --------> 'Z' o Cursor JoyStick Izquierda         ---
;---         Derecha ----------> 'X' o Cursor JoyStick Derecha           ---
;---         Disparo ----------> 'Spc' o Cursor JoyStick Arriba          ---
;---------------------------------------------------------------------------
leer_teclado:
	ld	a,$7f
	in	a,($fe)
	bit	3,a
	jr	nz, tecla_m
	
	;-----------------------------------------------------
	; Si llega hasta aqui, hemos pulsado Izquierda
	;-----------------------------------------------------
	ld	a,(nave_x)
	dec	a
	ld	(nave_x),a	
	ret

	tecla_m:
		ld	a,$7f
		in	a,($fe)
		bit	2,a
		ret	nz

		;-----------------------------------------------------
		; Si llega hasta aqui, hemos pulsado Derecha
		;-----------------------------------------------------
		ld	a,(nave_x)
		inc	a
		ld	(nave_x),a
		ret

;===========================================================================
;---                  E S P A C I O   E S T R E L L A S                  ---
;---                                                                     ---
;---     HL: Coordenadas Estrellas  ...  B: Bucle de $24/36 estrellas    ---
;---     DE: Puntero direcciones de Coordenadas de cada estrella         ---
;---------------------------------------------------------------------------
espacio:
	ld	de,estrellas	; Situar DE en direccion 'estrellas'
	ld	b,$24		; Bucle $24 estrellas

bucle_estrellas:
	ld	a,(de)
	ld	h,a
	inc	de
	ld	a,(de)
	ld	l,a
	ld	(hl),$00	; Borrar estrella

	call 	next_scan	; Sub Next-Scan (calculando tb Linea y Tercio)
	call	check_limite	; Sub Scroll (estrella ha terminado su recorrido)

	inc	de
	ld	a,(de)
	ld	(hl),a	; Dibuja estrella (direccion DE contiene cual estrella)

	dec	de
	ld	a,l
	ld	(de),a
	dec	de
	ld	a,h
	ld	(de),a		; Actualiza la nueva HL en direcciones DE

	inc	de
	inc	de
	inc 	de

	djnz 	bucle_estrellas
	ret

;----------------------------------------------------------------
;	Checkea el limite bajo (un hipotetico 4to tercio)
;----------------------------------------------------------------
check_limite:
	ld	a,h
	cp	%01011000	; Hipotetico 4to Tercio?
	ret	nz		; No? retorna y la estrella sigue...

	ld	h,%01000000	; Reinicia H
	res	7,l
	res	6,l
	res	5,l		; 000C CCCC, Reinicia Linea a 0
	ld	a,l
	add	a,$0e		; Cambia la C CCCC tb...
	ld	l,a		
	ret

;---------------------------------------------------------------------------
;---                 SUB - N E X T   S C A N L I N E                     ---
;---                                                                     ---
;---   Entrada: HL --> Salida: HL ( Siguiente Scanline, teniendo en...   ---
;---            ...cuenta el posible cambio de Caracter o Tercio)        ---
;---------------------------------------------------------------------------
next_scan:
inc	h
ld	a,h		; 010T TSSS
and	$07		; 0000 0111
ret	nz		; NZ hemos terminado, ret

ld	a,l		; LLLC CCCC
add	a,$20		; 0010 0000
ld	l,a
ret	c		; Carry=1, entonces cambio de tercio y ret

ld	a,h		; 010T '1'000 
sub	$08		; 010T '1'000
ld	h,a

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
nave_x	defb	$af	; Posicion X de la nave (l de hl)

;------------------------------------------------------------------------------
end	$8000

