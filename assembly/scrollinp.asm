;=========================================================
; bubble display scrolling display of input message
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

message_buffer		defs 256, $20
press_a_key			dm "Press a key...",00
type_your_message	dm "type your message... you have up to 256 characters. Choose wisely",13,10,00

message_len			defb 0
SCROLL_SPEED		equ $18



;=========================================================
; internal stuff

offset				defb 0
scroll_countdown 	defb SCROLL_SPEED



;=========================================================
; entry point

init	
					ld HL,type_your_message
					call print_str
				
					ld HL,message_buffer		; start of message, which is currently just spaces
					ld IX,message_len
waitkey				
					
					push HL
					push IX
					ld C,$01
					call 5						; Wait for a character from the keyboard; then echo it to the screen and return it.
					
					pop IX
					pop HL	
					
					cp  A,14
					;If A < N, then C flag is set.
					jr c,input_done
					
					ld(HL),A
					inc HL
					inc (IX)
					
					ld A,0						; maxed out?
					cp A,(IX)
					jr z,input_done
					
					jr waitkey
					
input_done			call eat_waiting_chars		; clear the input (we might be here after one half of a 10/13 combo)
					
				
all_clear		
					call CRLF
					call message_to_buffer


main_loop	
					call flush_display_buffer
					call scroll_message
						
						
					; key pressed?
					ld C,$0b
					call 5
					cp 0
					jp z,main_loop  ; no key down

					call eat_waiting_chars		; clear the character we just typed

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
					call z,reset_offset			; if offset == message_len, reset it
							
					call message_to_buffer
					call reset_scroll_countdown
					
					ret

					
					
message_char_at_index
					; returns (in A) the ascii character of our message at index C,

					call wrap_if_necessary
			
					ld B,0
					ld HL,message_buffer
					add HL,BC
					ld A,(HL)
					
					ret
				
				
wrap_if_necessary
					; if C > message_len, sub message_len from C. Repeat until.
					ld A,(message_len)
					dec A 	; C is a zero-based index. to compare with length, dec 1 from length
					cp C
					;If A < C, then C flag is set.
					ret nc

					ld B,A	; message length in A
					scf		; set carry, it's that length vs index thing again
					ld A,C	
					sbc A,B
					ld C,A
					jp wrap_if_necessary
				
					
reset_scroll_countdown				
					; just sets scroll_countdown back up to scroll_speed
					ld A,SCROLL_SPEED
					ld (scroll_countdown),A
					ret


reset_offset						
					; simply sets offset back to 0
					ld A,0
					ld (offset),A
					ret					
					
		
eat_waiting_chars
					ld C,$0b
					call 5				; chr waiting?
					cp 0
					ret z			  	; nope

					ld C,$01
					call 5
					jp eat_waiting_chars
					

CRLF				ld A,13
					call chrout
					ld A,10 
					call chrout


chrout
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
print_str_end		ret