%ifndef utils_
%define uitils_

%include "macros.asm"

check_end_of_match:
  push ax

  ; check if table is full
  mov ax, [table_moves]
  compare_condition ax, TABLE_FULL, table_full, word 0x0

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
    jmp draw_winner_line

    finish_o:
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
    jmp draw_winner_line

    finish_x:
    finish_match player_x_won_msg

  handle_player_x_won_ret:
    pop ax
    ret


draw_winner_line:
  pop dx  ; pop number
  ;mov [win_line_case], dx
  ;mov dx, win_line_case

  ;mov ah, 0x9
  ;int 0x21

  ;mov ah, 0x4c
  ;int 0x21

  mov dh, 'd'
  mov dl, '0'
  jmp d_case

  xor ax, ax
  mov al, 'd'
  cmp al, dh 
  je d_case
  mov al, 'h'
  cmp al, dh
  je h_case
  jmp v_case
  ;mov al, 'v'
  ;cmp al, dh
  ;je v_case

  d_case: 
    cmp dl, '1'
    je d_case_1
    d_case_0:
      draw_line X_EXTREME_0, Y_EXTREME_1, X_EXTREME_1, Y_EXTREME_0, intense_white
      jmp end
    d_case_1:
      draw_line X_EXTREME_1, Y_EXTREME_1, X_EXTREME_0, Y_EXTREME_0, intense_white
      jmp end
  
  h_case:
    cmp dl, '1'
    je h_case_1
    cmp dl, '2' 
    je h_case_2
    h_case_0:
      draw_line X_EXTREME_0, HORIZ_Y_BASE, X_EXTREME_1, HORIZ_Y_BASE, blue
      jmp end
    h_case_1:
      draw_line X_EXTREME_0, HORIZ_Y_SECOND_LINE_BASE, X_EXTREME_1, HORIZ_Y_SECOND_LINE_BASE, blue
      jmp end
    h_case_2:
      draw_line X_EXTREME_0, HORIZ_Y_THIRD_LINE_BASE, X_EXTREME_1, HORIZ_Y_THIRD_LINE_BASE, blue
      jmp end

  v_case:
    cmp dl, '1'
    je v_case_1
    cmp dl, '2' 
    je v_case_2
    v_case_0:
      draw_line VERT_X_BASE, Y_EXTREME_0, VERT_X_BASE, Y_EXTREME_1, blue 
      jmp end
    v_case_1:
      draw_line VERT_X_SECOND_COLUMN_BASE, Y_EXTREME_0, VERT_X_SECOND_COLUMN_BASE, Y_EXTREME_1, blue 
      jmp end
    v_case_2:
      draw_line VERT_X_THIRD_COLUMN_BASE, Y_EXTREME_0, VERT_X_THIRD_COLUMN_BASE, Y_EXTREME_1, blue 

  end:
    mov ax, [current_play]
    cmp ax, 'X'
    je jump_finish_x
    jmp finish_o
    jump_finish_x:
    jmp finish_x

draw_board: 
  ;-----------------------------------------;
  ; Board lines
  draw_line 270, 100, 270, 400, intense_white	
  draw_line 370, 100, 370, 400, intense_white	
  draw_line 170, 200, 470, 200, intense_white	
  draw_line 170, 300, 470, 300, intense_white	
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
