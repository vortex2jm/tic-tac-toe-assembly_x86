; GRUPO
; João Paulo Moura Clevelares
; Kevin Carvalho de Jesus
%include "macros.asm"
%include "consts.asm"

;----------------------------------------------------
; Data
;----------------------------------------------------
segment data  
  ; Initialization
  title                db 'TIC TAC TOE O/X'    ;15 
  cor		               db intense_white
  prev_video_mode      db 0x0
  start_message        db 'The game has been started!'   ;26
  buffer: times 1023   db 0x0
  buffer_ptr           db 0x0
  void_cf: times 30    db 0x20

  ; move management
  last_play_symbol       db 0x0              ; X/C
  current_play_symbol    db 0x0              ; X/C
  current_play_lc        db 0x0, 0x0         ;line&column

  player_bitmask  dw  0x0
  player_x_moves  dw  0x0
  player_o_moves  dw  0x0
  table_moves     dw  0x0

  ; Messages
  player_x_won_msg     db 'PLAYER X WON!             '  ;26
  player_o_won_msg     db 'PLAYER O WON!             '  ;26  
  full_table_message   db 'BOARD FULL, NO WINNER!    '   ;26
  winner_line          db  0x0, 0x0
  motivational_message db 'May the best win!         '   ;26
  buffer_overflow_msg  db 'BUFFER OVERFLOW!          '

  command_error_msg   db 'INVALID COMMAND!          '   ;26
  repeated_move_msg   db 'PLAY ANOTHER SYMBLE!      '   ;26 
  position_held_msg   db 'POSITION HELD!            '   ;26
  input_error_flag    db 0x0

  press_key_msg       db 'PRESS ANY KEY TO CLOSE    ' ;26

  ; Graphic functions management
  linha   	      dw  0x0
  coluna  	      dw  0x0
  deltax		      dw	0x0
  deltay		      dw	0x0

segment stack stack						
  resb 512	; 512 bytes for stack
stacktop:

