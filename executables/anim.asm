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

FRAMERATE				equ $10

segmentData				defb $01,$01,$01,$01,$01,$01,$01,$01	; round in a circle
						defb $02,$02,$02,$02,$02,$02,$02,$02
						defb $04,$04,$04,$04,$04,$04,$04,$04
						defb $08,$08,$08,$08,$08,$08,$08,$08
						defb $10,$10,$10,$10,$10,$10,$10,$10
						defb $20,$20,$20,$20,$20,$20,$20,$20
						
						defb $01,$01,$01,$01,$01,$01,$01,$01	; round in a circle
						defb $02,$02,$02,$02,$02,$02,$02,$02
						defb $04,$04,$04,$04,$04,$04,$04,$04
						defb $08,$08,$08,$08,$08,$08,$08,$08
						defb $10,$10,$10,$10,$10,$10,$10,$10
						defb $20,$20,$20,$20,$20,$20,$20,$20
												
						defb $01,$01,$01,$01,$01,$01,$01,$01	; round in a circle
						defb $02,$02,$02,$02,$02,$02,$02,$02
						defb $04,$04,$04,$04,$04,$04,$04,$04
						defb $08,$08,$08,$08,$08,$08,$08,$08
						defb $10,$10,$10,$10,$10,$10,$10,$10
						defb $20,$20,$20,$20,$20,$20,$20,$20


						
						defb $01,$01,$01,$01,$01,$01,$01,$01	; snake
						defb $00,$01,$01,$01,$01,$01,$01,$03
						defb $00,$00,$01,$01,$01,$01,$01,$43
						defb $00,$00,$00,$01,$01,$01,$41,$43
						defb $00,$00,$00,$00,$01,$41,$41,$43
						defb $00,$00,$00,$00,$40,$41,$41,$43						
						defb $00,$00,$00,$40,$40,$40,$41,$43
						defb $00,$00,$40,$40,$40,$40,$40,$43
						defb $00,$40,$40,$40,$40,$40,$40,$42
						defb $40,$40,$40,$40,$40,$40,$40,$40

						defb $50,$40,$40,$40,$40,$40,$40,$00
						defb $58,$40,$40,$40,$40,$40,$00,$00
						defb $58,$48,$40,$40,$40,$00,$00,$00
						defb $58,$48,$48,$40,$00,$00,$00,$00
						defb $58,$48,$48,$08,$00,$00,$00,$00
						defb $58,$48,$08,$08,$08,$00,$00,$00
						defb $58,$08,$08,$08,$08,$08,$00,$00
						defb $18,$08,$08,$08,$08,$08,$08,$00
						defb $08,$08,$08,$08,$08,$08,$08,$08
						
						defb $00,$08,$08,$08,$08,$08,$08,$0C
						defb $00,$00,$08,$08,$08,$08,$08,$0E
						defb $00,$00,$00,$08,$08,$08,$08,$0F
						defb $00,$00,$00,$00,$08,$08,$09,$0F
						defb $00,$00,$00,$00,$00,$09,$09,$0F
						defb $00,$00,$00,$00,$01,$01,$09,$0F
						defb $00,$00,$00,$01,$01,$01,$01,$0F
						defb $00,$00,$01,$01,$01,$01,$01,$07
						defb $00,$01,$01,$01,$01,$01,$01,$03
						defb $01,$01,$01,$01,$01,$01,$01,$01
						
						defb $01,$01,$01,$01,$01,$01,$01,$00	; shrink
						defb $01,$01,$01,$01,$01,$01,$00,$00
						defb $01,$01,$01,$01,$01,$00,$00,$00
						defb $01,$01,$01,$01,$00,$00,$00,$00
						defb $01,$01,$01,$00,$00,$00,$00,$00
						defb $01,$01,$00,$00,$00,$00,$00,$00
						defb $01,$00,$00,$00,$00,$00,$00,$00
						
						defb $20,$00,$00,$00,$00,$00,$00,$00	; weave
						defb $10,$00,$00,$00,$00,$00,$00,$00
						defb $08,$00,$00,$00,$00,$00,$00,$00
						defb $04,$00,$00,$00,$00,$00,$00,$00
						defb $02,$00,$00,$00,$00,$00,$00,$00
						
						defb $00,$01,$00,$00,$00,$00,$00,$00
						
						defb $00,$00,$20,$00,$00,$00,$00,$00
						defb $00,$00,$10,$00,$00,$00,$00,$00
						defb $00,$00,$08,$00,$00,$00,$00,$00
						defb $00,$00,$04,$00,$00,$00,$00,$00
						defb $00,$00,$02,$00,$00,$00,$00,$00
						
						defb $00,$00,$00,$01,$00,$00,$00,$00
						
						defb $00,$00,$00,$00,$20,$00,$00,$00
						defb $00,$00,$00,$00,$10,$00,$00,$00
						defb $00,$00,$00,$00,$08,$00,$00,$00
						defb $00,$00,$00,$00,$04,$00,$00,$00
						defb $00,$00,$00,$00,$02,$00,$00,$00
						
						defb $00,$00,$00,$00,$00,$01,$00,$00
						
						defb $00,$00,$00,$00,$00,$00,$20,$00
						defb $00,$00,$00,$00,$00,$00,$10,$00
						defb $00,$00,$00,$00,$00,$00,$08,$00
						defb $00,$00,$00,$00,$00,$00,$04,$00
						defb $00,$00,$00,$00,$00,$00,$02,$00
						
						defb $00,$00,$00,$00,$00,$00,$00,$01
						
						defb $00,$00,$00,$00,$00,$00,$01,$01	; grow
						defb $00,$00,$00,$00,$00,$00,$01,$01
						defb $00,$00,$00,$00,$00,$01,$01,$01
						defb $00,$00,$00,$00,$01,$01,$01,$01
						defb $00,$00,$00,$01,$01,$01,$01,$01
						defb $00,$00,$01,$01,$01,$01,$01,$01
						defb $00,$01,$01,$01,$01,$01,$01,$01
						
						defb $01,$01,$01,$01,$01,$01,$01,$01	; flash
						defb $00,$00,$00,$00,$00,$00,$00,$00
						defb $01,$01,$01,$01,$01,$01,$01,$01
						defb $00,$00,$00,$00,$00,$00,$00,$00
						defb $01,$01,$01,$01,$01,$01,$01,$01
						
						
