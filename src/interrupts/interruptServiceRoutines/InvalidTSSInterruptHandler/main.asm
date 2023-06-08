_invalidTSSInterruptHandler:
    section .data
        .invalidTSS db "The loaded TSS is invalid!"

    section .text
        mov rsi, .invalidTSS
        call _print
        jmp _haltMachine