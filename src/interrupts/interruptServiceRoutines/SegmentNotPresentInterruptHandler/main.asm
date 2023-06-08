_segmentNotPresentInterruptHandler:
    section .data
       .segmentNotPresent db "Segment not present fault occured meaning the current", 10, "segment present bit is 0."

    section .text
        mov rsi, .segmentNotPresent
        call _print
        jmp _haltMachine