;----------------------------------------------------
; Code
;----------------------------------------------------
segment code
..start:
  ;------------------------------------
  ; Setting up
  ;------------------------------------
  mov 	ax,data						
  mov 	ds,ax
  mov 	ax,stack	
  mov 	ss,ax
  mov 	sp,stacktop

  ; Saving currently video mode
  mov  		ah,0Fh
  int  		10h
  mov  		[prev_video_mode],al   

  ; Change video mode for graphic 640x480 16 colors 
  mov     	al,12h
  mov     	ah,0
  int     	10h	

  ;------------------------------------
  ; First input
  ;------------------------------------
  ; Verifying first input
  ; if char = c -> create new game
  ; if char = s -> end game
  ; else wait for another input
  entrypoint:
    mov ah, 0x7
    int 0x21
    mov ah, 'c'    ;0x63    
    cmp ah, al
    je start_game  
    mov ah, 's'    ;0x73
    cmp ah, al
    je  end_game
    jmp entrypoint

  ;------------------------------------
  ; Exit
  ;------------------------------------
  ; Closing game if char = s
  end_game:
    ; Returning main video mode
    mov al, [prev_video_mode]
    mov ah, 0
    int 10h
    
    ; Terminating program
    mov ah, 0x4c
    int 0x21
  
  ;------------------------------------
  ; Playing
  ;------------------------------------
  start_game:
    ;------------------------------------
    ; Initialization
    ;------------------------------------
    call draw_board
    call draw_fields
    print_message 2, 32, title, 15, magenta
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, start_message ,26 ,yellow

    ;------------------------------------
    ; Buffer started
    ;------------------------------------
    command_buffer:
    ; Reset buffer pointer
    mov [buffer_ptr], byte 0x0
    
    ; check end of match prematurelly
    call check_end_of_match

    input_reading:
    xor bx, bx
    mov bl, [buffer_ptr]

    cmp bl, 0x1e
    jne read_char
    jmp buffer_overflow
    invalid_read_loop:
    mov ah, 0x7
    int 0x21
    cmp al, 0x8
    je bspc
    jmp invalid_read_loop

    read_char:
    mov ah, 0x7
    int 0x21

    ; Verify if char is backspace
    cmp al, 0x8
    jne not_bspc

    ; If char is backspace
    bspc:
    cmp bl, 0x0
    je reset_input
    dec bl
    mov [buffer+bx], byte 0x0
    mov [buffer_ptr], bl
    jmp reset_input

    ; If char is not backspace
    not_bspc:
    mov [buffer+bx], al
    inc bl
    mov [buffer_ptr], bl
    cmp al, 0xd             ; If key is ENTER

    ; Back to reading
    reset_input:
    jne input_reading
    
    ;------------------------------------
    ; Printing command
    ;------------------------------------
    ; Reset command field
    print_message COMMAND_FIELD_L, COMMAND_FIELD_C, void_cf, 30, black 
    ; Printing new message
    dec bx
    print_message COMMAND_FIELD_L, COMMAND_FIELD_C, buffer, bx, cyan

    ;------------------------------------
    ; Parsing first character (letter)
    ;------------------------------------
    mov al, byte[buffer]
    cmp al, 'X'
    je validate_alternate_play     ; if letter equal X, jump to validate repeated plays

    ; If commando is not X
    validate_letter_command:
    cmp al, 'C'    
    jne invalid_command     ; Command needs to be X or C, else is an invalid command

    ;------------------------------------
    ; Verifying repeated X or C plays
    ;------------------------------------
    validate_alternate_play:
    mov [current_play_symbol], al   
    mov ah, [last_play_symbol]      
    cmp ah, al
    je invalid_play
    xor ah, ah
    push ax     ; Pushing move into stack to be used in another function

    ;------------------------------------
    ; Parsing line and comlumn
    ;------------------------------------
    validate_numbers:
    mov cx, 0x2     ; Loop counter
    mov bx, 0x0
    lc_parse:
    mov al, byte[buffer+bx+1]              
    cmp al, '4'             ; Checks if number is greater or equal 4
    jge invalid_command           
    cmp al, '0'               ; Checks if the number is less or equal 0
    jle invalid_command
    xor ah, ah
    push ax
    mov [current_play_lc+bx], al
    inc bx
    loop lc_parse

    ;------------------------------------
    ; ENTER KEY validation
    ;------------------------------------
    mov al, [buffer+3]
    cmp al, 0xd
    jne invalid_command
    jmp draw_move   ; Jumping over validation exceptions

    ;------------------------------------
    ; Printing error messages
    ;------------------------------------
    ; If command is not X or C, print error message and wait for another input
    invalid_command:
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, command_error_msg, 26, red
    jmp command_buffer
  
    ; If current play has already been played in last play
    invalid_play:
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, repeated_move_msg, 26, red
    jmp command_buffer

    ; If current play try to move over a held position
    invalid_play_case2:
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, position_held_msg, 26, red
    jmp command_buffer

    buffer_overflow:
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, buffer_overflow_msg, 26, red
    jmp invalid_read_loop

    ;------------------------------------
    ; Validating board and drawing symbols
    ;------------------------------------
    draw_move:
    ; converting moves to a range of 0-3
    ; l value is in cx
    ; c value is in dx
    pop dx          ; Getting column valeu from stack
    sub dx, 0x31    ; Parsing ASCII to int
    pop cx          ; Getting line value from stack
    sub cx, 0x31    ; Parsing ASCII to int

    call convert_move_to_bit_mask
    
    ; save player player_bitmask to a variable
    mov [player_bitmask], ax
    call check_end_of_match

    ; check if position has already been taken
    check_position_taken table_moves, player_bitmask, invalid_play_case2, move_not_taken
    
    ; If position hasn't been taken
    move_not_taken:
    mov al, [current_play_symbol]  ; If valid command, process this play (Avoid bug)
    mov [last_play_symbol], al

    ; Printing motivational message
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, motivational_message,26 ,yellow

    ; clean up ax
    xor ax, ax
    mov ah, [current_play_symbol]
    cmp ah, 'C'
    je should_draw_circle
    cmp ah, 'X'
    je should_draw_x
    jmp invalid_play

    should_draw_circle: 
    mov ax, [player_bitmask]

    ; save moves
    save_move player_o_moves
    save_move table_moves

    draw_circle_on_board dx, cx, 20, red
    jmp command_buffer

    should_draw_x: 
    mov ax, [player_bitmask]

    ; save moves
    save_move player_x_moves
    save_move table_moves

    draw_x_on_board dx, cx, 20, red
    jmp command_buffer

  %include "utils.asm"

