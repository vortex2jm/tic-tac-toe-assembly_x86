; pre-processor directives
%ifndef macros_
%define macros_

%include "consts.asm"

; verify_player_won(register_to_compare, label_to_jump)
%macro check_player_won 2
  compare_condition %1, PLAYER_WON_012, %2
  compare_condition %1, PLAYER_WON_345, %2
  compare_condition %1, PLAYER_WON_678, %2
  compare_condition %1, PLAYER_WON_048, %2
  compare_condition %1, PLAYER_WON_642, %2
  compare_condition %1, PLAYER_WON_630, %2
  compare_condition %1, PLAYER_WON_741, %2
  compare_condition %1, PLAYER_WON_852, %2
%endmacro

; compare_condition(register_to_compare, variable_to_compare, label_to_jump)
%macro compare_condition 3
  push %1
  and %1, %2
  cmp %1, %2
  pop %1
  je %3
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
