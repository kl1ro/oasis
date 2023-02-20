;
; Some useful constants
;
KEYBOARD_DATAPORT equ 0x60
KEYBOARD_COMMANDPORT equ 0x64

;
; This is a keyboard driver that 
; is invoked when keyboard interrupt,
; which is 0x21, is triggered
;
_getKeyboardKey:
	;
	; First things first read the data
	; stored in the keyboard dataport
	;
	xor rax, rax
	mov dx, KEYBOARD_DATAPORT
	in al, dx

	;
	; Then we need to check all of the	
	; cases of key codes
	;
	
	;
	; Escape button
	;
	cmp al, 1
	je _break
	
	;	
	; Backspace
	;
	cmp al, 14
	je _backspace
		
	;
	; Shift pushed
	;
	cmp al, 54
	je _keyboardCaseShiftPushed
	cmp al, 42
	je _keyboardCaseShiftPushed

	;
	; Shift released
	; 
	cmp al, 170
	je _keyboardCaseShiftReleased
	cmp al, 182
	je _keyboardCaseShiftReleased
	
	;
        ; If this is a release key 
        ; interrupt except shift we just break
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
		call _print
		ret

	_keyboardCaseShiftPushed:
		mov al, 1
		mov [shiftFlag], al
		ret
	
	_keyboardCaseShiftReleased:
                xor al, al
                mov [shiftFlag], al
                ret

shiftFlag db 0
keyboardBuffer dq 0
keyboardToAsciiSwitchTable db 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 0, 0, 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 10, 0, 97, 115, 100, 102, 103, 104, 106, 107, 108, 59, 39, 0, 0, 0, 122, 120, 99, 118, 98, 110, 109, 44, 46, 47, 0, 0, 0, 32,                                     33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 0, 0, 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 123, 125, 10, 0, 65, 83, 68, 70, 71, 72, 74, 75, 76, 58, 34, 0, 0, 0, 90, 88, 67, 86, 66, 78, 77, 60, 62, 63    