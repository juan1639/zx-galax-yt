org	$8000

;--------------------------------------------------------------------------
;                         C O N S T A N T E S
;--------------------------------------------------------------------------
NAVE_Y		equ	$50
LIMITE_IZ	equ	$a0
LIMITE_DE	equ	$be

NUMERO_MARCIANOS	equ	$18	; 24 marcianos fijos

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
;---			M E N U   P R I N C I P A L      		---
;---									---
;---      		    CLS + ATRIBUTOS GENERALES                   ---
;--------------------------------------------------------------------------
call	sub_cls
call 	sub_cls_attr
call	sub_attr_zonas
call	borde
call	menu_principal

;==========================================================================
;---			C O M I E N Z O   J U E G O       		---
;---									---
;---      		    CLS + ATRIBUTOS GENERALES                   ---
;--------------------------------------------------------------------------
nuevo_nivel:
ld	a,(settings)
res	3,a		; Resetear el flag nivel superado
res	7,a		; Resetear el flag rejugar nuevo nivel
ld	(settings),a

call	sub_cls
call 	sub_cls_attr
call	sub_attr_generales
call	sub_attr_zonas
;call	borde
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
	call	frames_nave_explosion
	call	disparo_marciano
	call	mover_marcianos
	call	frames_explo_marciano
	call	dibujar_banderita
	call	check_todos_abatidos
	call	check_estado_gameover
	
	ld	a,(settings)
	bit	7,a
	jr	nz, nuevo_nivel	; JP *** SALTO ABSOLUTO ***

	call	ralentizar_juego_halt
	
jr	bucle_principal
jr	$

;===========================================================================
;=====                                                                 =====
;=====                        S U B R U T I N A S                      =====
;=====                                                                 =====
;---------------------------------------------------------------------------
;===========================================================================
;		A mas cantidad de halts... mas lento
;---------------------------------------------------------------------------
ralentizar_juego_halt:
	ld	a,(elegir_vel)
	;halt
	dec	a
	ret	z

	halt
	dec	a
	ret	z

	halt
	dec	a
	ret	z
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
	ld	a,(settings)
	bit	3,a
	ret	z

	;-----------------------
	ld	de,txt_levelup
	ld	bc,$1c
	call	pr_string

	ld	de,txt_pulse_c
	ld	bc,$25
	call	pr_string

	ld	a,$fe		; Carg en A, puerto $fd (Semifila CAPS...V)
	in	a,($fe)		; Lee (in a) el puerto de entrada $fe
	bit	3,a		; Bit 4 es la tecla 'C'
	call	z,resetar_valores_nuevo_nivel
	;jr	$
ret

;==========================================================================
;---		            SUB -  SHOW SCORES                          ---
;--------------------------------------------------------------------------
mostrar_marcadores:
	ld	de,txt_puntos
	ld	bc,$12

	call	pr_string

	;--------------------------
	ld	a,(num_puntos)
	ld	b,a

	ld	a,(num_puntos + 1)
	ld	c,a

	call	out_num

	;--------------------------
	ld	de,txt_vidas
	ld	bc,$11

	call	pr_string

	;--------------------------
	ld	b,$00

	ld	a,(num_vidas)
	cp	$ff
	call	z,vidas_top_zero

	ld	c,a

	call	out_num
ret

;----------------------------------
vidas_top_zero:
	xor	a
ret

;=============================================================================
;---		           CHECK si GAME OVER (Vidas 0)                    ---
;-----------------------------------------------------------------------------
check_estado_gameover:
	ld	a,(settings)
	bit	4,a
	ret	z

	;-------------------------
	ld	de,txt_gameover
	ld	bc,$18

	call	pr_string

	;-------------------------
	ld	de,txt_rejugar
	ld	bc,$1d

	call	pr_string

	;-------------------------
	; Otra Partida?
	;-------------------------
	ld	a,$fd		; Carg en A, puerto $fd (Semifila A...G)
	in	a,($fe)		; Lee (in a) el puerto de entrada $fe
	bit	1,a		; Bit 4 es la tecla 'S'
	jr	z,$
	;call	z,resetar_valores_nuevapartida
ret

;-----------------------------------------------------------
resetar_valores_nuevo_nivel:
	ld	de,marciano_abatido

	ld	a,$18
	ld	(num_marcianos),a
	ld	a,(num_marcianos)

	ld	b,$18

	bucle_reset_marcianos_abatidos:
		ld	a,$00		; Ponemos a 0 todos los marcianos...
		ld	(de),a		; ...(para que se dibujen otra vez)
		inc	de
	djnz	bucle_reset_marcianos_abatidos

	ld	(de),a

	;-------------------------------------
	ld	a,(nivel)
	inc	a
	ld	(nivel),a

	ld	a,(settings)
	set	7,a		; Reseteo al nuevo nivel
	ld	(settings),a
ret

;=============================================================================
;---									   ---
;---		    V A R I A B L E S  en  M E M O R I A                   ---
;---									   ---
;-----------------------------------------------------------------------------
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

