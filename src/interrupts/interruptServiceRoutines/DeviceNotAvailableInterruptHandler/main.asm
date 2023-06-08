_deviceNotAvailableInterruptHandler:
    section .data
        .deviceNotAvailable db "FPU device is not available!"

    section .text
        mov rsi, .deviceNotAvailable
        call _print
        jmp _haltMachine