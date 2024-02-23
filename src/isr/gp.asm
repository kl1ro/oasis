_generalProtectionFaultInterruptHandler:
    section .data
        .generalProtectionFault db "General protection fault occured!", 0
    
    section .text
        mov rsi, .generalProtectionFault
        call Screen._print
        jmp _halt