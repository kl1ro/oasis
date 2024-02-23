_invalidTSSInterruptHandler:
    section .data
        .invalidTSS db "The loaded TSS is invalid!"

    section .text
        mov rsi, .invalidTSS
        call Screen._print
        jmp _halt