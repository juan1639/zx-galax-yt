org	$8000

;----------------------   C O N S T A N T E S   ---------------------------
NAVE_Y		equ	$50
LIMITE_IZ	equ	$a0
LIMITE_DE	equ	$be

beeper		equ	$03b5	; Rutina del sistema Beeper (hl=nota | de=duracion)
				; Altera registros hl,de,bc,af,ix

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
	call	mover_marcianos
	call	check_abatido_marciano
	;halt
	;halt
	;halt
	;halt
	;halt
	;halt
	;halt
	;halt
	halt
	halt			; A mas cantidad de halts... mas lento
	
jr	bucle_principal
jr	$

;==========================================================================
;=====                                                                =====
;=====                        S U B R U T I N A S                     =====
;=====                                                                =====
;--------------------------------------------------------------------------
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
;	Nave Jugador
;-----------------------------------------------
sprites:
	DEFB	  1,128,  3,192,  7,224, 15,240
	DEFB	 15,240,  9,144, 73,146, 65,130
	DEFB	229,167,237,183,253,191,252, 63
	DEFB	246,111,230,103,224,  7, 64,  2

marcianos_sprites:
	DEFB	  4, 32,  0,  4, 32,  0, 15,240
	DEFB	  0, 61,188,  0, 63,252,  0, 31
	DEFB	248,  0, 12, 48,  0,  6, 96,  0
	DEFB	 68, 68,  64

	DEFB	  2, 16,  0,  2, 16,  0,  7,248
	DEFB	  0, 30,222,  0, 31,254,  0, 15
	DEFB	252,  0,  6, 24,  0,  3, 48,  0
	DEFB     68, 68,  64

	DEFB	  1,  8,  0,  1,  8,  0,  3,252
	DEFB	  0, 15,111,  0, 15,255,  0,  7
	DEFB	254,  0,  3, 12,  0,  1,  8,  0
	DEFB	 68, 68, 64

	DEFB	  0,132,  0,  0,132,  0,  1,254
	DEFB	  0,  7,183,128,  7,255,128,  3
	DEFB	255,  0,  1,134,  0,  0,132,  0
	DEFB	  68, 68, 68

	DEFB	  0,129,  0,  0, 66,  0,  0,255
	DEFB	  0,  3,219,192,  3,255,192,  1
	DEFB	231,128,  0, 66,  0,  0, 66,  0
	DEFB     68, 68, 68

	DEFB	  0, 64,128,  0, 33,  0,  0,127
	DEFB	128,  1,237,224,  1,255,224,  0
	DEFB	243,192,  0, 33,  0,  0, 64,128
	DEFB	 68, 68, 68

	DEFB	  0, 32, 64,  0, 16,128,  0, 63
	DEFB	192,  0,246,240,  0,255,240,  0
	DEFB	121,224,  0, 16,128,  0, 32, 64
	DEFB     64, 68, 68

	DEFB	  0,  8, 64,  0,  8, 64,  0, 31
	DEFB	224,  0,123,120,  0,127,248,  0
	DEFB	 60,240,  0,  8, 64,  0,  8, 64
	DEFB     64, 68, 68

	DEFB	  0,  4, 32,  0,  4, 32,  0, 15
	DEFB	240,  0, 61,188,  0, 63,252,  0
	DEFB	 30,120,  0,  4, 32,  0,  4, 32
	DEFB	  64, 68, 68

	DEFB	  0,  2, 16,  0,  2, 16,  0,  7
	DEFB	248,  0, 30,222,  0, 31,254,  0
	DEFB	 15,252,  0,  6, 24,  0,  2, 16
	DEFB   64, 68, 68

	DEFB	  0,  1,  8,  0,  1,  8,  0,  3
	DEFB	252,  0, 15,111,  0, 15,255,  0
	DEFB	  7,254,  0,  3, 12,  0,  1,  8
	DEFB     64, 68, 68

;--------------------- $24 / 36 Estrellas ------------------------------------
estrellas:						
defb	$42,$4f,2,$47,$67,8,$4a,$83,64,$55,$10,32,$50,$14,32,$4f,$28,1
defb	$56,$05,4,$40,$a0,32,$44,$3b,64,$46,$39,32,$49,$ed,16,$4d,$eb,32
defb	$46,$c2,16,$53,$11,16,$40,$67,8,$43,$98,4,$46,$0f,2,$54,$47,36
defb	$4b,$09,16,$4f,$0c,32,$41,$e4,64,$45,$28,32,$50,$04,8,$4e,$6d,4
defb	$49,$32,32,$44,$88,64,$43,$c6,16,$53,$11,8,$4a,$29,64,$4b,$06,16
defb	$4e,$87,128,$47,$68,16,$45,$72,32,$42,$91,64,$55,$0b,8,$57,$2c,32

;------------------ Marciano/s abatido/s (24 Marcianos) ----------------------
marciano_abatido:
defb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;-----------------------------------------------------------------------------
;---		    V A R I A B L E S  en  M E M O R I A                   ---
;-----------------------------------------------------------------------------
; NAVE_Y esta declarada como constante (porque solo se mueve en horizontal)
nave_x		defb	$af	; Posicion X de la nave (l de hl)

disparo_y	defb	$50	; Posicion Y del disparo (h de hl)
disparo_x	defb	$8f	; Posicion X del disparo (l de hl)

settings	defb	$00	; Bits (flags) de los diferentes estados. Bits utilizados:

; Bit 0 ... 0=Disparo permitido		| 1=Disparo NO permitido (0000 0001)
; Bit 1 ... 0=Enemigos a la dcha.	| 1=Enemigos a la izda. 
; Bit 2 ... 0=marciano abatido OFF	| 1=Marciano abatido ON

marciano_y	defb	$40	; CoorY del marciano (h de hl)
marciano_x	defb	$20	; CoorX del marciano (l de hl)
rota_marciano	defb	$01	; Rotacion actual del marciano

include "sonido.asm"
include "teclas.asm"
include "jugador.asm"
include "disparo.asm"
include "estrellas.asm"
include "enemigos.asm"
include "utils.asm"

;------------------------------------------------------------------------------
end	$8000

