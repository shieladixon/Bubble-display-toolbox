\ 	Bubble Display scrolling message
\ 	scrolls a message input by the user
\ 	S Dixon https://peacockmedia.software
\ 
\ 	for RC2014's bubble display module 
\ 	written and tested using DXForth 4.3 for CP/M

include BUBTB

create message 	32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,		
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
				32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,				\ buffer for a message up to 256 characters

variable scroll_countdown 
variable message_len
variable message_cursor


: reset_scroll_countdown scroll_speed scroll_countdown ! ;


: message_char_at_position ( p -- c )
				message + c@
;

				
: set_message ( a n -- )
				dup message_len !
				 0 do													
					dup i + c@ 
					message i + c!
				loop
;


: message_to_buffer ( -- )		\ copies a substring of our message to the screen buffer using put_char_at_index
					8 0 do 
						\ i is 0 - 7

						message_cursor @ i + 
						dup message_len @ >= if										\ off the end?
							message_len @ - 
						then

						message_char_at_position 
						i put_char_at_index

					loop	
;


: scroll_message ( -- )
					scroll_countdown @ 1 - dup scroll_countdown !		\ dec leaving value on stack
					0 = if 
						
						message_cursor @ 1 + dup message_cursor !		\ inc leaving value on stack
						message_len @ = if
							0 message_cursor !
						then
						
						message_to_buffer 

						reset_scroll_countdown
					then
;


: escape? 		\ true if there's a key and if it's escape, else false
				key? 
					if 
					key 27 = 
						if 
							true 
						else 
							false 
							then 
					else 
						false 
					then  
;	


: initialisation ( -- )  	
	
				reset_scroll_countdown
				0 message_cursor !
				message_to_buffer	
;


: input ( -- ) 
				0														\ track our position / count chars
				begin
					key
					dup 13 <> if
						1 pick 254 < if									\ safeguard against >254 chars
							dup EMIT
							dup 2 pick message + c!						\ poke our char value into message
							swap 1 + swap								\ inc the counter
						then
					then
					13 = 
				until
				
				\ add a couple of spaces as the user probably hasn't
				32 1 pick message + c!
				32 1 pick message + c!
				2+
				
				message_len !
;


: scrollinp ( -- ) 
				initialisation
				
				cr
				." type your message... you have up to 256 characters. Choose wisely" 
				cr
				
				input
				
				cr
				." (esc to quit)" 
				cr
				
				begin 
				
					flush_display_buffer								\ main prog loop is here
			
					scroll_message										

			
					escape?
				until
;