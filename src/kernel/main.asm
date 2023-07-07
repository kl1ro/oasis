org 0x7e00
bits 64
[map all etc/kernelLinks.map]

section .text

_startLM:	
	;
	; Printing about switching 
	; to 64-bit success		
	;
	mov rsi, done
	call _print

	;
	; Print loading IDT
	;
	mov rsi, loadingIDT
	call _print

	;
	; Load IDT
	; 	
	call _loadIDT	

	;
	; Print about loading IDT success
	;	
	mov rsi, done
	call _print

	;
	; Check all ATA ports
	;
	call ATA._init

	mov rsi, diskMessage
	mov rdi, diskSectorBuffer
	call _strcpy

	mov rsi, diskSectorBuffer
	mov rdi, ATA.port0Base
	mov al, 1
	mov ebx, 0
	call ATA._write
	test al, al
	jz _haltMachine
	call ATA._flush

	mov rsi, ATA.port0Base
	mov rdi, diskSectorBuffer
	mov al, 1
	xor ebx, ebx
	mov rcx, 512
	call ATA._read

	mov rsi, diskSectorBuffer
	call _print

	jmp _chill

;
; Drivers
;
%include "src/drivers/keyboard/main.asm"
%include "src/drivers/screen/main.asm"
%include "src/drivers/ATA/main.asm"

;
; Interrupt handlers
;
%include "src/interrupts/interruptServiceRoutines/DivisionBy0InterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/InvalidOpcodeInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/DeviceNotAvailableInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/InvalidTSSInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/SegmentNotPresentInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/StackSegmentFaultInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/GeneralProtectionFaultInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/PageFaultInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/FloatingPointExceptionHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/KeyboardInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/ClockInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/SyscallHandler/main.asm"
%include "src/interrupts/resources/IDTInterruptGatePattern/main.asm"

;
; Syscalls
;
%include "src/syscalls/sysRead/main.asm"

;
; AsmFunctions
;
%include "../../AsmFun/Headers64bit/TempRes/main.asm"
%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/InterruptBreak/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Sleep/main.asm"
%include "../../AsmFun/Headers64bit/Chill/main.asm"
%include "../../AsmFun/Headers64bit/MinusCheck/main.asm"
%include "../../AsmFun/Headers64bit/AssignFlippedIntegerPortion/main.asm"
%include "../../AsmFun/Headers64bit/FlipString/main.asm"
%include "../../AsmFun/Headers64bit/IntToString/main.asm"
%include "../../AsmFun/Headers64bit/AddMinus/main.asm"
%include "../../AsmFun/Headers64bit/Memclrb/main.asm"
%include "../../AsmFun/Headers64bit/Add0/main.asm"
%include "../../AsmFun/Headers64bit/AddNewLineCharacter/main.asm"
%include "../../AsmFun/Headers64bit/AddSpaceCharacter/main.asm"
%include "../../AsmFun/Headers64bit/Strcpy/main.asm"

;
; Strings
;
done db "Done!", 10, 0
loadingIDT db "Loading IDT... ", 0
diskMessage db "This message is put to the disk drive and is taken from it!", 0
diskSectorBuffer times 512 db 0

