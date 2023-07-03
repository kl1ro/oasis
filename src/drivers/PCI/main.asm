PCI:
    ;
    ;   Alright... Let's enumerate the ports
    ;   being used to communicate with the
    ;   PCI controller
    ;
    ;
    ;   32-bit:
    ;
    .dataPort equ 0xcfc
    .commandPort equ 0xcf8

    ;
    ;   This function reads device information
    ;   from PCI controller
    ;
    ;   Input:
    ;       - eax as the bus number
    ;
    ;       - ebx as the device number
    ;
    ;       - ecx as the function number
    ;
    ;       - edx as the register offset
    ;       (needs to be a multiple of 4)
    ;
    ._readFromFunction:
        ;
        ;   Get the function id
        ;
        call ._getId

        ;
        ;   Tell the PCI which function 
        ;   we want to read
        ;
        mov dx, .commandPort
        out dx, eax

        ;
        ;   Read the device function
        ;
        mov dx, .dataPort
        in eax, dx
        ret

    ;
    ;   This function writes ...
    ;
    ;   Input:
    ;       - eax as the bus number
    ;
    ;       - ebx as the device number
    ;
    ;       - ecx as the function number
    ;
    ;       - edx as the register offset
    ;
    ;       - esi as the value we want to write
    ;
    ._writeToFunction:
        ;   
        ;   Get the function id   
        ;
        call ._getId

        ;
        ;   Tell the PCI which function
        ;   we want to write to
        ;
        mov dx, .commandPort
        out dx, eax

        ;
        ;   And then write to function
        ;
        mov dx, .dataPort
        mov eax, esi
        out dx, eax
        ret

    ;
    ;   Checks if the device being
    ;   connected to the PCI has any function
    ;
    ;   Input:
    ;       - eax as the bus number
    ;
    ;       - ebx as the device number
    ;
    ;   Output:
    ;       - bit 7 of eax is set if the device has any function
    ;
    ._deviceHasFunctions:
        ;
        ;   Prepare the registers to _readFromFunction command and call it
        ;
        ;   Function number is 0
        ;
        xor ecx, ecx

        ;
        ;   Register offset is 0x0e
        ;
        mov edx, 0x0e
        call ._readFromFunction
        ret

    ;
    ;   This converts the bus, device, function
    ;   and register offset into single number
    ;   that it stores in eax
    ;
    ._getId:
        shl eax, 16
        shl ebx, 11
        shl ecx, 8
        or eax, ebx
        or eax, ecx
        or eax, edx
        ret

