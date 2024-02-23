PCI:
    ;
    ;   Alright... Let's enumerate the ports being used to communicate with the
    ;   PCI controller. They are 32-bit each.
    ;
    .dataPort equ 0xcfc
    .commandPort equ 0xcf8

    ;
    ;   This function reads the device function data from PCI controller
    ;
    ;   Input:
    ;       - ax as the bus number
    ;
    ;       - bx as the device number
    ;
    ;       - cx as the function number
    ;
    ;       - edx as the register offset (needs to be a multiple of 4)
    ;
    ;   Output:
    ;       - eax stores the device function data
    ;
    ;       - bx is modified
    ;
    ;       - cx is modified
    ;
    ;       - edx is modified 
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
    ;   This function writes to function
    ;
    ;   Input:
    ;       - ax as the bus number
    ;
    ;       - bx as the device number
    ;
    ;       - cx as the function number
    ;
    ;       - edx as the register offset
    ;
    ;       - esi as the value we want to write
    ;
    ;   Output:
    ;       - eax is modified
    ;
    ;       - bx is modified
    ;
    ;       - cx is modified
    ;
    ;       - edx is modified       
    ;
    ;       - esi remains the same
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
    ;   Checks if the device being connected to the PCI has any function
    ;
    ;   Input:
    ;       - ax as the bus number
    ;
    ;       - bx as the device number
    ;
    ;   Output:
    ;       - bit 7 of eax is set if the device has any function
    ;
    ;       - bx is modified
    ;
    ;       - cx is modified
    ;
    ;       - edx is modified                
    ;
    ._deviceHasFunctions:
        ;
        ;   Prepare the registers to _readFromFunction command and call it
        ;
        ;   Function number is 0
        ;
        xor cx, cx

        ;
        ;   Register offset is 0x0e
        ;
        mov edx, 0x0e
        call ._readFromFunction
        ret

    ;
    ;   This converts the bus, device, function and register offset into single number
    ;   that it stores in eax
    ;
    ;   Input:
    ;       - ax as the bus number
    ;
    ;       - bx as the device number
    ;
    ;       - cx as the function number
    ;
    ;       - edx as the register offset
    ;
    ;   Output:
    ;       - eax stores the function id
    ;
    ;       - bx is modified
    ;
    ;       - cx is modified
    ;
    ;       - edx is modified
    ;
    ._getId:
        shl eax, 16
        shl ebx, 11
        shl ecx, 8
        or eax, ebx
        or eax, ecx
        or eax, edx
        bts eax, 31
        ret

    ;
    ;   This function enumerates the devices connected to the PCI and prints their data
    ;   to the screen
    ;
    ._init:
        ;
        ;   Print that we're looking for devices
        ;
        mov rsi, .lookingForPCIDevices
        call Screen._print

        ;
        ;   Registers ax, bx, cx and edx will be used as the parameters to the read functions. 
        ;   So we need to store the iteration counters in the other registers, e.g. r10w, r11w, r12w. 
        ;   Then r10w is the bus number, r11w is the device number and r12w is function number. 
        ;   The reason we use exactly these registers is because print function uses all registers up to r9
        ;
        ;   First things first we start the enumeration cycles
        ;
        xor r10w, r10w 

        ._busesEnumerationCycle:
            cmp r10w, 8
            je _break
            xor r11w, r11w

            ._devicesEnumerationCycle:
                cmp r11w, 32
                je ._devicesEnumerationCycleReturn
                
                ;
                ;   Check if the device has functions and start the cycle only one time if it doesn't
                ;
                xor r12w, r12w
                mov ax, r10w
                mov bx, r11w
                call ._deviceHasFunctions
                bt eax, 7
                jnc ._elseDeviceHasFunctions

                ._ifDeviceHasFunctions:
                    mov r13w, 8
                    jmp ._functionsEnumerationCycle

                ._elseDeviceHasFunctions: 
                    mov r13w, 1
                
                ._functionsEnumerationCycle:
                    cmp r12w, r13w
                    je ._functionsEnumerationCycleReturn 

                    ;
                    ;   Read the device function vendor and device ids, save them in r14d
                    ;
                    mov ax, r10w
                    mov bx, r11w
                    mov cx, r12w
                    xor edx, edx
                    call ._readFromFunction
                    cmp eax, 0xffffffff
                    je ._functionsEnumerationCycleContinue
                    test eax, eax
                    jz ._functionsEnumerationCycleContinue
                    mov r14d, eax

                    ;
                    ;   Print vendor id string
                    ;
                    mov rsi, .vendorIdString
                    call Screen._print

                    ;
                    ;   Process the vendor id and print it
                    ;
                    mov eax, r14d
                    and eax, 0xffff
                    mov rdi, .buffer
                    mov rcx, 16
                    call _itoa
                    mov rsi, .buffer
                    call Screen._print

                    ;
                    ;   Print the device id string
                    ;
                    mov rsi, .deviceIdString
                    call Screen._print 
                    
                    ;
                    ;   Process the device id and print it
                    ;
                    mov eax, r14d
                    shr eax, 16
                    mov rdi, .buffer
                    mov rcx, 16
                    call _itoa
                    mov rsi, .buffer
                    call Screen._print

                    ;
                    ;   Print the line break
                    ;
                    mov rsi, lineBreak
                    call Screen._print
                
                    ._functionsEnumerationCycleContinue:
                    inc r12w
                    jmp ._functionsEnumerationCycle

                ._functionsEnumerationCycleReturn: 
                inc r11w
                jmp ._devicesEnumerationCycle

            ._devicesEnumerationCycleReturn:
            inc r10w
            jmp ._busesEnumerationCycle

section .data
    .lookingForPCIDevices db 10, "Looking for PCI devices:", 10, 0
    .buffer times 4 db "0"
                    db 32, 0
    .vendorIdString db "    Vendor id: ", 0
    .deviceIdString db "Device id: ", 0
    .classAndSubclassIdsString db "Class and subclass ids: ", 0

section .text
