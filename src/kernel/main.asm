org 0x5000
bits 64
[map all etc/links.map]

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

	jmp _console

;
; Drivers
;
%include "src/drivers/keyboard/main.asm"
%include "src/drivers/screen/main.asm"

;
; Interrupt handlers
;
%include "src/interrupts/interruptServiceRoutines/DivisionBy0InterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/InvalidOpcodeInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/DeviceNotAvailableInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/InvalidTSSInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/SegmentNotPresentInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/StackSegmentFaultInterruptHandler/main.asm"
%include "src/interrupts/interruptServiceRoutines/IgnoreInterruptHandler/main.asm"
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
%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/InterruptBreak/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Negate/main.asm"
%include "../../AsmFun/Headers64bit/Sleep/main.asm"
;
; Utilities
;
%include "src/utilities/console/main.asm"

;
; Variables
;
done db "Done!", 10, 0
loadingIDT db "Loading IDT... ", 0

