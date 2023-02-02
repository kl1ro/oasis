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
; 	cl is a row position
;	ch is a colomn
;
_printChar:
	;
	; If style is black on black
	; we give it our default style
	; which is gray on black
	;
	test ah, ah
	jnz _defaultCharacterStyleAfter

_defaultCharacterStyle:
        mov ah, 0x07

_defaultCharacterStyleAfter:

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
	; Note: we need to define that bx is
	; an offset from start of the video 
	; memory
	;
	cmp ch, 0
	jl _getCursor
	cmp cl, 0
	jl _getCursor
	
	;
	; Save ax reg from being overwritten
	;	
	mov dx, ax
	call _getVideoMemoryOffset	
	mov bx, ax
	
	;
	; And restore it
	; 
	mov ax, dx

_getCursorAfter:
	;
	; If we see a newline character, set 
	; offset to the end of current row, so 
	; it will be advanced to the first col
	; of the next row.
	; 
	cmp cl, 10
	jne _elseNewLineCharacter 

_ifNewLineCharacter:
	; 
	; Note: shr 1 (But this is efficient) = div 2
	;
	shr bx, 1
	
	;
	; We have to save our ax register
        ; because for some reason div instruction
        ; can divide only rax. So si register will
        ; serve as a buffer.
	;
	mov si, ax
	mov ax, bx
	div MAX_COLS
	mov cx, ax
	mov ax, si
	mov ch, 79
	jmp _getScreenOffset	

_elseNewLineCharacter:
	;
	; Otherwise we just write the character 
	; to the video memory at our calculated 
	; offset
	; 
	mov byte [VIDEO_ADDRESS + bx], al
	mov byte [VIDEO_ADDRESS + bx + 1], ah

_newLineCharacterAfter:
	;
	; Update the offset to the next character cell, which is
	; two bytes ahead of the current cell .
	;	
	add bx, 10b
	call _handleScrolling
	jmp _setCursor
	
;
; Then we need to specify the functions 
; we already used in _printChar. First
; let's see how _getVideoMemoryOffset
; works.
;
; Input:
;	cl = row position
; 	ch = colomn position
; Output:
;	ax = offset from the video 
; 	memory to the character
_getVideoMemoryOffset:
	xor ax, ax
	mov al, cl
	mul al, MAX_COLS
	add al, ch
	; i.e. multiplication by two
	shl ax, 1
	ret

;
; We also used _getCursor
; Let's implement it too
; 
; Input:
; 	nothing at all
; Output:
;	ax is an offset of the cursor
; 	being on the screen right now
;
_getCursor:
	;
	; First things first we need to 
	; select device internal register
	; that we are interested in via
	; putting the number of that 
	; register to the device port
	;
	mov dx, REG_SCREEN_CTRL	
	mov al, 14
	out dx, al
	
	;
	; Then read high byte of the 
	; cursor offset to the ah register
	; from the device 
	;
	mov dx, REG_SCREEN_DATA	
	in al, dx
	mov al, ah		
	
	;
	; Then again select internal register	
	;
	mov dx, REG_SCREEN_CTRL
	mov al, 15
	out dx, al

	;
	; And read low byte of the 
	; offset to the al register
	;
	mov dx, REG_SCREEN_DATA
	in al, dx
	
	;
	; And at last we multiply this 
	; offset by two
	;
	shl ax, 1
	ret	
	
