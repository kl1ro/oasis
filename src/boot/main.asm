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
ebr_volume_label:           db 'AsmFunOs   '        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes

_start:
	mov ax, 0				; Setup the data segments
	mov ds, ax
	mov es, ax

	mov ss, ax				; Setup stack
	mov sp, 0x7c00

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

	; Print starting text to a screen
	mov si, startOs
	call _printText
	mov bh, 01h
	call _newLine

	; Reading from a floppy via Bios interruption
	; Note: Bios should put drive number to the 
	; dl register automatically
	mov [ebr_drive_number], dl
	mov ax, 1
	mov cl, 1	
	mov bx, 0xc7e00
	call _diskLoad	
	mov si, diskLoadComplete
	call _printText	
	mov bh, 01h
	call _newLine
		
	; Jumping into the 32-bit protected mode
	mov si, switch
	call _printText
	jmp _haltMachine

%include "../../Headers16bit/HaltMachine/main.asm"
%include "../../Headers16bit/WaitForKeyAndReboot/main.asm"
%include "../../Headers16bit/LbaToChs/main.asm"
%include "../../Headers16bit/PrintText/main.asm"
%include "../../Headers16bit/DiskLoad/main.asm"
%include "../../Headers64bit/Break/main.asm"
%include "../../Headers16bit/NewLine/main.asm"
	
; Global variables
osName db "AsmFun Operating System 64-bit", 0
startOs db "Booting system from a disk...", 0
switch db "Making a switch to 32-bit PM... ", 0
switchComplete db "Switch to 32-bit is complete!", 0

%include "../../Headers16bit/DiskLoadRes/main.asm"

times 510-($-$$) db 0			; Pad remainder of boot sector with 0s
dw 0xaa55				; The standard PC boot signature

