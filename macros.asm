; pre-processor directives
%ifndef macros_
%define macros_

%include "consts.asm"

; finish match(msg_to_display)
%macro finish_match 1
  ; print message
  mov dx, %1
  mov ah, 0x9
  int 0x21

  ;Press any key
  mov ah, 0x7
  int 0x21

  ; Returning main video mode
  mov al, [prev_video_mode]
  mov ah, 0
  int 10h

  ; exit
  mov ah, 0x4c
  int 0x21
%endmacro


; verify_player_won(register_to_compare, label_to_jump)
%macro check_player_won 2
  compare_condition %1, PLAYER_WON_012, %2, word'h', word 0x0  
  compare_condition %1, PLAYER_WON_345, %2, word'h', word 0x1
  compare_condition %1, PLAYER_WON_678, %2, word'h', word 0x2
  compare_condition %1, PLAYER_WON_048, %2, word'd', word 0x0
  compare_condition %1, PLAYER_WON_642, %2, word'd', word 0x1
  compare_condition %1, PLAYER_WON_630, %2, word'v', word 0x0
  compare_condition %1, PLAYER_WON_741, %2, word'v', word 0x1
  compare_condition %1, PLAYER_WON_852, %2, word'v', word 0x2
%endmacro

; compare_condition(register_to_compare, variable_to_compare, label_to_jump)
%macro compare_condition 5
  push %1
  and %1, %2
  cmp %1, %2
  pop %1
  push %4   ;Pushing line drawing information
  push %5   ;Pushing line drawing information
  je %3
  pop dx
  pop dx
%endmacro

; check_position_taken(table_moves, positon_bitmask, move_taken_label, move_not_taken_label)
%macro check_position_taken 4
  ; save context
  push ax
  push bx

  mov ax, [%2]
  mov bx, [%1]
  and ax, bx
  cmp ax, 0

  ; restore context
  pop ax
  pop bx
  ; if the and with the bitmask results in 0, the positions has not been taken yet
  je %4
  ; otherwise, it was
  jmp %3
%endmacro

; save_player_move(player_variable)
%macro save_move 1
  mov bx, [%1]
  or ax, bx 
  mov [%1], ax
%endmacro

; draw_line(x1, y1, x2, y2, color)
%macro draw_line 5
	mov		byte[cor], %5	
	mov		ax, %1
	push		ax
	mov		ax, %2
	push		ax
	mov		ax, %3
	push		ax
	mov		ax, %4
	push		ax
	call		line
%endmacro

; draw_circle(xc, yc, r, color)
%macro draw_circle 4 
	mov byte[cor], %4
	mov		ax, %1
	push		ax
	mov		ax, %2
	push		ax
	mov		ax, %3
	push		ax
	call circle
%endmacro

; draw_x(x1, y1, x2, y2, color)
%macro draw_x 5
	mov byte[cor], %5
	mov ax, %1
	push	ax
	mov ax, %2
	push	ax
	mov ax, %3
	push	ax
	mov ax, %4
	push	ax
	call line
	mov ax, %1
	push	ax
	mov ax, %4
	push	ax
	mov ax, %3
	push	ax
	mov ax, %2
	push	ax
	call line
%endmacro


;draw_circle_on_board(x, y, r, color)
%macro draw_circle_on_board 4
	mov byte[cor], %4
	mov ax, 100
	mov bx, %2

	push dx
	mul bx
	pop dx
	
	add ax, 220
	push ax
	mov ax, 100
	mov bx, %1
	
	push dx
	mul bx
	pop dx
	
	mov bx, 340
	sub bx, ax
	push bx
	mov bx, %3
	push bx
	call circle
%endmacro

;draw_x_on_board(x, y, xsize, color)
%macro draw_x_on_board 4
	mov byte[cor], %4
	mov ax, 100
	mov bx, %2

	push dx
	mul bx
	pop dx
	
	add ax, 220
  sub ax, %3
  ; x converted 
	push ax
  add ax, %3
  push ax

	mov ax, 100
	mov bx, %1
	
	push dx
	mul bx
	pop dx
	
	mov bx, 340
  ; y converted
	sub bx, ax

  ; ax -> x converted
  pop ax

  ; yc - xsize
  sub bx, %3
	push bx

  ; ax -> x + xc
  add ax, %3
  push ax

  add bx, %3
  add bx, %3
  ; bx -> yc + xsize
  push bx

	call line

  ; ax -> xc + xsize
  ; bx -> yc + xsize
  push ax
  sub bx, %3
  sub bx, %3
  ; bx -> yc - xsize
  push bx

  sub ax, %3
  sub ax, %3
  ; ax -> xc - xsize
  push ax
  add bx, %3
  add bx, %3
  ; bx -> yc + xsize
  push bx

  call line
%endmacro

%endif
