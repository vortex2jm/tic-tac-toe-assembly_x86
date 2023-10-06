%include "macros.asm"

; DS
segment data
    cor		        db		branco_intenso
    prev_video_mode	db		0

    linha   	    dw  	0
    coluna  	    dw  	0
    deltax		    dw		0
    deltay		    dw		0

    ; Saving colors
    preto		    equ		0x0
    azul		    equ		0x1
    verde		    equ		0x2
    cyan		    equ		0x3
    vermelho	    equ		0x4
    magenta		    equ		0x5
    marrom		    equ		0x6
    branco		    equ		0x7
    cinza		    equ		0x8
    azul_claro	    equ		0x9
    verde_claro	    equ		0xa
    cyan_claro	    equ		0xb
    rosa		    equ		0xc
    magenta_claro	equ		0xd
    amarelo		    equ		0xe
    branco_intenso	equ		0xf

; SS
segment stack stack						
		resb 256	; 256 bytes for stack
stacktop:

; CS
segment code
..start:
    ;Setting up segment registers
    MOV 	AX,data						
	MOV 	DS,AX
	MOV 	AX,stack	
	MOV 	ss,AX
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
        mov ah, 0x63    ;c character    
        cmp ah, al
        je start_game  
        mov ah, 0x73    ;s character
        cmp ah, al
        je  end_game
        jmp entrypoint

    start_game:
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

        draw_line 270, 100, 270, 400, branco_intenso	
        draw_line 370, 100, 370, 400, branco_intenso	
        draw_line 170, 190, 470, 190, branco_intenso	
        draw_line 170, 290, 470, 290, branco_intenso	
        draw_circle 220, 240, 20, cyan

    end_game:
        ; Returning main video mode
        mov al, [prev_video_mode]
        mov ah, 0
        int 10h
        
        ; Terminating program
        mov ah, 0x4c
        int 0x21
