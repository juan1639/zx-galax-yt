;===========================================================================
;---                SUB - M E N U   P R I N C I P A L                    ---
;---                                                                     ---
;---  C---> Z Comenzar (Ret)                                             ---
;---  HL--> Puntero VRAM        ...   DE---> Puntero para texto,etc.     ---
;---------------------------------------------------------------------------
menu_principal:
	;call	inicia_estrella

menu_principal2:
	call	espacio		; SUB Scroll espacial estrellas

	call	titulo
	call	velocidad_juego
	call	creditos
	call 	pulse_continuar

	push	bc

	ld	c,$01		; C=1... NO pulsada ... (continua en bucle MP)
	call	teclado_mp	; Leer Teclado para avanzar...
	ld	a,c

	pop	bc
	ret	z		; Retorna si C=0
	
	halt
	jr	menu_principal2		; bucle Menu Principal

ret		; No hace falta

;---------------------------------------------------------------------------
;---                SUB - T E C L A D O   MENU PRINCIPAL                 ---
;---                                                                     ---
;---  			  Space bar --> Comenzar                         ---
;---------------------------------------------------------------------------
teclado_mp:
	ld	a,$7f			; Carg en A, puerto $7f (semifila SPC...B)
	in	a,($fe)			; Lee (In A) el puerto entrada $fe
	bit	0,a			; Comprobamos estado del Bit0 (Tecla Space)
	jr 	nz,tecla_mp2		; NZ = '0' No pulsada, salta a la siguiente...
	jr	comenzar_ajugar

tecla_mp2:
	ld	a,$fe			; Carga en A, puerto $ef (semifila CAPS...V)
	in	a,($fe)			; Lee (In A) el puerto entrada $fe
	bit	4,a			; Comprobamos estado del Bit2 (Tecla V)
	ret 	nz			; NZ = 'V' No pulsada, Retorna ...

cambiar_vel:
	ld	a,$04
	call	sonido

	ld	a,$02
	call	sonido

	ld	a,(elegir_vel)
	dec	a
	ld	(elegir_vel),a

	or	a
	call	z,hacer_loop

	halt
	halt
	halt

	ret

comenzar_ajugar:
	ld	a,$04
	call	sonido
	ld	c,$00			; C=0 ... Pulsada! Salir del Menu Principal

	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt	
ret

;----------------------------------------------------
hacer_loop:
	inc	a
	inc	a
	inc	a
	ld	(elegir_vel),a
ret

;---------------------------------------------------------------------------
;---                      Texto Pulse Continuar...                       ---
;---------------------------------------------------------------------------
pulse_continuar:
	push	de
	push	bc
	
	ld	de,txt_pulse_continuar
	ld	bc,$26

	call	pr_string

	pop	bc
	pop 	de
ret

;---------------------------------------------------------------------------
;---                	       Texto Creditos                            ---
;---------------------------------------------------------------------------
creditos:
	push	de
	push	bc
	
	ld	de,txt_creditos
	ld	bc,$1e

	call	pr_string

	pop	bc
	pop 	de
ret

;---------------------------------------------------------------------------
;---                	       Texto Titulo                              ---
;---------------------------------------------------------------------------
titulo:
	push	de
	push	bc
	
	ld	de,txt_titulo
	ld	bc,$18

	call	pr_string

	pop	bc
	pop 	de
ret

;---------------------------------------------------------------------------
;---                	Texto Velocidad del Juego                        ---
;---------------------------------------------------------------------------
velocidad_juego:
	push	de
	push	bc
	
	ld	de,txt_v
	ld	bc,$0c

	call	pr_string

	ld	de,txt_velocidad
	ld	bc,$1d

	call	pr_string

	;----------------------------------
	ld	a,(elegir_vel)
	cp	$03
	call	z,cambiar_txt_a_vel_normal
	cp	$02
	call	z,cambiar_txt_a_vel_rapido
	cp	$01
	call	z,cambiar_txt_a_vel_turbo

	ld	bc,$11
	call	pr_string
	;---------------------------------

	pop	bc
	pop 	de
ret

;---------------------------------------------------
cambiar_txt_a_vel_normal:
	ld	de,txt_vel_normal
ret

;---------------------------------------------------
cambiar_txt_a_vel_rapido:
	ld	de,txt_vel_rapido
ret

;---------------------------------------------------
cambiar_txt_a_vel_turbo:
	ld	de,txt_vel_turbo
ret

