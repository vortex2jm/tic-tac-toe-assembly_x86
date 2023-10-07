%include "macros.asm"

; DS
segment data
    cor		        db		intense_white
    prev_video_mode	db		0x0
    last_play       db      0x0

    command_error   db 'Invalid command', 0xd, 0xa, '$'
    play_error      db 'Invalid play, this symble has already been played', 0xd, 0xa, '$' 
    result_msg      db '000$'

    linha   	    dw  	0x0
    coluna  	    dw  	0x0
    deltax		    dw		0x0
    deltay		    dw		0x0

    ; Saving colors
    black		    equ		0x0
    blue		    equ		0x1
    green		    equ		0x2
    cyan		    equ		0x3
    red	            equ		0x4
    magenta		    equ		0x5
    brown		    equ		0x6
    white		    equ		0x7
    grey		    equ		0x8
    light_blue	    equ		0x9
    light_green	    equ		0xa
    light_cyan	    equ		0xb
    pink		    equ		0xc
    light_magenta	equ		0xd
    yellow		    equ		0xe
    intense_white	equ		0xf

; SS
segment stack stack						
		resb 512	; 256 bytes for stack
stacktop:

; CS
segment code
..start:
    ;Setting up segment registers
    MOV 	ax,data						
	MOV 	ds,ax
	MOV 	ax,stack	
	MOV 	ss,ax
	MOV 	sp,stacktop

    ; Saving currently video mode
	mov  		ah,0Fh
	int  		10h
	mov  		[prev_video_mode],al   

    ; Change video mode for graphic 640x480 16 colors 
	mov     	al,12h
	mov     	ah,0
	int     	10h	

    ;==============================;
    entrypoint:
        mov ah, 0x7
        int 0x21
        mov ah, 'c'    ;0x63    
        cmp ah, al
        je start_game  
        mov ah, 's'    ;0x73 character
        cmp ah, al
        je  end_game
        jmp entrypoint

    end_game:
        ; Returning main video mode
        mov al, [prev_video_mode]
        mov ah, 0
        int 10h
        
        ; Terminating program
        mov ah, 0x4c
        int 0x21

    start_game:
        ; SCALE INFO------------------------------;
        ; half screen width
        ; 640 / 2 = 320
        ; first vertical line
        ; 320 - 50 = 270
        ; second vertical line
        ; 320 + 50 = 370

        ; half screen height
        ; 480 / 2 = 240
        ; first horizontal line 
        ; 240 - 50 = 190
        ; second horizontal line
        ; 240 + 50 = 290

        ;-----------------------------------------;
        ; Board lines
        draw_line 270, 100, 270, 400, intense_white	
        draw_line 370, 100, 370, 400, intense_white	
        draw_line 170, 190, 470, 190, intense_white	
        draw_line 170, 290, 470, 290, intense_white	
        
        ;-----------------------------------------;
        ; Circles from top line
        draw_circle 220, 340, 20, cyan  ;11
        draw_circle 320, 340, 20, cyan  ;12
        draw_circle 420, 340, 20, cyan  ;13
        
        ; Circles from middle line
        draw_circle 220, 240, 20, cyan  ;21
        draw_circle 320, 240, 20, cyan  ;22 
        draw_circle 420, 240, 20, cyan  ;23

        ; Circles from bottom line
        draw_circle 220, 140, 20, cyan  ;31
        draw_circle 320, 140, 20, cyan  ;32
        draw_circle 420, 140, 20, cyan  ;33

        ;-----------------------------------------;
        ; X from top line
        draw_x 200, 320, 240, 360, magenta  ;11 
        draw_x 300, 320, 340, 360, magenta  ;12
        draw_x 400, 320, 440, 360, magenta  ;13
        
        ; X from middle line
        draw_x 200, 220, 240, 260, magenta  ;21
        draw_x 300, 220, 340, 260, magenta  ;22
        draw_x 400, 220, 440, 260, magenta  ;23

        ; X from bottom line
        draw_x 200, 120, 240, 160, magenta  ;31
        draw_x 300, 120, 340, 160, magenta  ;32
        draw_x 400, 120, 440, 160, magenta  ;33

        ;jmp commands_buffer
        ;jmp entrypoint


    ; This approach validates one each time
    ; We can also read all input and validate after (Discuss)
    command_buffer:
        ; Parsing first character (letter)
        mov ah, 0x7
        int 0x21
        mov ah, 'X'
        cmp ah, al
        je validate_letter_play     ; if letter equal X, jump to validate repeated plays

        validate_letter_command:
        mov ah, 'C'
        cmp ah, al    
        jne invalid_command

         
        validate_letter_play:   ; Verifying repeated letter plays
        mov ah, [last_play]
        cmp ah, al
        je invalid_play
        xor ah, ah
        push ax

        ; Parsing line and comlumn
        validate_numbers:
        mov cx, 0x2 
        lc_parse:
        mov ah, 0x7
        int 0x21
        mov ah, '4'             ; Check if number is greater or equal 4
        cmp al, ah
        jge invalid_command
        xor ah, ah
        push ax
        loop lc_parse 
        jmp execute_command

    invalid_command:
        mov dx, command_error
        mov ah, 0x9
        int 0x21
        jmp command_buffer

    invalid_play:
        mov dx, play_error
        mov ah, 0x9
        int 0x21
        jmp command_buffer

    execute_command:
        pop bx
        mov [result_msg+2], bl
        pop bx
        mov [result_msg+1], bl
        pop bx
        mov [result_msg], bl
        mov dx, result_msg

        ; Reseting video mode
        mov al, [prev_video_mode]
        mov ah, 0
        int 10h

        ; Printing result
        mov ah, 0x9
        int 0x21
        
        mov ah, 0x4c
        int 0x21


;--FIGURES-----------------------------------------------;

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
    ;    funcao circle
    ;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
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