DATA_LENGTH_FRAMES		equ 90



;=========================================================
; internal variables

frame_cursor			defb 00
scroll_countdown		defb 00



;=========================================================
; entry point

init			
				
					call clear_buffer
					call load_frame
					call reset_scroll_countdown


main_loop									
					call advance_frame				; contains a divider. 

					call flush_display_buffer
						
						
						
					; key pressed?
					ld C,$0b
					call 5
					cp 0
					jp z,main_loop  ; no key down

					;tidy up
					call clear_buffer
					call flush_display_buffer
					ret
				

					
;=========================================================
; animation stuff	

load_frame

					ld HL,segmentData
					ld BC,(frame_cursor)
					; multiply by 8
					sla C
					rl B
					sla C
					rl B
					sla C
					rl B
					
					add HL,BC
					
					; BC is free
					ld C,0	; loop 0-7

lf_lp				ld A,(HL)
					push HL
					push BC
						call put_raw_segment_data_at_index ; (your character (ascii) in A and position (0-7) in C )
					pop BC
					pop HL
					
					inc HL
					inc C
					ld A,8
					cp C
					jr nz,lf_lp

					ret


advance_frame
					; simply increases the data cursor and re-copies data to buffer. 
					; so that we can simply call this as often as the flushing the display
					; it has a divider, a simple countdown

 					ld HL,scroll_countdown
					dec (HL)
					ret nz

					
					ld A,(frame_cursor)
					inc A
					ld (frame_cursor),A

					ld B,DATA_LENGTH_FRAMES
					cp B
					
										
					call z,reset_cursor	; if offset == message_len, reset it
							
					call load_frame
					call reset_scroll_countdown
					
					ret


reset_scroll_countdown
					ld A,FRAMERATE
					ld (scroll_countdown),A
					ret

					
reset_cursor
					ld A,0
					ld (frame_cursor),A
					ret
					

					
;=========================================================
; general useful stuff	

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