_deviceNotAvailableInterruptHandler:
    section .data
        .deviceNotAvailable db "FPU device is not available!"

    section .text
        mov rsi, .deviceNotAvailable
        call Screen._print
        jmp _halt