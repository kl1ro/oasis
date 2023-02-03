org 0x500

bits 64

_startLM:
	mov r9, done
	call _print
	jmp _haltMachine

%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Memcpy/main.asm"
%include "src/drivers/screen/main.asm"
done db "Done!", 10, 10, 10, "one", 10, 10, 10, "one", 10, 10, 10, "one", 10, "idkfjks", 10, "dkfs", 10, "dksfk", 10, "asjf;sajf;sdkf", 10, 10, 10, 10, 10, 10, "2432", 10, 10, "fsf", 10, "fskdf", 10, "fskddjfks", 0
