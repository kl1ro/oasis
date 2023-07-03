_invalidOpcodeInterruptHandler:
    section .data
        .invalidOpcode db "The invalid instruction opcode exception occured!"

    section .text
        mov rsi, .invalidOpcode
        call _print
        jmp _haltMachine