; # The program ends here. Below there are functions to manage graphic mode #

;------------------------------------------------------------------------------;
;GRAPHIC
;------------------------------------------------------------------------------;
;   funcao plot_xy
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
    push		bp
    mov		bp,sp
    pushf
    push 		ax
    push 		bx
    push		cx
    push		dx
    push		si
    push		di
    mov     	ah,0ch
    mov     	al,[cor]
    mov     	bh,0
    mov     	dx,479
    sub		dx,[bp+4]
    mov     	cx,[bp+6]
    int     	10h
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
    pop		bp
    ret		4
;_____________________________________________________________________________
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
;    funcao circle
;    cor definida na variavel cor
circle:
    push 	bp
    mov	 	bp,sp
    pushf                        ;coloca os flags na pilha
    push 	ax
    push 	bx
    push	cx
    push	dx
    push	si
    push	di
    
    mov		ax,[bp+8]    ; resgata xc
    mov		bx,[bp+6]    ; resgata yc
    mov		cx,[bp+4]    ; resgata r
    
    mov 	dx,bx	
    add		dx,cx       ;ponto extremo superior
    push    ax			
    push	dx
    call plot_xy
    
    mov		dx,bx
    sub		dx,cx       ;ponto extremo inferior
    push    ax			
    push	dx
    call plot_xy
    
    mov 	dx,ax	
    add		dx,cx       ;ponto extremo direita
    push    dx			
    push	bx
    call plot_xy
    
    mov		dx,ax
    sub		dx,cx       ;ponto extremo esquerda
    push    dx			
    push	bx
    call plot_xy
        
    mov		di,cx
    sub		di,1	 ;di=r-1
    mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
    
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d
stay:				;loop
    mov		si,di
    cmp		si,0
    jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov		si,dx		;o jl � importante porque trata-se de conta com sinal
    sal		si,1		;multiplica por doi (shift arithmetic left)
    add		si,3
    add		di,si     ;nesse ponto d=d+2*dx+3
    inc		dx		;incrementa dx
    jmp		plotar
inf:	
    mov		si,dx
    sub		si,cx  		;faz x - y (dx-cx), e salva em di 
    sal		si,1
    add		si,5
    add		di,si		;nesse ponto d=d+2*(dx-cx)+5
    inc		dx		;incrementa x (dx)
    dec		cx		;decrementa y (cx)
    
