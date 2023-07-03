;
; Let's define some constants in order to
; simplify our code
;
;
; And let's make it clear:
; The screen starts from 0xb8000
; and ends at 0xb8f9f
;
VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
GRAY_ON_BLACK equ 0x07

; Screen device I/O ports
REG_SCREEN_CTRL equ 0x3d4
REG_SCREEN_DATA equ 0x3d5

;
; Prints a string to the screen 
; at the specific row and colomn position
;
; Input: 
;	- rsi is a pointer to the string
;
; 	- ah is a style of the character
;
; 	- cl is a row position
;
;	- ch is a colomn
;
; Output:
;       - rax is modified
;
;       - rbx equals to offset to the
;         place after the last character
;         of the string on the screen
;
;       - cx equals to 0
;
;       - rdx is modified
;
;       - rsi point to the end of the string
;
;       - rdi is modified
;
;       - r8 is modified
;
;		- r9 is modified
;
_printAt:
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
		; position to put our first character to
		;
		; Firstly we check if row and colomn 
		; are positive. If they're not we 
		; gotta get our cursor position and 
		; write the character after that. Well,
		; if they are then we need to specify
		; the offset in memory.
		;
		; Note: we need to define that rbx is
		; an offset from start of the video 
		; memory
		;
		; Save ax from being overwritten
		; r8w is a buffer
		;
		mov r8w, ax
		
		;
		; Clear rbx because we use entire
		; register but mov only to a part of
		; this register and that cause the 
		; problems for us
		;
		xor rbx, rbx	

		cmp ch, 0
		jl _ifGetCursor
		cmp cl, 0
		jl _ifGetCursor
		
		call _getVideomemoryOffset
		jmp _getCursorAfter	

		_ifGetCursor:
			call _getCursor

		_getCursorAfter:
			; 
			; Restore ax    
			;       
			mov bx, ax
			mov ax, r8w

	;
	; Note: this is the cycle start
	;
	_writeCharacterCycle:
		;
		; If we see a newline character, set 
		; offset to the end of current row, so 
		; it will be advanced to the first col
		; of the next row.
		;
		mov al, [rsi]
		test al, al
		jz _break
		cmp al, 10
		jne _elseNewLineCharacter 

		_ifNewLineCharacter:	
			;
			; We have to save our ax register
			; because for some reason div instruction
			; can divide only rax. So r8w register will
			; serve as a buffer.
			;
			mov r8w, ax
			mov ax, bx
			mov rdi, MAX_COLS * 2
			xor dx, dx
			div di
			sub rdi, 10b
			sub di, dx
			add rbx, rdi
			
			;
			; Restore ax
			;
			mov ax, r8w	
			jmp _newLineCharacterAfter

		_elseNewLineCharacter:
			;
			; Otherwise we just write the character 
			; to the video memory at our calculated 
			; offset
			;
			mov [rbx + VIDEO_ADDRESS], ax
	
		_newLineCharacterAfter:
			;
			; Update the offset to the next character cell, which is
			; two bytes ahead of the current cell.
			;	
			add rbx, 10b
			inc rsi
			mov r9, rsi
			call _handleScrolling
			mov rsi, r9
			mov r8, rbx
			call _setCursor	
			mov rbx, r8
			jmp _writeCharacterCycle
	
;
; Then we need to specify the functions 
; we already used in _print. First
; let's see how _getVideoMemoryOffset
; works.
;
; Input:
;	- cl = row position
;
; 	- ch = colomn position
;
; Output:
;	- ax = offset from the video 
; 	memory to the character
;
;	- di equals to maximum colomns
; 	on the screen
;
;	- cl equals to the colomn position
;	from the videomemory
;
;	- dx equals to 0
;
_getVideomemoryOffset:
	xor ax, ax
	mov al, cl
	mov di, MAX_COLS
	mul di
	shr cx, 8
	add ax, cx

	;
	; i.e. multiplication by two
	;
	shl ax, 1
	ret

