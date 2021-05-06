;=========================================================
; bubble display toolbox
; S Dixon https://peacockmedia.software

; for RC2014's bubble display module and CP/M
; use zasm to build

;=========================================================
; usage
;
; bubble display toolbox creates a 'screen buffer' corresponding 
; with the 8 digits of the bubble display. 
; and contains a 'font' 
; 
;
; high-level use: 
; ===============
;
; to send an ascii character to the buffer: call put_char_at_index
; (your character (ascii) in A and position (0-7) in C )
; (for efficiency, ascii is converted to a 'screen code' before storing in the buffer
; this corresponds with the position of the raw segment data in our 'font')		; TODO: store raw data in the buffer?
;
; 'flushing' sends the buffer to the display
; call flush_display_buffer  as often as possible 
; The 'on time' delay for each digit is built in
;
; to clear the display: call clear_buffer and then flush 
;
;
; low-level use: 
; ===============
;
; 
; to send data directly to the bubble display,
;
; call sendSegmentDataToDigit 
; digit (0-7) in A, Segment data in C
;
;
; or to get even dirtier:

; first call selectDigit with digit (1-128) in A 
; (call two_to_power to convert 0-7 to 1-128)
;
; then call sendData with digit segments in A
; segments a,b,c,d,e,f,g,dp represented by 1,2,4,8,16,32,
;
;
; note that when using these low-level calls, 
; only one digit can be on at a time 
; (or multiple digits if you're sending the same segment data to all)	
; so fast looping is required to give the illusion 
; of all digits being on at the same time
;			
;
;


DIGIT_SELECT_PORT	equ 00		
SEGMENT_PORT		equ 02

on_time				defw $0020
off_time			defw $00E0						; usually just use on_time
													; but off_time can be used to dim the digits (duty cycle)
													; make off_time and on_time add up to the default value of on_time


font
					defb 0		; space
					defb 128	; dp

					defb 63,6,91,79,102 			; digits, 0 - 9
					defb 109,125,7,127,111
					defb 95,124,57,94,121 			; a/A - z/Z
					defb 113,111,116,48,30 			; -j
					defb 117,56,21,55,63 			; -o
					defb 115,103,49,109,120			; -t
					defb 62,62,42,118,110,91 		; -z

					defb 64,83,2 					; a few symbols;  - ? '



;=========================================================
; config above this line, internal stuff below
			

display_buffer 		defs 8, $00 					; 8 x spaces



;=========================================================
; 'API', higher level


flush_display_buffer
	
					; the job of this routine is to loop through the 8 bytes in the display buffer
					; and send each in turn to the appropriate digit on the display and pause for the 'on time' 
					; optionally switch off the digit for 'off time'
					
					ld A,1							; loop 1-8
					ld HL,display_buffer

fdb_lp				ld C,(HL)
					push AF
					push HL
					call sendSegmentDataToDigit		; digit in A, segment data in C
					ld BC, (on_time) 
					call pause

					ld BC,(off_time)
					ld A,B
					or A,C
					jr z,fdb_skip_offtime
					pop HL
					pop AF
					push AF
					push HL
					ld C,0
					call sendSegmentDataToDigit		; digit in A, segment data in C
					ld BC, (off_time) 
					call pause
fdb_skip_offtime	pop HL
					pop AF					

					inc HL
					inc A
					cp A,9
					jp nz,fdb_lp

					ret
					
						
put_char_at_index	
					; puts char into screen buffer
					; char (ascii) in A, position in C
					push BC
					call segment_data_from_ascii 	; A -- A
					pop BC
					
					call put_raw_segment_data_at_index
					
					ret


put_raw_segment_data_at_index	
					; puts char into screen buffer
					; segment data in A, position in C
					
					ld HL,display_buffer
					ld B,0
					add HL,BC
					ld (HL),A
					
					ret



;=========================================================
; 'API', lower level

	
selectDigit			; digit (1-128) in A
					; to convert digit index 0-7, first call two_to_power
					out(DIGIT_SELECT_PORT),A
					ret	
					
					
sendData			; digit segments in A
					out(SEGMENT_PORT),A
					ret			
	

					
sendSegmentDataToDigit	
					; digit (0-7) in A, Segment data in C
					
					push BC				; preserve C
					call two_to_power	; convert digit from 0-7 to 1-128. 2 to the power of what is sent
					
										; good practice would be to send a 0 to the data port here
										; because when we select the new digit it may temporarily show
										; the previous data in the new selected digit.
										; in practice, with assembly, the new data will be sent so quickly
										; that it's not an issue
					

					call selectDigit
					pop BC
					ld A,C
					call sendData
					ret
					
				
				
				
segment_data_from_ascii ; A -- A
					call ascii_to_font_index 

					ld C,A
					ld HL,font
					ld B,0
					add HL,BC
					ld A,(HL)
				
					ret



;=========================================================
; general useful stuff


two_to_power		; 2 to the power of A, useful for selecting bits
					ld B,A
					ld A,0
					scf 							; make A=0 and carry 1

ttp_lp				rla
					djnz ttp_lp
					
					ret
					
										
clear_buffer		ld B,8
					ld HL,display_buffer

cb_lp				ld A,0							; our code for a space
					ld (HL),A
					inc HL
					djnz cb_lp


pause				
					; pause length in BC
					; return                 
					ld A, B               
					or C                   
					ret z
					dec BC 
					jr pause
          
												
ascii_to_font_index
					; char (ascii) in A
		
					; the job of this routine is to convert an ascii value
					; to the index of the character in our 'font'
					; which goes: space, dot, 0-9, a-z and a few symbols: - ? '
					  
					cp A,45
					jr nz,not45
					; couple special chars. put after Z. This is dash
					; +78
					add a,78			

not45				cp A,63
					jr nz,not63
					; ?
					add a,61			

not63				cp A,39
					jr nz,not39
					; '
					add a,86			

not39				cp A,44
					jr nz,not44
					; ,  make it a dp
					add a,2			
					
not44				cp A,97
					; 97 -> becomes 65 ->, making all alpha chars uppercase
					;If A < N, then C flag is set.
					;If A >= N, then C flag is reset.
					jr c,notuc
					or A		; clc
					sbc A,32
				
notuc				cp A,65
					; 65 -> becomes 58 ->, putting alpha chars directly above numbers
					;If A < N, then C flag is set.
					;If A >= N, then C flag is reset.
					jr c,notlc
					or A		; clc
					sbc A,7
				
notlc				cp A,46
					jr nz,not46
					; special case, put dp immediately below numbers (make 47)
					inc A	
					
not46				cp A,32
					jr nz,not32
					; special case, put space below dp (make 46)
					add a,14
					
not32				; everything now starts at 47; spc, dp, numbers, alpha
					or A		; clc
					sbc A,46

					ret