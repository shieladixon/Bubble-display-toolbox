\ 	Bubble Display toolbox
\ 	S Dixon https://peacockmedia.software
\ 
\ 	for RC2014's bubble display module 
\ 	This version adjusted and tested on Minstrel the Forth (Jupiter Ace)


00 constant digit_select_port
02 constant segment_port

02 constant on_time		\ amount of time each digit is displayed during the flush
8 constant scroll_speed 	\ higher = slower



create font  	0 c,		\ space
				128 c,		\ dp

				63 c, 6 c, 91 c, 79 c, 102 c, 				\ digits, 0 - 9
				109 c, 125 c, 7 c, 127 c, 111 c,
				
				95 c, 124 c, 57 c, 94 c, 121 c, 			\ a/A - z/Z
				113 c, 111 c, 116 c, 48 c, 30 c, 			\ -j
				117 c, 56 c, 21 c, 55 c, 63 c, 				\ -o
				115 c, 103 c, 49 c, 109 c, 120 c,			\ -t
				62 c, 62 c, 42 c, 118 c, 110 c, 91 c, 		\ -z

				64 c, 83 c,	2 c,							\ a few symbols;  - ? '
				
				
				
\ config above this line, internal stuff below
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 
 
create display_buffer	0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 	\ default 8 spaces



\ DX-Forth doesn't have a 'raise to the power' word for regular signed numbers, or >=

create twos 1 c, 2 c, 4 c, 8 c, 16 c, 32 c, 64 c, 128 c, 

: power2 ( y -- r )  								\ x to the power of y, useful for selecting bits
				twos + c@		 
; 

: >= ( n1 n2 -- f )
				1 - >
;



: selectDigit ( n -- ) 
				digit_select_port out
;

: sendData ( n -- ) 
				segment_port out
;

: sendChar ( n -- )
				font + c@ sendData
;

: ascii_to_screen_code ( n -- n )

									
				dup 45 = if			\ couple special chars. put after Z. This is dash
					78 +
				then

				dup 63 = if			\ ?
					61 +
				then

				dup 39 = if			\ '
					86 +
				then
				
				dup 44 = if			\ ,  make it a dp
					2 +
				then
				
				dup 96 > if
					32 -			\ 97 -> becomes 65 ->, making all alpha chars uppercase
				then
	
				dup 64 > if
					7 -				\ 65 -> becomes 58 ->, putting alpha chars directly above numbers
				then		
	
				dup 46 = if
					1 +				\ special case, put dp immediately below numbers (make 47)
				then
		
				dup 32 = if
					14 +			\ special case, put space below dp (make 46)
				then
	
									\ everything now starts at 47; spc, dp, numbers, alpha
				46 -
				
				dup 40 > if
					dup -			\ make zero
				then
				
				dup 0 < if
					drop 0			\ make zero
				then
				
;


: sendScreenCodeToDigit ( c d -- )	
				2 swap power2		\ convert digit from 0-7 to 1-128. 2 to the power of what is sent		
				selectDigit
			
				sendChar
;


: pause begin 1 - dup 0= until drop ;



\ low-level stuff above this line, high-level stuff below
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\				

	
: flush_display_buffer
				8 0 do 
					\ i is 0 - 7 

					display_buffer i + c@										\ get screencode from buffer at pos i
					i 															\ our digit #
		
					sendScreenCodeToDigit

					on_time pause												\ short delay while this row on 
			
					0 i sendScreenCodeToDigit									\ send space - reduces ghosting when scrolling
																				
				loop
;
		
		
: put_char_at_index ( c i -- ) 										\ char means ascii, converted to screen code for display buffer
																	\ index 0-7
				swap ascii_to_screen_code swap
				display_buffer + c!		
;
		
