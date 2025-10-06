org	$8000

;----------------------   C O N S T A N T E S   ---------------------------
NAVE_Y		equ	$50
LIMITE_IZ	equ	$a0
LIMITE_DE	equ	$be

beeper		equ	$03b5	; Rutina del sistema Beeper (hl=nota | de=duracion)
				; Altera registros hl,de,bc,af,ix

border_c	equ 	$5c48	; Variable sistema (Borde)

locate		equ 	$0dd9	; Rutina sistema: (Locate), (B = ycoord, C = xcoord)
pr_string	equ	$203c	; Rutina sistema para imprimir textos
out_num		equ	$1a1b	; Rutina sistema para imprimir numeros (0-9999)

_CR         	equ $0d
_INK        	equ $10
_PAPER      	equ $11
_FLASH      	equ $12
_BRIGHT     	equ $13
_INVERSE    	equ $14
_OVER       	equ $15
_AT        	equ $16
_TAB   		equ $17

;==========================================================================
;---			C O M I E N Z O   P R O G R A M A		---
;---									---
;---      		    CLS + ATRIBUTOS GENERALES                   ---
;--------------------------------------------------------------------------
call	sub_cls
call 	sub_cls_attr
call	sub_attr_generales
call	sub_attr_zonas
call	borde
call	mostrar_marcadores

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
	call	frames_explo_marciano
	call	check_todos_abatidos
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

;===========================================================================
;=====                                                                 =====
;=====                        S U B R U T I N A S                      =====
;=====                                                                 =====
;---------------------------------------------------------------------------
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

;==========================================================================
;---		       SUB -  ESTABLECER COLOR BORDE                    ---
;--------------------------------------------------------------------------
borde:
	ld	a,%00000111	; 00BBB111 (B = borde)
	ld	(border_c), a

	ld	a,$00		; Color del Borde (negro)
	out	($fe),a		; Puerto FE
ret

;==========================================================================
;         	   SUB -  CHECK TODOS ABATIDOS
;--------------------------------------------------------------------------
check_todos_abatidos:
	ld	a,(num_marcianos)
	or	a
	ret	nz

	ld	de,txt_levelup
	ld	bc,$1c
	call	pr_string
	jr	$
ret

;==========================================================================
;---		            SUB -  SHOW SCORES                          ---
;--------------------------------------------------------------------------
mostrar_marcadores:
	ld	de,txt_puntos
	ld	bc,$0e

	call	pr_string

	;--------------------------
	ld	a,(num_puntos)
	ld	b,a

	ld	a,(num_puntos + 1)
	ld	c,a

	call	out_num

	;--------------------------
	ld	de,txt_vidas
	ld	bc,$0d

	call	pr_string

	;--------------------------
	ld	b,$00

	ld	a,(num_vidas)
	ld	c,a

	call	out_num
ret

;=============================================================================
; 			     $24 / 36 Estrellas
;-----------------------------------------------------------------------------
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
defb	0	; Hay uno de mas, para que cuadre al ser b y bc regresivos

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
; Bit 3 ... 0=nivel NO superado		| 1=Nivel SUPERADO

marciano_y	defb	$40	; CoorY del marciano (h de hl)
marciano_x	defb	$40	; CoorX del marciano (l de hl)
rota_marciano	defb	$01	; Rotacion actual del marciano

num_marcianos	defb	$18	; Numero de marcianos 24 (para checkear nivel superado)

explo_marciano_y	defb	$40	; Coor Y de la explosion marciano
explo_marciano_x	defb	$c0	; Coor X de la explosion marcinao
explo_marciano_timer	defb	$00	; Cuenta atras frames explosion marciano

txt_puntos	defb	_PAPER, $00, _INK, $06, _AT, $00, $01, "Puntos:"
txt_vidas	defb	_PAPER, $00, _INK, $06, _AT, $00, $14, "Vidas:"
txt_levelup	defb	_BRIGHT, $01, _FLASH, $01, _PAPER, $00, _INK, $05, _AT, $0c, $08, " L E V E L   U P "

num_puntos:
	defb	$00, $00

num_vidas	defb	$03	; numero de vidas

;------------------------------------------------------------------------------
include "sonido.asm"
include "teclas.asm"
include "jugador.asm"
include "disparo.asm"
include "estrellas.asm"
include "enemigos.asm"
include "utils.asm"
include "sprites.asm"
include "explomarciano.asm"

;------------------------------------------------------------------------------
end	$8000

