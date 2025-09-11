;================================================================
;		     S U B  -  S O N I D O S
;
;             Salvarguardar en la pila los registros:
;			  de,hl,af,bc,ix                                                             
;----------------------------------------------------------------
sonido:
	push	de		; Salvaguardar DE,HL
	push	hl

	dec	a
	jr	z,sonido_disparo

	dec	a
	jr	z,sonido_enemigos

	dec	a
	jr	z,sonido_vidamenos

	dec	a
	jr	z,sonido_pulsamenus

	jr	$

sonido_disparo:
	ld	l,$0e			; Valor fijo en l
	ld	a,(disparo_y)		; Para que 'varíe' en funcion del tercio
	sub	$40			; Restar mucho (para que sea agudo)
	ld	h,a			; Cargarlo en h
	ld	de,$0001		; Duracion muy corta
	;ld	de,$0105/$10/$10	; Carga en DE la duracion
	jr	emitir_sonido		; Salta a emitir el sonido

sonido_enemigos:
	ld	hl,$0326		; Carga en Hl la nota
	ld	de,$0001	
	;ld	de,$020b/$10/$10	; Carga en DE la duracion
	jr	emitir_sonido		; Salta a emitir el sonido

sonido_vidamenos:
	ld	hl,$0407		; Carga en HL la nota
	ld	de,$0082/$10/$10	; Carga en DE la duracion
	jr	emitir_sonido		; Salta emitir sonido

sonido_pulsamenus:
	ld	hl,$0d0f		; Carga en HL la nota
	ld	de,$04			; Carga en DE la duracion
	jr	emitir_sonido		; Salta a emitir sonido

	jr	$

;----------------------------------------------------
emitir_sonido:
	push	af		; Salvaguardar AF,BC,IX...
	push	bc
	push	ix
	call	beeper		; SUB rutina sistema SONIDOS
	pop	ix
	pop	bc
	pop	af

	pop	hl
	pop	de		; Recupera AF,BC,IX,HL,DE

	ret

;=====================================================
;		   NOTAS MUSICALES
;
;          (algunos ejemplos como referencia)
;
;-----------------------------------------------------
;                   Medio graves
;-----------------------------------------------------
; DO4   equ $0D0F
; RE4   equ $0BEE
; MI4   equ $0ADE
; FA4   equ $0A2E
; SOL4  equ $094A
; LA4   equ $087B
; SI4   equ $07C0
; DO5   equ $0758

; ------------ Octava 5 (muy agudas) -----------------
; NOTA_C5  equ $0780
; NOTA_CS5 equ $070E
; NOTA_D5  equ $0680
; NOTA_DS5 equ $060E
; NOTA_E5  equ $0580
; NOTA_F5  equ $050E
; NOTA_FS5 equ $0480
; NOTA_G5  equ $040E
; NOTA_GS5 equ $0380
; NOTA_A5  equ $030E
; NOTA_AS5 equ $0280
; NOTA_B5  equ $020E
;====================================================
