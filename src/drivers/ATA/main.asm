;
;   Here I try to use the label as the 
;   namespace and that's kinda funny.
;   Let's see if it will work.
;   If you see this, it does.
;
ATA:

    ;
    ;   So this will be an easy ATA driver
    ;   that only use the 28 bit PIO method. 
    ;   Maybe I will implement the DMA 
    ;   in the future, who knows...
    ;
    ;   These are the ports that are used 
    ;   to communicate with the Advanced Technology 
    ;   Attachment chip. All ports are 8 bit 
    ;   except the data one, it is 16 bit:
    ;
    .port0Base equ 0x1f0
    .port1Base equ 0x170
    .port2Base equ 0x1e8
    .port3Base equ 0x168
    .dataPortOffset equ 0
    .errorPortOffset equ 1
    .sectorCountPortOffset equ 2
    .lbaLowPortOffset equ 3
    .lbaMidPortOffset equ 4
    .lbaHighPortOffset equ 5
    .devicePortOffset equ 6 
    .commandPortOffset equ 7
    .controlPortOffset equ 0x206

    ;
    ;   Some useful constants
    ;
    .bytesPerSector equ 512
    .devicePortIdentifyMasterMessage equ 0xa0
    .devicePortIdentifySlaveMessage equ 0xb0
    .devicePortReadWriteMasterMessage equ 0xe0
    .devicePortReadWriteSlaveMessage equ 0xf0
    .commandPortIdentifyMessage equ 0xec
    .commandPortReadMessage equ 0x20
    .commandPortWriteMessage equ 0x30

    ;
    ;   Some driver messages
    ;
    section .data
        .ATADeviceDetectedMessage db "    ATA device detected at bus ", 0
        .lookForATADevicesMessage db "Looking for ATA devices:", 10, 0
        .noDevicesMessage db "    No devices were found", 10, 0
        .error db "    There's an ATA error!", 10, 0
        .slaveMessage db "Slave", 10, 0
        .masterMessage db "Master", 10, 0

        ;
        ;   Memory for the hex value
        ;
	    .ATAPortBaseHex times 4 db 0

    section .text
    
    ;
    ;   This function initializes the communication
    ;   between the cpu and the ata adapter
    ;
    ;   Input:
    ;       - rsi as the ata port base
    ;
    ;       - al as the master or slave 
    ;       (1 if master, else 0)
    ;
    ;   Output:
    ;       - al is 1 if everything worked fine
    ;         otherwise it will be 0
    ;
    ;       - bl is equal to 0xa0 or 0xb0
    ;
    ;       - rdx is modified
    ;
    ;       - rcx is modified
    ;
    ._identify:
        ;
        ;   First we need to tell the ata adapter
        ;   that we need to talk to the master or 
        ;   to the slave
        ;
        ;   Check who we want to talk to
        ;
        test al, al
        jz ._ifTalkToSlaveIdentify

        ._ifTalkToMasterIdentify:
            mov al, .devicePortIdentifyMasterMessage
            jmp ._ifTalkToReturnIdentify

        ._ifTalkToSlaveIdentify:
            mov al, .devicePortIdentifySlaveMessage
    
        ._ifTalkToReturnIdentify:

        ;
        ;   The bl register will store the 
        ;   slave/master message
        ;
        mov bl, al

        ;
        ;   Calculate the device port
        ;
        mov rdx, rsi
        add dx, .devicePortOffset
        
        ;
        ;   Tell the ata adapter who we want to talk to
        ;
        out dx, al

        ;
        ;   Calculate the control port
        ;
        add dx, .controlPortOffset - .devicePortOffset

        ;
        ;   Clear the hob bit and set nien bit
        ;
        mov al, 2
        out dx, al

        ;
        ;   Calculate the device port
        ;
        sub dx, .controlPortOffset - .devicePortOffset

        ;
        ;   Now we need to talk to the master
        ;
        mov al, .devicePortIdentifyMasterMessage
        out dx, al

        ;
        ;   Calculate the command port
        ;
        add dx, .commandPortOffset - .devicePortOffset

        ;
        ;   Get the ATA Drive status
        ;
        in al, dx

        ;
        ;   The ATA controller responds with 0xff if
        ;   there's no device
        ;
        cmp al, 0xff
        jne ._elseNoDevice

        ._ifNoDevice:
            xor al, al
            ret
        
        ._elseNoDevice:
        
        ;
        ;   Restore master/slave message
        ;   from bl
        ;
        mov al, bl

        ;
        ;   Calculate the device port
        ;
        sub dx, .commandPortOffset - .devicePortOffset

        ;
        ;   Tell the ata adapter who we want to talk to
        ;
        out dx, al

        ;
        ;   Calculate the sector count port
        ;
        sub dx, .devicePortOffset - .sectorCountPortOffset

        ;
        ;   Null the count port
        ;
        xor al, al
        out dx, al

        ;
        ;   Calculate the lba low port
        ;
        inc dx

        ;
        ;   Null the lba low port
        ;
        out dx, al

        ;
        ;   Calculate the lba mid port
        ;
        inc dx

        ;
        ;   Null the lba mid port
        ;
        out dx, al

        ;
        ;   Calculate the lba high port
        ;
        inc dx

        ;
        ;   Null the lba high port
        ;
        out dx, al
        
        ;
        ;   Calculate the command port
        ;
        add dx, .commandPortOffset - .lbaHighPortOffset

        ;
        ;   Tell the ATA to execute
        ;   the identify instruction
        ;
        mov al, .commandPortIdentifyMessage
        out dx, al

        ;
        ;   Get the ATA Drive status
        ;
        in al, dx
        
        test al, al
        jz ._ifNoDevice

        ._waitForDevice:
            ;
            ;   First bit means ata device error
            ;
            bt ax, 0
            jc ._ifNoDevice

            ;
            ;   Eighth bit means ata device busy
            ;
            bt ax, 7
            jc ._waitStatusConfirmed
            jmp ._waitForDeviceReturn

            ._waitStatusConfirmed:
                ;
                ;   Get new ATA Drive status
                ;
                in al, dx
                jmp ._waitForDevice

        ._waitForDeviceReturn:
        
        ;
        ;   Calculate the data port
        ;
        sub dx, .commandPortOffset - .dataPortOffset
        
        ;
        ;   Read the sector 
        ;
        mov rcx, .bytesPerSector / 2
        
        ;
        ;   For now we will read the sector and immediately forget it
        ;
        ._identifyReadCycle:
            in ax, dx
            loop ._identifyReadCycle

        mov al, 1
        ret

    ;
    ; 	Checks ATA port
    ;
    ;	Input:
    ;		- rsi as a port base
    ;
    ;		- al as master/slave bit
    ;
    ;   Output:
    ;       - every single register up to r12 is modified
    ;
    ._checkATAPort:
        ;
        ;	Save ATA port base and master/slave bit
        ;
        mov r10, rsi
        mov r11b, al

        ;
        ;	Send the identify command
        ;
        call ._identify
        test al, al
        jnz ._ifATADeviceExists
        ret

        ._ifATADeviceExists:
            ;
            ;   Save the deviceExist flag
            ;	
            inc r12b

            ;
            ;   Print that ata device exists
            ;
            mov rsi, .ATADeviceDetectedMessage
            call _print

            ;
            ;   Print the hex value of the port base
            ;
            mov rax, r10
            mov rdi, .ATAPortBaseHex
            mov rcx, 16
            call _intToString
            mov rsi, rdi
            call _add0
            call _addSpaceCharacter
            mov rsi, .ATAPortBaseHex
            call _print

            ;
            ;   Print master/slave message
            ;
            test r11b, r11b
            jz ._printSlave

            ._printMaster:
                mov rsi, .masterMessage
                call _print
                ret

            ._printSlave:
                mov rsi, .slaveMessage
                call _print
                ret

    ;
    ;   Looks for ATA devices and prints them 
    ;
    ;   Input:
    ;       - nothing
    ;
    ;   Output:
    ;       - every single register from rax to r12 
    ;       is modified
    ;
    ._init:
        ;
        ;   Print look for ATA devices message
        ;
        mov rsi, .lookForATADevicesMessage
        call _print

        ;
        ;   Set the device exist flag to 0
        ;
        xor r12b, r12b
        
        ;
        ;   Check port 0 Master
        ;
        mov rsi, .port0Base
        mov al, 1
        call ._checkATAPort

        ;
        ;   Check port 0 Slave
        ;
        mov rsi, .port0Base
        xor al, al
        call ._checkATAPort

        ;
        ;   Check port 1 Master
        ;
        mov rsi, .port1Base
        mov al, 1
        call ._checkATAPort

        ;
        ;   Check port 1 Slave
        ;
        mov rsi, .port1Base
        xor al, al
        call ._checkATAPort

        ;
        ;   Check port 2 Master
        ;
        mov rsi, .port2Base
        mov al, 1
        call ._checkATAPort

        ;
        ;   Check port 2 Slave
        ;
        mov rsi, .port2Base
        xor al, al
        call ._checkATAPort

        ;
        ;   Check port 3 Master
        ;
        mov rsi, .port3Base
        mov al, 1
        call ._checkATAPort

        ;
        ;   Check port 3 Slave
        ;
        mov rsi, .port3Base
        xor al, al
        call ._checkATAPort

        ;
        ;   If there were no devices, we
        ;   print that out
        ;
        test r12b, r12b
        jz ._printNoDevices
        ret

        ._printNoDevices:
            mov rsi, .noDevicesMessage
            call _print
            ret

    ;
    ;   Reads the sector of a disk 
    ;   being pointed by lba
    ;
    ;   Input:
    ;       - rsi as a port base
    ;
    ;       - ebx as the 28 bit lba address
    ;
    ;       - rdi as a pointer to memory
    ;
    ;       - rcx as the number of bytes to read
    ;
    ;       - al as the master/slave bit
    ;
    ._read:
        ;
        ;   All ATA commands are relatively the
        ;   same thing
        ;
        ;   First we need to tell the ata adapter
        ;   that we need to talk to the master or 
        ;   to the slave
        ;

        ;
        ;   Check who we want to talk to
        ;
        test al, al
        jz ._ifTalkToSlaveRead

        ._ifTalkToMasterRead:
            mov al, .devicePortReadWriteMasterMessage
            jmp ._ifTalkToReturnRead

        ._ifTalkToSlaveRead:
            mov al, .devicePortReadWriteSlaveMessage
    
        ._ifTalkToReturnRead:

        ;
        ;   Take the last 4 bits of the sector 
        ;   and put it to the device port
        ;
        mov r8d, ebx
        shr r8d, 24
        or al, r8b

        ;
        ;   Calculate the device port
        ;
        mov dx, si
        add dx, .devicePortOffset

        ;
        ;   Tell the ata adapter who we want to talk to
        ;   and tell the last 4 lba bits
        ;
        out dx, al

        ;
        ;   Calculate the error port
        ;
        sub dx, .devicePortOffset - .errorPortOffset

        ;
        ;   Null the error port
        ;
        xor al, al
        out dx, al

        ;
        ;   Calculate the sector count port
        ;
        inc dx

        ;
        ;   Put 1 into the sector count port
        ;
        mov al, 1
        out dx, al

        ;
        ;   Calculate the lba low port
        ;
        inc dx

        ;
        ;   Put low lba bits into the lba low port
        ;
        mov al, bl
        out dx, al

        ;
        ;   Calculate the lba mid port
        ;
        inc dx

        ;
        ;   Put mid lba bits into the lba mid port
        ;
        mov al, bh
        out dx, al

        ;
        ;   Calculate the lba high port
        ;
        inc dx

        ;
        ;   Put high lba bits into the lba high port
        ;
        shr ebx, 8
        mov al, bh
        out dx, al
        
        ;
        ;   Calculate the command port
        ;
        add dx, .commandPortOffset - .lbaHighPortOffset

        ;
        ;   Tell the ATA to execute
        ;   the read instruction
        ;
        mov al, .commandPortReadMessage
        push rdx
        mov rdi, .memory
        mov rcx, 16
        call _intToString
        call _addSpaceCharacter
        pop rax
        mov rcx, 16
        call _intToString
        call _addNewLineCharacter
        mov rsi, .memory
        call _print
        jmp _haltMachine
        out dx, al
        
        ;
        ;   Get the ATA Drive status
        ;
        in al, dx

        ._waitForDeviceRead:
            ;
            ;   First bit means ata device error
            ;
            bt ax, 0
            jc ._printError

            ;
            ;   Eighth bit means ata device busy
            ;
            bt ax, 7
            jc ._waitStatusConfirmedRead
            jmp ._waitForDeviceReturnRead

            ._waitStatusConfirmedRead:
                ;
                ;   Get new ATA Drive status
                ;
                in al, dx
                jmp ._waitForDeviceRead

        ._waitForDeviceReturnRead:

        ;
        ;   Calculate the data port
        ;
        sub dx, .commandPortOffset - .dataPortOffset
        
        ;
        ;   Read the sector 
        ;   and store it in memory being
        ;   pointed by rdi
        ;
        mov r10, .bytesPerSector / 2
        xor rax, rax

        ._readCycle:
            in ax, dx
            mov rsi, .memory
            mov [rsi], ax
            xor ah, ah
            call _print
            dec r10
            test r10, r10
            jnz ._readCycle
        
        mov al, 1
        ret
    
    ._printError:
        mov rsi, .error
        call _print
        ret

    section .data
        .memory times 15 db 0

    section .text