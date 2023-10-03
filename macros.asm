%macro draw_line 4
	mov		byte[cor], branco_intenso	
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