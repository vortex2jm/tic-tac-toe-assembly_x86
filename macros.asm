; pre-processor directives
%ifndef macros_
%define macros_

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


;draw_circle(x, y, r, color)
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

%endif
