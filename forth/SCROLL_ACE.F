\ 	Bubble Display scrolling message
\ 	scrolls a message input by the user
\ 	S Dixon https://peacockmedia.software
\ 
\ 	for RC2014's bubble display module 
\ 	This version adjusted and tested on Minstrel the Forth (Jupiter Ace)

include BUBTB

create msg 	74 c, 85 c, 80 c, 73 c, 84 c, 69 c, 82 c, 32 c,		
				65 c, 67 c, 69 c, 32 c, 73 c, 83 c, 32 c, 65 c,
				67 c, 69 c, 32 c, 32 c, 32 c, 32 c, 32 c, 32 c,
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

0 variable scrll_cdn 
13 variable msg_len
0 variable msg_csr


: rst_scrll_cdn scroll_speed scrll_cdn ! ;


: msg_c_at_pos ( p -- c )
				msg + c@
;


: msg_to_buffer ( -- )		\ copies a substring of our message to the screen buffer using put_char_at_index
					8 0 do 
						\ i is 0 - 7

						msg_csr @ i + 
						dup msg_len @ >= if										\ off the end?
							msg_len @ - 
						then

						msg_c_at_pos 
						i put_char_at_index

					loop	
;


: scrll_msg ( -- )
					scrll_cdn @ 1 - dup scrll_cdn !		\ dec leaving value on stack
					0 = if 
						
						msg_csr @ 1 + dup msg_csr !		\ inc leaving value on stack
						msg_len @ = if
							0 msg_csr !
						then
						
						msg_to_buffer 

						rst_scrll_cdn
					then
;



: init ( -- )  	
	
				rst_scrll_cdn
				0 msg_csr !
				msg_to_buffer	
;





: scroll ( -- ) 
				init
				
				begin 
				
					flush_display_buffer								\ main prog loop is here
			
					scrll_msg										

					0
				until
;