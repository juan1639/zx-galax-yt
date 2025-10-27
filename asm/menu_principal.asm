;===========================================================================
;---                SUB - M E N U   P R I N C I P A L                    ---
;---                                                                     ---
;---  C---> Z Comenzar (Ret)                                             ---
;---  HL--> Puntero VRAM        ...   DE---> Puntero para texto,etc.     ---
;---------------------------------------------------------------------------
menu_principal:
	;call	inicia_estrella

menu_principal2:
	;call	espacio		; SUB Scroll espacial estrellas
	;call	estrella	; SUB Animacion Estrella
	;call	attr_mp
	;call 	galax_jon
	call 	pulse_continuar
	call	creditos

	ld	c,$01		; C=1... NO pulsada ... (continua en bucle MP)
	call	teclado_mp	; Leer Teclado para avanzar...
	ld	a,c
	ret	z		; Retorna si C=0
	
	halt
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
	bit	0,a			; Comprobamos estado del Bit4 (Tecla 5)
	jr 	nz,tecla_mp2		; NZ = '0' No pulsada, salta a la siguiente...
	jr	comenzar_ajugar

tecla_mp2:
	ld	a,$ef			;Carg en A, puerto $ef (semifila 6...0)
	in	a,($fe)			;Lee (In A) el puerto entrada $fe
	bit	4,a			;Comprobamos estado del Bit4 (Tecla '6')
	jr 	nz,tecla_mp3		;NZ = '6' No pulsada, salta a la siguiente...
	jr	comenzar_ajugar

tecla_mp3:
	ld	a,$ef			;Carg en A, puerto $ef (semifila 6...0)
	in	a,($fe)			;Lee (In A) el puerto entrada $fe
	bit	3,a			;Comprobamos estado del Bit3 (Tecla 7)
	jr 	nz,tecla_mp4		;NZ = '7' No pulsada, salta a la siguiente...
	jr	comenzar_ajugar

tecla_mp4:
	ld	a,$ef			;Carg en A, puerto $ef (semifila 6...0)
	in	a,($fe)			;Lee (In A) el puerto entrada $fe
	bit	2,a			;Comprobamos estado del Bit2 (Tecla 8)
	ret 	nz			;NZ = '8' No pulsada, Retorna ...

comenzar_ajugar:
	ld	a,$04
	call	sonido
	ld	c,$00			; C=0 ... Pulsada! Salir del Menu Principal
	;call	sub_cls
	;call	sub_clsattr
	
ret

;---------------------------------------------------------------------------
;---                		Pulse Continuar...                       ---
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
;---                		     Creditos                            ---
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


