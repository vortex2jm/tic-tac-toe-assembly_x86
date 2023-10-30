%ifndef utils_
%define uitils_

%include "macros.asm"

;--------------------------------------------------
; End of match function (It checks if someone wins)
;--------------------------------------------------
check_end_of_match:
  push ax

  ; Check both players
  call handle_player_x_won
  call handle_player_o_won

  ; Check if table is full (tie)
  mov ax, [table_moves]
  and ax, TABLE_FULL
  cmp ax, TABLE_FULL
  je table_full

  jmp check_end_of_match_ret

  table_full:
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, full_table_message, 26, red
    call finish_match

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
      print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, player_o_won_msg, 26, light_green
      call finish_match

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
    print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, player_x_won_msg ,26 , light_green
    call finish_match

  handle_player_x_won_ret:
    pop ax
    ret


;--------------------------------------------------
; Winner line function
;--------------------------------------------------
; draws a line in the sequence that won the game
draw_winner_line:
  ; get drawing information from variable
  mov dh, [winner_line]
  mov dl, [winner_line + 1]

  ; decide where to draw the line
  cmp dh, 'd'
  je d_case
  cmp dh, 'h'
  je h_case
  jmp v_case

  d_case: 
    cmp dl, '1'
    je d_case_1
    d_case_0:
      draw_line X_EXTREME_0, Y_EXTREME_1, X_EXTREME_1, Y_EXTREME_0, light_green
      jmp end
    d_case_1:
      draw_line X_EXTREME_1, Y_EXTREME_1, X_EXTREME_0, Y_EXTREME_0, light_green
      jmp end
  
  h_case:
    cmp dl, '1'
    je h_case_1
    cmp dl, '2' 
    je h_case_2
    h_case_0:
      draw_line X_EXTREME_0, HORIZ_Y_BASE, X_EXTREME_1, HORIZ_Y_BASE, light_green
      jmp end
    h_case_1:
      draw_line X_EXTREME_0, HORIZ_Y_SECOND_LINE_BASE, X_EXTREME_1, HORIZ_Y_SECOND_LINE_BASE, light_green
      jmp end
    h_case_2:
      draw_line X_EXTREME_0, HORIZ_Y_THIRD_LINE_BASE, X_EXTREME_1, HORIZ_Y_THIRD_LINE_BASE, light_green
      jmp end

  v_case:
    cmp dl, '1'
    je v_case_1
    cmp dl, '2' 
    je v_case_2
    v_case_0:
      draw_line VERT_X_BASE, Y_EXTREME_0, VERT_X_BASE, Y_EXTREME_1, light_green 
      jmp end
    v_case_1:
      draw_line VERT_X_SECOND_COLUMN_BASE, Y_EXTREME_0, VERT_X_SECOND_COLUMN_BASE, Y_EXTREME_1, light_green 
      jmp end
    v_case_2:
      draw_line VERT_X_THIRD_COLUMN_BASE, Y_EXTREME_0, VERT_X_THIRD_COLUMN_BASE, Y_EXTREME_1, light_green 

  end:
    mov ax, [current_play_symbol]
    xor ah, ah
    cmp ax, 'X'
    je jump_finish_x
    jmp finish_o
    jump_finish_x:
    jmp finish_x


;--------------------------------------------------
; Drawing board function
;--------------------------------------------------
draw_board: 
  draw_line 270, 100, 270, 400, intense_white	
  draw_line 370, 100, 370, 400, intense_white	
  draw_line 170, 200, 470, 200, intense_white	
  draw_line 170, 300, 470, 300, intense_white	
  ret


;--------------------------------------------------
; Drawing fields function
;--------------------------------------------------
draw_fields:
  ; command field
  ; horizontal lines
  draw_line 170,83 ,470, 83, intense_white
  draw_line 170,58 ,470, 58, intense_white
  ; vertical lines
  draw_line 170,58 ,170, 83, intense_white
  draw_line 470,58 ,470, 83, intense_white

  ; message field
  ; horizontal lines
  draw_line 170,50 ,470, 50, intense_white
  draw_line 170,25 ,470, 25, intense_white
  ; vertical lines
  draw_line 170,25 ,170, 50, intense_white
  draw_line 470,25 ,470, 50, intense_white
  ret

;--------------------------------------------------
; Finish match function
;--------------------------------------------------
finish_match:
  ; Wait a time before show the next message
  mov cx, 0xffff  
  for:
    push cx
    mov cx, 0x8f
    for_2:
      loop for_2
      pop cx
      loop for 

  print_message MESSAGE_FIELD_L, MESSAGE_FIELD_C, press_key_msg, 26, yellow

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


;--------------------------------------------------
; Move validation function (using bit masks)
;--------------------------------------------------
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