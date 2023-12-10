org 0x7e00
bits 64
[map all Etc/kernelLinks.map]

section .text

_startLM:	
	;
	;	Printing about switching to 64-bit success		
	;
	mov rsi, done
	call Screen._print

	;
	;	Print loading IDT
	;
	mov rsi, loadingIDT
	call Screen._print

	;
	;	Load IDT
	;		
	call _loadIDT	

	;
	;	Print about loading IDT success
	;	
	mov rsi, done
	call Screen._print

	;
	;	Iniitialize the subsystems
	;
	call ATA._init
	call PCI._init

	;
	;	Copy message to the sector
	;
	mov rsi, message
	mov rdi, sector
	call _strcpy

	;
	;	Write the message to the disk
	;
	mov rsi, sector
	mov rdi, ATA.port0Base
	xor ebx, ebx
	mov al, 1
	call ATA._write

	jmp _chill

;
;	Drivers
;
%include "Src/Drivers/Keyboard/main.asm"
%include "Src/Drivers/Screen/main.asm"
%include "Src/Drivers/PCI/main.asm"
%include "Src/Drivers/ATA/main.asm"

;
;	Interrupt handlers
;
%include "Src/Interrupts/InterruptServiceRoutines/DivisionBy0InterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/InvalidOpcodeInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/DeviceNotAvailableInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/InvalidTSSInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/SegmentNotPresentInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/StackSegmentFaultInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/GeneralProtectionFaultInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/PageFaultInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/FloatingPointExceptionHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/KeyboardInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/ClockInterruptHandler/main.asm"
%include "Src/Interrupts/InterruptServiceRoutines/SyscallHandler/main.asm"
%include "Src/Interrupts/Resources/IDTInterruptGatePattern/main.asm"

;
;	Syscalls
;
%include "Src/Syscalls/SysRead/main.asm"

;
;	AsmFunctions
;
%include "../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../AsmFun/Headers64bit/Break/main.asm"
%include "../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../AsmFun/Headers64bit/Chill/main.asm"
%include "../AsmFun/Headers64bit/Memset/main.asm"
%include "../AsmFun/Headers64bit/IntToString/main.asm"
%include "../AsmFun/Headers64bit/AssignFlippedIntegerPortion/main.asm"
%include "../AsmFun/Headers64bit/FlipString/main.asm"
%include "../AsmFun/Headers64bit/Memclrb/main.asm"
%include "../AsmFun/Headers64bit/Strcpy/main.asm"
%include "../AsmFun/Headers64bit/Pusha/main.asm"
%include "../AsmFun/Headers64bit/Popa/main.asm"

;
;	Strings
;
done db "Done!", 10, 0
lineBreak db 10, 0
loadingIDT db "Loading IDT... ", 0
sector times 512 db 0
message db "This is a message that will be written to the disk", 0