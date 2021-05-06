;=========================================================
; bubble display scrolling Hello World 
; S Dixon https://peacockmedia.software

; for RC2014's bubble display module and CP/M
; use zasm to build

;=========================================================

#target BIN
#code PAGE1,$100

					jp init			; jump to entry point
					
#include "bubtb.asm"



;=========================================================
; config here

hello_world			dm "hello world, I am RC2014. ",00
message_len			defb 26
SCROLL_SPEED		equ $18



;=========================================================
; internal stuff

offset				defb 0
scroll_countdown 	defb SCROLL_SPEED



;=========================================================
; entry point

init	
					call message_to_buffer


main_loop
						
					call flush_display_buffer
					call scroll_message
						
						
					; key pressed?
					ld C,$0b
					call 5
					cp 0
					jp z,main_loop  ; no key down


					;tidy up
					call clear_buffer
					call flush_display_buffer
					
					ret
		
				

;=======================================================================
; scrolling stuff. basically copies our message into the display buffer, 
; starting at an offset, and if necessary, wrapping at the end of the message
	
	
message_to_buffer				

					ld C,0						; loop 0-7

mtb_lp2				push BC
					
					ld HL,offset
					ld A,C
					add a,(HL)
					ld C,A

					
					call message_char_at_index 	; affects BC,HL

					pop BC 
					push BC
					call put_char_at_index 		; char in A, position in C


					pop BC
					inc C
					ld A,8
					cp A,C
					jp nz,mtb_lp2
					ret


scroll_message
					; simply increases the offset and re-copies message to buffer. 
					; so that we can simply call this as often as the flushing the display
					; it has a counter, 

					ld HL,scroll_countdown
					dec (HL)
					ret nz
					
					ld HL,message_len
					ld B,(HL)
					
					ld HL,offset
					inc (HL)
					ld A,(HL)
					
					cp B					
					call z,reset_offset	; if offset == message_len, reset it
							
					call message_to_buffer
					call reset_scroll_countdown
					
					ret
					
					
message_char_at_index
					; returns (in A) the ascii character of our message at index C,
					
					;  wrapping is done here, if C > message_len, sub message_len from C. If message wraps more than once, tough.
					ld A,(message_len)
					dec A 	; C is a zero-based index. to compare with length, dec 1 from length
					cp C
					;If A < C, then C flag is set.
					call c,sub_message_len_from_C		; it'll only wrap once. If message is very short, tough.
			
					ld B,0
					ld HL,hello_world
					add HL,BC
					ld A,(HL)
					
					ret
				
				
sub_message_len_from_C
					ld B,A	; message length in A
					scf		; set carry, it's that length vs index thing again
					ld A,C	
					sbc A,B
					ld C,A
					ret
				
					
reset_scroll_countdown
					ld A,SCROLL_SPEED
					ld (scroll_countdown),A
					ret


reset_offset	
					ld A,0
					ld (offset),A
					ret					
					
chrout
					; affects C & E
					ld E,A
					ld C,02
					call 5
					ret


print_str
					ld A,(HL)
					cp 00
					jr z,print_str_end
					push HL
					call chrout
					pop HL
					inc HL
					jp print_str
print_str_end
					ret