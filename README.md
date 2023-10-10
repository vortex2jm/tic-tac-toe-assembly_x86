## Tic tac toe - assembly x86_16 :construction:

### Player moves and board masks
Each playe move and all the positions that have already been played are
represented as 2 bytes, where the least significant 9 bytes represent the positions
on the board. 

If the bit on the position is set to 1, that means that position has been played
by one of the players. The same idea applies for each player move.

#### Representation:
We represent the player moves as well as the board positions as follows: 

![](https://github.com/KPMGE/tic-tac-toe-assembly_x86/blob/master/table.png)

board/moves: 0000000x.xxxxxxxx

So, we can figure out if a player has won the match or if the board if full by
means of some masks. Let's define them:  

##### Board is full:
If the board is full, that means all the 9 least significant bytes are 1,
meaning all positions have been taken, so let's define a mask for that: 

board full mask: 00000001.11111111 => 0x01ff

##### Player won with sequence 012:
won 012 mask: 00000000.00000111 => 0x0007

##### Player won with sequence 345:
won 345 mask: 00000000.00111000 => 0x0038

##### Player won with sequence 678:
won 678 mask: 00000001.11000000 => 0x01C0

##### Player won with sequence 048:
won 048 mask: 00000001.00010001 => 0x0111

##### Player won with sequence 642:
won 642 mask: 00000000.01010100 => 0x0054

##### Player won with sequence 630:
won 630 mask: 00000000.01001001 => 0x0049

##### Player won with sequence 741:
won 741 mask: 00000000.10010010 => 0x0092

##### Player won with sequence 852:
won 852 mask: 00000001.00100100 => 0x0124