;-----------------------------------------------------------------------------
; NAVE_Y esta declarada como constante (porque solo se mueve en horizontal)
nave_x		defb	$af	; Posicion X de la nave (l de hl)

explo_nave_x	defb	$00	; Posicion X de la explo nave (y es constante)
explo_nave_timer	defb	$00	; Cuenta atras explosion nuestra nave

;-----------------------------------------------------------------------------
disparo_y	defb	$50	; Posicion Y del disparo (h de hl)
disparo_x	defb	$8f	; Posicion X del disparo (l de hl)

;-----------------------------------------------------------------------------
settings	defb	%00000000	; Bits (flags) de los diferentes estados. Bits utilizados:

; Bit 0 ... 0=Disparo permitido		| 1=Disparo NO permitido (0000 0001)
; Bit 1 ... 0=Enemigos a la dcha.	| 1=Enemigos a la izda. 
; Bit 2 ... 0=marciano abatido OFF	| 1=Marciano abatido ON
; Bit 3 ... 0=Nivel NO superado		| 1=Nivel SUPERADO
; Bit 4 ... 0=Game Over OFF		| 1=Game Over ON
; Bit 5 ... 0=Marciano atacando OFF	| 1=Marciano atacando ON
; Bit 6 ... 0=Rejugar OFF		| 1=Rejugar ON
; Bit 7 ... 0=Reset Nuevo Nivel OFF	| 1=Reset Nuevo Nivel ON

;----------------------------------------------------------------------------
; 	1 = Turbo
; 	2 = Rapido
; 	3 = Normal
;----------------------------------------------------------------------------
elegir_vel	defb	$03	; Velocidad del juego (default 3 normal)

;----------------------------------------------------------------------------
marciano_y	defb	$40	; CoorY del marciano (h de hl)
marciano_x	defb	$40	; CoorX del marciano (l de hl)
rota_marciano	defb	$01	; Rotacion actual del marciano

explo_marciano_y	defb	$40	; Coor Y de la explosion marciano
explo_marciano_x	defb	$c0	; Coor X de la explosion marcinao
explo_marciano_timer	defb	$00	; Cuenta atras frames explosion marciano

disparo_marciano_y	defb	$40	; Posicion Y del disparo marciano
disparo_marciano_x	defb	$00	; Posicion X del disparo marciano

;------------------ Marciano/s abatido/s (24 Marcianos) ----------------------
marciano_abatido:
defb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
defb	0	; Hay uno de mas, para que cuadre al ser b y bc regresivos

num_marcianos	defb	NUMERO_MARCIANOS	; Num de marcianos 24 (pa checkear nivel superado)

;-----------------------------------------------------------------------------
txt_puntos	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $00, $01, "Puntos:"
txt_vidas	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $00, $14, "Vidas:"
txt_levelup	defb	_BRIGHT, $01, _FLASH, $01, _PAPER, $00, _INK, $05, _AT, $0c, $08, " L E V E L   U P "

txt_pulse_continuar	defb	_BRIGHT, $01, _FLASH, $01, _PAPER, $00, _INK, $05, _AT, $11, $03, " Pulse Space para comenzar "
txt_creditos	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $02, _AT, $15, $08, $7f," Juan Eguia, 2025 "

txt_titulo	defb 	_BRIGHT, $00, _FLASH, $00, _PAPER, $06, _INK, $01, _AT, $02, $0b, " Galax Jon "
txt_v		defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $08, $07, "V"
txt_velocidad	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $07, _AT, $08, $08, "elocidad del juego"
txt_vel_normal	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $0a, $0d, "Normal"
txt_vel_rapido	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $0a, $0d, "Rapido"
txt_vel_turbo	defb	_BRIGHT, $00, _FLASH, $00, _PAPER, $00, _INK, $06, _AT, $0a, $0d, "Turbo "

txt_gameover	defb	_BRIGHT, $01, _FLASH, $01, _PAPER, $00, _INK, $02, _AT, $0c, $0b, " Game Over "		
txt_rejugar	defb	_BRIGHT, $01, _FLASH, $00, _PAPER, $00, _INK, $07, _AT, $0f, $07, " Otra partida? S/N "
txt_pulse_c	defb	_BRIGHT, $01, _FLASH, $00, _PAPER, $00, _INK, $07, _AT, $0f, $04, " Pulse C para nuevo nivel "

num_puntos:
	defb	$00, $00

num_vidas	defb	$03	; numero de vidas
nivel		defb	$01	; nivel (banderita)

;==============================================================================
include "sonido.asm"
include "teclas.asm"
include "jugador.asm"
include "disparo.asm"
include "estrellas.asm"
include "enemigos.asm"
include "utils.asm"
include "sprites.asm"
include "explomarciano.asm"
include "menu_principal.asm"
include "banderita.asm"

;------------------------------------------------------------------------------
end	$8000

