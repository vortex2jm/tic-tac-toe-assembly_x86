%ifndef consts_
%define consts_

%define TABLE_FULL     0x01ff
%define PLAYER_WON_012 0x0007 
%define PLAYER_WON_345 0x0038
%define PLAYER_WON_678 0x01C0
%define PLAYER_WON_048 0x0111
%define PLAYER_WON_642 0x0054
%define PLAYER_WON_630 0x0049
%define PLAYER_WON_741 0x0092
%define PLAYER_WON_852 0x0124

; board vertexes
%define X_EXTREME_0 170    
%define X_EXTREME_1 470
%define Y_EXTREME_0 100
%define Y_EXTREME_1 400

; NOTE: Add 100 to go to the next column
%define VERT_X_BASE 220
%define VERT_X_SECOND_COLUMN_BASE 320
%define VERT_X_THIRD_COLUMN_BASE 420

; NOTE: Sub 100 to go to the next row
%define HORIZ_Y_BASE 350
%define HORIZ_Y_SECOND_LINE_BASE 250
%define HORIZ_Y_THIRD_LINE_BASE 150

; Saving colors
%define  black		   		0x0
%define  blue		   		0x1
%define  green		   		0x2
%define  cyan		   		0x3
%define  red	       		0x4
%define  magenta			0x5
%define  brown		   		0x6
%define  white		   		0x7
%define  grey		   		0x8
%define  light_blue		    0x9
%define  light_green		0xa
%define  light_cyan		    0xb
%define  pink		   		0xc
%define  light_magenta		0xd
%define  yellow			    0xe
%define  intense_white		0xf

%endif
