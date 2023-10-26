%ifndef utils_
%define uitils_

%include "macros.asm"

check_end_of_match:
  push ax

  ; check if table is full
  mov ax, [table_moves]
  compare_condition ax, TABLE_FULL, table_full

  call handle_player_x_won
  call handle_player_o_won

  jmp check_end_of_match_ret

  table_full:
    finish_match full_table_message

  check_end_of_match_ret:
    pop ax
    ret

handle_player_o_won: 
  push ax
  ; check if player o has won
  mov ax, [player_o_moves]
  check_player_won ax, player_o_won_match
  jmp handle_player_o_won_ret

  player_o_won_match:
    finish_match player_x_won_msg

  handle_player_o_won_ret
    pop ax
    ret

handle_player_x_won: 
  push ax
  ; check if player x has won
  mov ax, [player_x_moves]
  check_player_won ax, player_x_won_match
  jmp handle_player_x_won_ret

  player_x_won_match:
    finish_match player_x_won_msg

  handle_player_x_won_ret:
    pop ax
    ret

draw_board: 
  ;-----------------------------------------;
  ; Board lines
  draw_line 270, 100, 270, 400, intense_white	
  draw_line 370, 100, 370, 400, intense_white	
  draw_line 170, 190, 470, 190, intense_white	
  draw_line 170, 290, 470, 290, intense_white	
  ret

; INPUT: move in the form (x, y). 
;   x from 0 to 3
;   y from 0 to 3
;   x is passed through cx
;   y is passed through dx
; OUTPUT: 2 bytes of bit mask representing the move in the form:
;   move = 0000000000000x00
;   x representing any arbitrary move taken
;   bit mask is set in ax
convert_move_to_bit_mask:
  push cx
  push dx
  ; formula; 
  ; pos_bit_mask = (y * 3) + x 

  ; ax = y * 3 
  mov ax, 3
  mul dx

  ; ax = (y * 3) + x
  add ax, cx

  ; if position is greather than 1 byte shift
  cmp ax, 0x0008
  je edge_case
  jmp shift_case

  shift_case:
    mov ah, 0x0
    ; rotation value
    mov cl, al
    mov al, 0x1
    shl al, cl
    jmp final

  edge_case: 
  mov ax, 0x0100
  jmp final

  final: 
  pop cx
  pop dx
  ret

%endif
