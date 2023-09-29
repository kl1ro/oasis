;
;	Some useful constants
;
KEYBOARD_DATAPORT equ 0x60
KEYBOARD_COMMANDPORT equ 0x64

;
;	This is a keyboard driver that is invoked whenever the keyboard interrupt,
;	which is 0x21, is triggered.
;
;	Input:
;		- nothing
;
;	Output:
;		If [SHIFT] is pressed or released:
;			- rax is 1 if pressed and 0 if released
;
;			- dx equals to keyboard data port
;
;		Else if [Backspace] is pressed:
;			If the cursor is on the first character of the screen:
;				- rax is modified
;
;				- rbx is modified
;
;				- rcx equals to 0
;
;				- rdx is a number of screen data port
;
;				- rdi equals to maximum cols * 2
;
;			Else if the cursor is on one of the rest of the characters:
;				- rax is modified
;
;				- rbx is modified
;
;				- rdx is a number of screen data port
;
;		Else:
;			- rax is modified
;			
;			- rbx equals to offset to the place after the last character
;             of the string on the screen
;
;			- rcx is modified
;
;			- dx equals to screen data register port number
;
;			- rsi point to the end of the string
;
;			- rdi equals to 0
;
;			- r8 is modified
;
;			- r9 equals to rsi
;
;	Input:
;		- nothing
;
_getKeyboardKey:
	;
	;	First things first read the data
	;	stored in the keyboard dataport
	;
	xor rax, rax
	mov dx, KEYBOARD_DATAPORT
	in al, dx

	;
	;	Then we need to check all of the cases of key codes
	;
	
	;
	;	Escape button
	;
	cmp al, 1
	je _break

	;	
	;	Backspace
	;
	cmp al, 14
	je Screen._backspace
		
	;
	;	Shift pushed
	;
	cmp al, 54
	je _keyboardCaseShiftPushed
	cmp al, 42
	je _keyboardCaseShiftPushed
	
	;
	;	Shift released
	;	
	cmp al, 170
	je _keyboardCaseShiftReleased
	cmp al, 182
	je _keyboardCaseShiftReleased

	;
	;	Right pressed
	;
	cmp al, 77
	je Screen._cursorGoRight

	;
	;	Up pressed
	;
	cmp al, 72
	je Screen._cursorGoUp

	;
	;	Left pressed
	;
	cmp al, 75
	je Screen._cursorGoLeft

	;
	;	Down pressed
	;
	cmp al, 80
	je Screen._cursorGoDown

	;
	;	If this is a release key 
	;	interrupt except shift we just break
	;
	cmp al, 80
	ja _break

	mov bl, [shiftFlag]
	test bl, bl
	jz _keyboardElseShift
	
	_keyboardIfShift:
		mov al, [keyboardToAsciiSwitchTable + rax + 54]	
		jmp _keyboardCaseAfter

	_keyboardElseShift:
		mov al, [keyboardToAsciiSwitchTable + rax - 2]

	_keyboardCaseAfter:
		mov rsi, keyboardBuffer
		mov [rsi], al
		call Screen._print
		ret

	_keyboardCaseShiftPushed:
		mov al, 1
		mov [shiftFlag], al
		ret
	
	_keyboardCaseShiftReleased:
		xor al, al
		mov [shiftFlag], al
		ret

section .data
	shiftFlag db 0
	keyboardBuffer times 2 db 0

	;
	;	This is a counter of characters to read from the keyboard. 
	;	It is received from user code when it does the sysRead syscall.
	;
	inputCounter db 0

	;
	;	This is the buffer that is received from user
	;	code from sysRead syscall
	;
	inputBuffer db 0

section .text
	keyboardToAsciiSwitchTable db 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 0, 0, 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 10, 0, 97, 115, 100, 102, 103, 104, 106, 107, 108, 59, 39, 0, 0, 0, 122, 120, 99, 118, 98, 110, 109, 44, 46, 47, 0, 0, 0, 32, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 0, 0, 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 123, 125, 10, 0, 65, 83, 68, 70, 71, 72, 74, 75, 76, 58, 34, 0, 0, 0, 90, 88, 67, 86, 66, 78, 77, 60, 62, 63    
