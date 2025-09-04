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

;==========================================================================
;---                                                                    ---
;---	               B U C L E    P R I N C I P A L                   ---
;---                                                                    ---
;==========================================================================
bucle_principal:
	call	leer_teclado
	call 	dibuja_nave
	halt
	halt
	
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
; ink 6 ------- bits 2,1,0

	ld	a,%00000100
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

;-----------------------------------------------------------------------------
;---		    V A R I A B L E S  en  M E M O R I A                   ---
;-----------------------------------------------------------------------------
nave_x	defb	$af	; Posicion X de la nave (l de hl)

;------------------------------------------------------------------------------
end	$8000

