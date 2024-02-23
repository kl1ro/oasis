ASM=nasm
SRC_DIR=src
BUILD_DIR=build

.PHONY: all build kernel boot truncated clean always

#
#	Build image
#
build: $(BUILD_DIR)/build.img

$(BUILD_DIR)/build.img: always boot kernel truncated
	dd if=/dev/zero of=$(BUILD_DIR)/build.img bs=1024 count=1440
	dd if=$(BUILD_DIR)/truncated.bin of=$(BUILD_DIR)/build.img seek=0 count=1140 conv=notrunc
	rm $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/truncated.bin

#
#	Truncated image
#
truncated: $(BUILD_DIR)/truncated.bin 

$(BUILD_DIR)/truncated.bin: always boot kernel
	cat $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/truncated.bin

#
#	Boot
#
boot: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.bin: always
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

#
#	Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel.asm -f bin -o $(BUILD_DIR)/kernel.bin

#
#	Always
#
always:
	mkdir -p $(BUILD_DIR)
	
#
#	ATA
#
ata:
	mkdir -p $(BUILD_DIR)/ata
	qemu-img create -f raw $(BUILD_DIR)/ata/hdd0.img 1M
	qemu-img create -f raw $(BUILD_DIR)/ata/hdd1.img 1M
	qemu-img create -f raw $(BUILD_DIR)/ata/hdd2.img 1M
	qemu-img create -f raw $(BUILD_DIR)/ata/hdd3.img 1M

#
#	Clean
#
clean:
	rm -rf $(BUILD_DIR)/*