;
; We also used _getCursor
; Let's implement it too
; 
; Input:
; 	- nothing at all
;
; Output:
;	- ax equals to the offset from video memory
;
;	- dx equals to screen data register port number
;
_getCursor:
	;
	; First things first we need to 
	; select device internal register
	; that we are interested in via
	; putting the number of that 
	; register to the device port
	;
	mov al, 14
	mov dx, REG_SCREEN_CTRL
	out dx, al
	
	;
	; Then read high byte of the 
	; cursor offset to the ah register
	; from the device 
	;		
	mov dx, REG_SCREEN_DATA
	in al, dx
	mov ah, al		
	
	;
	; Then again select internal register	
	;
	mov al, 15
	mov dx, REG_SCREEN_CTRL
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

;
; There're situations in which we
; need to also set a cursor. So let's
; implement it
;
; Input:
;	- bx is offset (it needs to be even)
;
; Output:
;	- al equals to low byte of bx
;
;	- bx equals to offset / 2
;
;	- dx equals to the screen data register port number
;
_setCursor:
	;
	; This is similar to the _getCursor	
	; but we write to those internal
	; device registers
	;
	
	;
	; Prepare address
	;
	shr bx, 1
	
	mov al, 14
    mov dx, REG_SCREEN_CTRL
    out dx, al

    mov al, bh
    mov dx, REG_SCREEN_DATA
    out dx, al

    mov al, 15
    mov dx, REG_SCREEN_CTRL
    out dx, al

    mov al, bl
    mov dx, REG_SCREEN_DATA
    out dx, al	
    ret

;
; Usually we need to print a whole string
; to a position of the cursor on the screen
;
; Input:
;	- rsi as a pointer to string
;
;	- ah is characters style
;
; Output: 
;	- ah remains the same
;
;	- al equals to 0
;
;	- rbx equals to offset to the
;	place after the last character
;	of the string on the screen
;
;	- cx equals to 0
;
;	- dx equals to screen data register port number
;
;	- rsi point to the end of the string
;
;	- rdi is modified
;
;	- r8 equals to rbx
;
;	- r9 equals to rsi
;
_print:
	mov ch, -1
	call _printAt
	ret

;
; Another useful but not too complicated
; function is a _clearScreen that puts
; space character at each position of the 
; screen
;
; Input: 
; 	- nothing
;
; Output:
;	- rax is modified
;
;	- rbx equals to 0
;
;	- dx equals to screen data register port number
;
;	- rcx equals to 0
;
_clearScreen:
	;
	; This 64-bit number represents 4
	; standard style space characters	
	;
	mov rax, 0x0720072007200720
	mov rbx, VIDEO_ADDRESS
	mov rcx, MAX_COLS * MAX_ROWS / 4
	
	_clearScreenCycle:
		mov [rbx], rax
		add rbx, 8
		loop _clearScreenCycle
		xor rbx, rbx
		call _setCursor
		ret

;
; In order to keep our screen from 
; overflowing we need to handle scrolling
;
; Input:
;	- rbx is the cursor offset
;
; Output:
;	- rax is modified
;
;	- rbx remains the same if it is not equal to 0xfa0 else it equals 0xf00
;
;	- rcx equals to 0 if rbx = 0xfa0
;
;	- rsi points to the last string on the screen
;
;	- rdi points to the last string + 1 on the screen
;
; Note: hardcoded values can be used
; only for this resolution (80 * 25)
;
_handleScrolling:
	;
	; If the cursor is within the
	; screen we getting out
	;
	cmp rbx, (MAX_COLS * MAX_ROWS) * 2
	jne _break

	mov rsi, VIDEO_ADDRESS + MAX_COLS * 2 		 		; Which is the second string
	mov rdi, VIDEO_ADDRESS								; i.e. the first string
	mov rcx, MAX_COLS * MAX_ROWS / 4
	call _memcpyq

	sub rbx, MAX_COLS * 2
	ret

;
; For the keyboard interrupt [BACKSPACE]
; we need to write a function that 
; pushes the cursor to the previous character
; and clears it
;
; Input:
;	- nothing at all
;
; Output:
; 	- ax is modified
;
;	- bx is modified
;
;	- dx equals to the screen data register port number
;
; 	- di equals to maximum colomns of the screen * 2
;
_backspace:
	xor rbx, rbx
	xor rax, rax
	call _getCursor
	cmp ax, 2
	jl _break

	xor dx, dx
	sub ax, 2
	mov bx, ax
	mov di, MAX_COLS	
	shl di, 1
	div di
	cmp dx, MAX_COLS * 2 - 2
	je _backspacePrevLineIf
	
	_backspacePrevLineElse:
		mov al, 32	
		mov [VIDEO_ADDRESS + rbx], al
		call _setCursor
		ret

	_backspacePrevLineIf:
		mov al, [VIDEO_ADDRESS + rbx]
		cmp al, 32
		jne _backspacePrevLineElse

		_backspaceCycle:
			mov al, [VIDEO_ADDRESS + rbx]
			cmp al, 32
			jne _backspaceCycleAfter
			sub bx, 2
			jmp _backspaceCycle

		_backspaceCycleAfter:
			add rbx, 2
			call _setCursor
			ret

;
; This function increments the current
; cursor position by one.
; 
; Input:
;	- nothing
;
; Output:
;       If it was not the last character of
;       the string then:
;
;               - al equals to low byte of bx
;
;               - bx equals to offset / 2
;
;               - dx equals to the screen data register port number
;
;               - di equals to MAX_COLS * 2
;
;       Else:
;
;		- ax equals to the cursor offset
;               
;               - dx equals to MAX_COLS * 2 - 2
;
;               - di equals to MAX_COLS * 2
;
;               - bx equals to the cursor offset
;
_cursorGoRight:
	call _getCursor
	xor dx, dx
	mov di, MAX_COLS * 2
	mov bx, ax
	div di
	cmp dx, MAX_COLS * 2 - 2
	je _break
	add bx, 2
	call _setCursor
	ret


;
; This function decrements the current
; cursor position by one.
; 
; Input:
;       - nothing
;
; Output:
;	If it was not the first character of
; 	the string then:
;
;      		- al equals to low byte of bx
;
;	      	- bx equals to offset / 2
;
;       	- dx equals to the screen data register port number
;
;		- di equals to MAX_COLS * 2
;
;	Else:
;
;		- ax equals to the cursor offset
;				
;		- dx equals to 0
;
;		- di equals to MAX_COLS * 2
;
;		- bx equals to the cursor offset
;
_cursorGoLeft:
	call _getCursor
	xor dx, dx
	mov di, MAX_COLS * 2
	mov bx, ax
	div di
	test dx, dx
	jz _break
	sub bx, 2
	call _setCursor
	ret

;
; This function puts the cursor up by one
;
; Input:
; 	- nothing
;
; Output:
;	If it was not the first string
;	of the screen then:
;	       	
;		- al equals to low byte of bx
;
;       	- bx equals to offset / 2
;
;     	  	- dx equals to the screen data register port number
;
;		- di is equal to MAX_COLS * 2
;
;	Else:
;
;	       	- ax equals to the offset from video memory
;
;       	- dx equals to screen data register port number
;
;		- bx is modified
;
;               - di is equal to MAX_COLS * 2		
;
_cursorGoUp:
	call _getCursor
	mov bx, ax
	mov di, MAX_COLS * 2
	sub bx, di
	test bx, bx
	jns _setCursor
	ret

;
; This function puts the cursor down by one
;
; Input:
;       - nothing
;
; Output:
;       If it was not the last string
;       of the screen then:
;               
;               - al equals to low byte of bx
;
;               - bx equals to offset / 2
;
;               - dx equals to the screen data register port number
;
;               - di is equal to MAX_COLS * 2
;
;       Else:
;
;               - ax equals to the offset from video memory
;
;               - dx equals to screen data register port number
;
;               - bx is modified
;
;               - di is equal to MAX_COLS * 2           
;
_cursorGoDown:
        call _getCursor
        mov bx, ax
        mov di, MAX_COLS * 2
        add bx, di
        cmp bx, MAX_COLS * MAX_ROWS * 2
        jl _setCursor
        ret