plotar:	
    mov		si,dx
    add		si,ax
    push    si			;coloca a abcisa x+xc na pilha
    mov		si,cx
    add		si,bx
    push    si			;coloca a ordenada y+yc na pilha
    call plot_xy		;toma conta do segundo octante
    mov		si,ax
    add		si,dx
    push    si			;coloca a abcisa xc+x na pilha
    mov		si,bx
    sub		si,cx
    push    si			;coloca a ordenada yc-y na pilha
    call plot_xy		;toma conta do s�timo octante
    mov		si,ax
    add		si,cx
    push    si			;coloca a abcisa xc+y na pilha
    mov		si,bx
    add		si,dx
    push    si			;coloca a ordenada yc+x na pilha
    call plot_xy		;toma conta do segundo octante
    mov		si,ax
    add		si,cx
    push    si			;coloca a abcisa xc+y na pilha
    mov		si,bx
    sub		si,dx
    push    si			;coloca a ordenada yc-x na pilha
    call plot_xy		;toma conta do oitavo octante
    mov		si,ax
    sub		si,dx
    push    si			;coloca a abcisa xc-x na pilha
    mov		si,bx
    add		si,cx
    push    si			;coloca a ordenada yc+y na pilha
    call plot_xy		;toma conta do terceiro octante
    mov		si,ax
    sub		si,dx
    push    si			;coloca a abcisa xc-x na pilha
    mov		si,bx
    sub		si,cx
    push    si			;coloca a ordenada yc-y na pilha
    call plot_xy		;toma conta do sexto octante
    mov		si,ax
    sub		si,cx
    push    si			;coloca a abcisa xc-y na pilha
    mov		si,bx
    sub		si,dx
    push    si			;coloca a ordenada yc-x na pilha
    call plot_xy		;toma conta do quinto octante
    mov		si,ax
    sub		si,cx
    push    si			;coloca a abcisa xc-y na pilha
    mov		si,bx
    add		si,dx
    push    si			;coloca a ordenada yc-x na pilha
    call plot_xy		;toma conta do quarto octante
    
    cmp		cx,dx
    jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
    jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
        
        
fim_circle:
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
    pop		bp
    ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
    push 	bp
    mov	 	bp,sp
    pushf                        ;coloca os flags na pilha
    push 	ax
    push 	bx
    push	cx
    push	dx
    push	si
    push	di
    mov		ax,[bp+8]    ; resgata xc
    mov		bx,[bp+6]    ; resgata yc
    mov		cx,[bp+4]    ; resgata r
    
    mov		si,bx
    sub		si,cx
    push    ax			;coloca xc na pilha			
    push	si			;coloca yc-r na pilha
    mov		si,bx
    add		si,cx
    push	ax		;coloca xc na pilha
    push	si		;coloca yc+r na pilha
    call line
    
        
    mov		di,cx
    sub		di,1	 ;di=r-1
    mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
    
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d
stay_full:				;loop
    mov		si,di
    cmp		si,0
    jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov		si,dx		;o jl � importante porque trata-se de conta com sinal
    sal		si,1		;multiplica por doi (shift arithmetic left)
    add		si,3
    add		di,si     ;nesse ponto d=d+2*dx+3
    inc		dx		;incrementa dx
    jmp		plotar_full
inf_full:	
    mov		si,dx
    sub		si,cx  		;faz x - y (dx-cx), e salva em di 
    sal		si,1
    add		si,5
    add		di,si		;nesse ponto d=d+2*(dx-cx)+5
    inc		dx		;incrementa x (dx)
    dec		cx		;decrementa y (cx)
    
plotar_full:	
    mov		si,ax
    add		si,cx
    push	si		;coloca a abcisa y+xc na pilha			
    mov		si,bx
    sub		si,dx
    push    si		;coloca a ordenada yc-x na pilha
    mov		si,ax
    add		si,cx
    push	si		;coloca a abcisa y+xc na pilha	
    mov		si,bx
    add		si,dx
    push    si		;coloca a ordenada yc+x na pilha	
    call 	line
    
    mov		si,ax
    add		si,dx
    push	si		;coloca a abcisa xc+x na pilha			
    mov		si,bx
    sub		si,cx
    push    si		;coloca a ordenada yc-y na pilha
    mov		si,ax
    add		si,dx
    push	si		;coloca a abcisa xc+x na pilha	
    mov		si,bx
    add		si,cx
    push    si		;coloca a ordenada yc+y na pilha	
    call	line
    
    mov		si,ax
    sub		si,dx
    push	si		;coloca a abcisa xc-x na pilha			
    mov		si,bx
    sub		si,cx
    push    si		;coloca a ordenada yc-y na pilha
    mov		si,ax
    sub		si,dx
    push	si		;coloca a abcisa xc-x na pilha	
    mov		si,bx
    add		si,cx
    push    si		;coloca a ordenada yc+y na pilha	
    call	line
    
    mov		si,ax
    sub		si,cx
    push	si		;coloca a abcisa xc-y na pilha			
    mov		si,bx
    sub		si,dx
    push    si		;coloca a ordenada yc-x na pilha
    mov		si,ax
    sub		si,cx
    push	si		;coloca a abcisa xc-y na pilha	
    mov		si,bx
    add		si,dx
    push    si		;coloca a ordenada yc+x na pilha	
    call	line
    
    cmp		cx,dx
    jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
    jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
    
    
