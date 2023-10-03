; DS
segment data

; SS
segment stack stack						
		resb 256							; 256 bytes for stack
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

    ;==============================;
    entrypoint:
        mov ah, 0x7
        int 0x21
        mov ah, 0x63    ;c character    
        cmp ah, al
        jz start_game  
        mov ah, 0x73    ;s character
        cmp ah, al
        jz  end_game
        jmp entrypoint

    start_game:
        mov ah, 0x4c
        int 0x21

    end_game:
        mov ah, 0x4c
        int 0x21
