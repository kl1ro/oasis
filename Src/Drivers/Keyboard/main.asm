Keyboard:
	;
	;	Some useful constants
	;
	.DATAPORT equ 0x60
	._cOMMANDPORT equ 0x64

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
	._getKey:
		;
		;	First things first read the data stored in the keyboard dataport
		;
		xor rax, rax
		mov dx, .DATAPORT
		in al, dx
		mov rdi, .buffer
		mov rcx, 10
		call _intToString
		mov rsi, .buffer
		mov [rdi], byte 10
		call Screen._print
		mov rdi, .buffer
		mov rcx, 4
		call _memclrb
		ret

		;
		;	Then we need to check all of the cases of key codes
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
		je ._caseShiftPushed
		cmp al, 42
		je ._caseShiftPushed
		
		;
		;	Shift released
		;	
		cmp al, 170
		je ._caseShiftReleased
		cmp al, 182
		je ._caseShiftReleased

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
		;	If the key is released, we just break, except for the shift key.
		;
		cmp al, 80
		ja _break

		mov bl, [.shiftFlag]
		test bl, bl
		jz ._keyboardElseShift
		
		._keyboardIfShift:
			mov al, [.keyboardToAsciiSwitchTable + rax + 55]	
			jmp .default

		._keyboardElseShift:
			mov al, [.keyboardToAsciiSwitchTable + rax - 1]

		;
		;	Default case, in which we just print the key
		;
		.default:
			mov rsi, .buffer
			mov [rsi], al
			call Screen._print
			ret

		;
		;	Other cases
		;
		._caseShiftPushed:
			mov al, 1
			mov [.shiftFlag], al
			ret
		
		._caseShiftReleased:
			xor al, al
			mov [.shiftFlag], al
			ret

	section .data
		.shiftFlag db 0
		.buffer times 4 db 0

		;
		;	This is a counter of characters to read from the keyboard. 
		;	It is received from user code when it does the sysRead syscall.
		;
		.inputCounter db 0

		;
		;	This is the buffer that is received from user code from sysRead syscall
		;
		.inputBuffer db 0

	section .text

		;
		;	Keyboard codes to ascii convertion table
		;
		.keyboardToAsciiSwitchTable: 
			;
			;    Esc(1)  1(2)  2(3)  3(4)  4(5)  5(6)  6(7)  7(8)  8(9)  9(10)  0(11)  -(12)  (13)   Backspace(14)  Tab(15)
			;    |       |     |     |     |     |     |     |     |     |      |      |      |      |              |
			db   0,      49,   50,   51,   52,   53,   54,   55,   56,   57,    48,    45,    61,    0,             0  
			
			;
			;    q(16)  w(17)  e(18)  r(19)  t(20)  y(21)  u(22)  i(23)  o(24)  p(25)  [(26)  ](27)  Enter(28)  Left Ctrl(29)
			;    |      |      |      |      |      |      |      |      |      |      |      |      |          |
			db   113,   119,   101,   114,   116,   121,   117,   105,   111,   112,   91,    93,    10,        0
			
			;
			;    a(30)  s(31)  d(32)  f(33)  g(34)  h(35)  j(36)  k(37)  l(38)  ;(39)  '(40)
			;    |      |      |      |      |      |      |      |      |      |      |
			db   97,    115,   100,   102,   103,   104,   106,   107,   108,   59,    39
			
			;
			;    `(41)  Shift(42) \(43)
			;
			db   96, 0, 0, 122, 120, 99, 118, 98, 110, 109, 44, 46, 47, 0, 0, 0, 32, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 0, 0, 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 123, 125, 10, 0, 65, 83, 68, 70, 71, 72, 74, 75, 76, 58, 34, 0, 0, 0, 90, 88, 67, 86, 66, 78, 77, 60, 62, 63