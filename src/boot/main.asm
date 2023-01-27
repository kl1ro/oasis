org 0x7c00
bits 16

jmp short _start
nop

;
; This is FAT12 Header
;
bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'AsmFunOs64b'        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes

_start:
	mov ax, 0				; Setup the data segments
	mov ds, ax
	mov es, ax

	mov ss, ax				; Setup stack
	mov sp, 0x7c00

	; Note: Bios should put drive number to the 
        ; dl register automatically
        mov [ebr_drive_number], dl

	; Change video mode via bios interruption	
	mov ah, 00h
	mov al, 01eh
	int 10h	

	; Clear screen
	mov ah, 05h
	mov al, 01h
	int 10h
	
	; Print os name to the screen
	mov si, osName
        call _printText
        mov bh, 01h
        call _newLine
	
	; Calculating lba adress of the kernel
	; First of all read fat directory
	; Lba of root directory = reserved + fats * sectors per fat
	mov ax, [bdb_sectors_per_fat]
	mov bx, [bdb_fat_count]
	mul bl 					; ax = fats * sectors per fat
	add ax, [bdb_reserved_sectors]

	; Using si as a buffer is more efficient 
	; than pushing into stack I guess
	; Also need to store dx in di 
	; to save the drive number
	mov si, ax		
	mov di, dx	
	
	; Now we need to compute the size of the root directory
	; It = (32 * numbers_of_entries) / bytes_per_sector
	mov ax, [bdb_sectors_per_fat]
	shl ax, 5				; ax *= 32
	xor dx, dx
	div word [bdb_bytes_per_sector]
	test dx, dx;				
	jz _root_dir_read		
	
	; Division remainder != 0 
	; meaning we have a sector only partially filled with entries
	inc ax					; if(dx == 0) ax++;

_root_dir_read:
	; Read root directory after calculation 
	; of its position in memory	
	mov cl, al
	
	; Treat that as a pop instruction
	; I just move info from the buffer 
	; which is si now
	mov ax, si	
	mov dx, di
	
	; We saved this previously from bios
	mov bx, buffer 				; es:bx is a buffer
	call _diskLoad

	; Next we need to search for
	; the kernel.bin file
	xor bx, bx
	mov di, buffer

_search_kernel_cycle:
	mov si, Kernel.bin
	mov cx, 11	
	mov ax, di
	repe cmpsb
	mov di, ax
	je _kernelFound
	
	; Unfortunately haven't found our kernel yet
	; Note: ax is a buffer now
	add di, 32
	inc bx
	cmp bx, [bdb_dir_entries_count]
	jl _search_kernel_cycle

	; There's no kernel.bin on a disk
	jmp _kernelNotFound
	

_kernelFound:	
	; Now di has the address of the entry
	mov ax, [di + 26]
	mov [kernelCluster], ax	

	; Read the FAT from disk into ram
	; Note: dl still is a drive number 
        ; we don't need to restore it
	mov ax, [bdb_reserved_sectors]
	mov bx, buffer
	mov cl, [bdb_sectors_per_fat] 
	call _diskLoad

	; Read kernel and process the FAT chain
	mov bx, 0x2000
	mov es, bx
	xor bx, bx
_loadKernelLoop:
	; Read the next cluster
	mov ax, [kernelCluster]
	
	; ToDo: fix this hardcoded value
	add ax, 31		; first cluster = (kernel cluster - 2) * sectors_per_cluster + start_sector
				; start sector = reserved + fats + directory size = 1 + 18 + 134 = 153
	mov cl, 1
	call _diskLoad 
	
	xor dx, dx
	mov ax, [kernelCluster]
	mov cx, 3
	mul cl
	mov cx, 2
	div cx			; ax = index of entry in FAT, dx = cluster mod 2
	
	mov si, buffer
	add si, ax
	mov ax, [ds:si]
	test dx, dx
	jnz _loadKernelLoopOdd

_loadKernelLoopEven:
	and ax, 0x0FFF
	jmp _nextClusterAfter

_loadKernelLoopOdd:
	shr ax, 4

_nextClusterAfter:
	cmp ax, 0x0FF8		; 0x0FF8 is the end of the chain
	jae _readComplete
	mov [kernelCluster], ax	
	jmp _loadKernelLoop

_readComplete:
	mov dx, [ebr_drive_number]
	mov ax, 0x2000
	mov ds, ax
	mov es, ax
	jmp 0x2000:0x0
	jmp _waitForKeyAndReboot

_kernelNotFound:
	jmp _waitForKeyAndReboot	

%include "../../Headers16bit/HaltMachine/main.asm"
%include "../../Headers16bit/WaitForKeyAndReboot/main.asm"
%include "../../Headers16bit/LbaToChs/main.asm"
%include "../../Headers16bit/PrintText/main.asm"
%include "../../Headers16bit/DiskLoad/main.asm"
%include "../../Headers64bit/Break/main.asm"
%include "../../Headers16bit/NewLine/main.asm"
	
; Global variables
osName db "AsmFun Operating System 64-bit", 0
Kernel.bin db 'KERNEL  BIN'
kernelCluster dw 0

%include "../../Headers16bit/DiskLoadRes/main.asm"

times 510-($-$$) db 0			; Pad remainder of boot sector with 0s
dw 0xaa55				; The standard PC boot signature
buffer:
