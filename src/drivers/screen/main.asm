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

; Screen device 1/0 ports
REG_SCREEN_CTRL equ 0x3d4
REG_SCREEN_DATA equ 0x3d5

;
; Prints a string to the screen 
; at the specific row and colomn position
;
; Input: 
;	r9 is a pointer to the string
; 	ah is a style of the character
; 	cl is a row position
;	ch is a colomn
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
	; si is a buffer
	;
	mov si, ax
	
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
        mov ax, si

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
	mov al, [r9]
	test al, al
	jz _break
	cmp al, 10
	jne _elseNewLineCharacter 

_ifNewLineCharacter:	
	;
	; We have to save our ax register
        ; because for some reason div instruction
        ; can divide only rax. So si register will
        ; serve as a buffer.
	;
	mov si, ax
	mov ax, bx
	mov di, MAX_COLS
	shl di, 1
	xor rdx, rdx
	div di
	sub rdi, 10b
	sub rdi, rdx
	add rbx, rdi
	
	;
        ; Restore ax
        ;
        mov ax, si	
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
	inc r9
	mov r13, r9
	call _handleScrolling
	mov rsi, rbx
	call _setCursor	
	mov rbx, rsi
	mov r9, r13
	jmp _writeCharacterCycle
	
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
;
_getVideomemoryOffset:
	xor ax, ax
	mov al, cl
	mov di, MAX_COLS
	mul di
	shr cx, 8
	add ax, cx
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
;	bx is offset
; Output:
;	nothing but cursor is set
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
;	r9 is a pointer to a string
;	ah is a style
;
_print:
	mov ch, -1
	call _printAt
	ret

;
; Another useful but not too complicated
; function is a _clearScreen that puts
; \0 character at each position of the 
; screen
;
; Input: 
; 	nothing
; Output:
; 	nothing
;
_clearScreen:
	;
	; This 64-bit number represents 4
	; standard style space characters	
	;
	mov rax, 0x0720072007200720
	mov rbx, VIDEO_ADDRESS
	
_clearScreenCycle:
	mov [rbx], rax
	add rbx, 8
	cmp rbx, 0xb8Fa0
	jne _clearScreenCycle
	xor rbx, rbx
	call _setCursor
	ret

;
; In order to keep our screen from 
; overflowing we need to handle scrolling
;
; Input:
;	rbx is the cursor offset
;
; Note: hardcoded values
_handleScrolling:
	;
	; If the cursor is within the
	; screen we getting out
	;
	cmp rbx, 0xfa0
	jne _break
	mov r10, 0xb80a0 	; Which is the second string
	mov r11, 0xb8000	; i.e. the first string
	mov r12, 0xa0
	
	;
	; Moving strings one by one
	; until we reach the last string
	; 	
	_handleScrollingCycle:
		mov r8, r10
		mov r9, r11
		mov rcx, r12
		call _memcpy
		add r10, r12
		add r11, r12	
		cmp r11, 0xb8f00
		jne _handleScrollingCycle
	
	mov r10, 0x0720072007200720
	
	; 
	; Blank the last line by setting all bytes to 0
	;
	_handleScrollingBlankLineCycle:
		mov [r11], r10
		add r11, 8
		cmp r11, 0xb8fa0
		jne _handleScrollingBlankLineCycle
	
	sub rbx, r12
	ret

;
; For the keyboard interrupt [ENTER]
; we need to write a function that 
; pushes the cursor to the first character of
; the next line
;
; Input:
;	nothing but rbx must be 0
;	and rax too
; Output:
;	cursor is in the first character
;	of a new line
;
_newLine:
	call _getCursor
	mov bx, ax
	mov di, MAX_COLS
        shl di, 1
        xor dx, dx
        div di
        sub di, dx
        add bx, di
	call _setCursor
	ret
