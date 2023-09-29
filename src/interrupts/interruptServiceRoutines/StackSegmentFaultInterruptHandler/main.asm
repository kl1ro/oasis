_stackSegmentFaultInterruptHandler:
    segment .data
        .stackSegmentFault db "Stack-segment fault has occured!"
    segment .text
        mov rsi, .stackSegmentFault
        call Screen._print
        jmp _haltMachine