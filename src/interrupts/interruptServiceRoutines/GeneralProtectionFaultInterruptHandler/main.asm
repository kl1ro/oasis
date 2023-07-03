_generalProtectionFaultInterruptHandler:
    section .data
        .generalProtectionFault db "General protection fault occured!", 0
    
    section .text
        mov rsi, .generalProtectionFault
        call _print
        jmp _haltMachine