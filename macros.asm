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