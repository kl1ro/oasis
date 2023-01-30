;
; Let's define some constants in order to
; simplify our code
;
VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
GRAY_ON_BLACK equ 0x07

; Screen device 1/0 ports
REG_SCREEN_CTRL equ 0x3d4
REG_SCREEN_DATA equ 0x3d5

;
; Prints a char to the screen 
; at the specific row and colomn position
;
; Input: 
;	al is a ascii code of the character
; 	ah is a style of the character
; 	ch is a row position
;	cl is a colomn
;
_printChar:
	;
	; If style is black on black
	; we give it our default style
	; which is gray on black
	;
	test ah, ah
	gz _defaultCharacterStyle
	
	;
	; Then we need to calculate memory
	; position to put our character to
	;
	; Firstly we check if row and colomn 
	; are positive. If they're not we 
	; gotta get our cursor position and 
	; write the character after that. Well,
	; if they are then we need to specify
	; the offset in memory.
	;
	; Note: we need to define that bl is
	; an offset from start of the video 
	; memory
	;
	cmp ch, 0
	jl _getCursor
	cmp cl, 0
	jl _getCursor
	jmp _getVideoMemoryOffset

_defaultCharacterStyle:
	mov ah, 0x07
	ret