fim_full_circle:
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
    pop		bp
    ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
    push		bp
    mov		bp,sp
    pushf                        ;coloca os flags na pilha
    push 		ax
    push 		bx
    push		cx
    push		dx
    push		si
    push		di
    mov		ax,[bp+10]   ; resgata os valores das coordenadas
    mov		bx,[bp+8]    ; resgata os valores das coordenadas
    mov		cx,[bp+6]    ; resgata os valores das coordenadas
    mov		dx,[bp+4]    ; resgata os valores das coordenadas
    cmp		ax,cx
    je		line2
    jb		line1
    xchg		ax,cx
    xchg		bx,dx
    jmp		line1
line2:		; deltax=0
    cmp		bx,dx  ;subtrai dx de bx
    jb		line3
    xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
    push		ax
    push		bx
    call 		plot_xy
    cmp		bx,dx
    jne		line31
    jmp		fim_line
line31:
    inc		bx
    jmp		line3
line1:
    push		cx
    sub		cx,ax
    mov		[deltax],cx
    pop		cx
    push		dx
    sub		dx,bx
    ja		line32
    neg		dx
line32:		
    mov		[deltay],dx
    pop		dx
    push		ax
    mov		ax,[deltax]
    cmp		ax,[deltay]
    pop		ax
    jb		line5
; cx > ax e deltax>deltay
    push		cx
    sub		cx,ax
    mov		[deltax],cx
    pop		cx
    push		dx
    sub		dx,bx
    mov		[deltay],dx
    pop		dx
    mov		si,ax
line4:
    push		ax
    push		dx
    push		si
    sub		si,ax	;(x-x1)
    mov		ax,[deltay]
    imul		si
    mov		si,[deltax]		;arredondar
    shr		si,1
    ; se numerador (DX)>0 soma se <0 subtrai
    cmp		dx,0
    jl		ar1
    add		ax,si
    adc		dx,0
    jmp		arc1
ar1:	
	sub		ax,si
    sbb		dx,0
arc1:
    idiv		word [deltax]
    add		ax,bx
    pop		si
    push		si
    push		ax
    call		plot_xy
    pop		dx
    pop		ax
    cmp		si,cx
    je		fim_line
    inc		si
    jmp		line4
line5:		
    cmp		bx,dx
    jb 		line7
    xchg	ax,cx
    xchg	bx,dx
line7:
    push		cx
    sub		cx,ax
    mov		[deltax],cx
    pop		cx
    push		dx
    sub		dx,bx
    mov		[deltay],dx
    pop		dx
    mov		si,bx
line6:
    push		dx
    push		si
    push		ax
    sub		si,bx	;(y-y1)
    mov		ax,[deltax]
    imul		si
    mov		si,[deltay]		;arredondar
    shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
    cmp		dx,0
    jl		ar2
    add		ax,si
    adc		dx,0
    jmp		arc2
ar2:		sub		ax,si
    sbb		dx,0
arc2:
    idiv		word [deltay]
    mov		di,ax
    pop		ax
    add		di,ax
    pop		si
    push		di
    push		si
    call		plot_xy
    pop		dx
    cmp		si,dx
    je		fim_line
    inc		si
    jmp		line6
fim_line:
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
    pop		bp
    ret		8

;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
    	mov     	ah,9
    	mov     	bh,0
    	mov     	cx,1
   	mov     	bl,[cor]
    	int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret