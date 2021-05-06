;=========================================================
; bubble display animation demo
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

table 				defb 0,1,2,4,6,9,12,15,20,24,32,48,64,96,128,192,255,255
					defb 255,192,128,96,64,48,32,24,20,15,12,9,6,4,2,1,0
					; this table isn't calculated, just cobbled together by guesswork.
					; needs to be logarithmic, changes slowly at first, quickly later.
TABLELENGTH			equ 35	
pointer				defb 0
FRAMERATE			equ $08						; use to tweak the rate of the animation




;=========================================================
; internal variables

scroll_countdown 	defb FRAMERATE		



;=========================================================
; entry point

init							
					ld HL,on_time
					ld A,$80
					ld (HL),A
					ld HL,off_time
					ld A,$80
					ld (HL),A	


					ld C,0
populate			ld A,$30					; ascii zero

					push BC
					call put_char_at_index		; character (ascii) in A and position (0-7) in C )
					pop BC
					inc C
					ld A,8
					cp C
					jr nz,populate
				

main_loop									
					; do stuff

					call handle_animation
					
					call flush_display_buffer
					
					
					
						
					; key pressed?
					ld C,$0b
					call 5
					cp 0
					jp z,main_loop  			; no key down

					;tidy up
					call clear_buffer
					call flush_display_buffer
					ret


handle_animation			
			
 					ld HL,scroll_countdown		; divider
					dec (HL)
					ret nz					

					ld HL,pointer
					inc (HL)
					ld C,(HL)
					ld A,TABLELENGTH
					cp C
					call z,reset_pointer 

					ld C,(HL)
					ld B,0
					ld HL,table
					add HL,BC
					ld A,(HL)
					ld HL,on_time
					ld (HL),A

					ld B,A
					ld A,255
					sbc A,B
					ld HL,off_time
					ld (HL),A		

					call reset_scroll_countdown
					ret	

			
reset_pointer		
					ld HL,pointer
					ld A,0
					ld(HL),A
					ret
							
			
reset_scroll_countdown
					ld A,FRAMERATE
					ld (scroll_countdown),A
					ret			
			

;=========================================================
; general useful stuff	
		
eat_waiting_chars
					ld C,$0b
					call 5					; chr waiting?
					cp 0
					ret z			  		; nope

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