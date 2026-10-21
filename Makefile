.DEFAULT_GOAL := all
.PHONY: run clean all tar

all: build/pete-os.img

build:
	mkdir -p build

build/stage1.bin : boot/stage1.asm | build
	nasm -f bin boot/stage1.asm -o build/stage1.bin

build/stage2.bin: boot/stage2.asm build/kernel.bin | build
	nasm -f bin -D KERNEL_SECTORS=$$(( ($$(wc -c < build/kernel.bin) + 511) / 512 )) boot/stage2.asm -o build/stage2.bin

build/main.o: kernel/main.c | build
	gcc -m32 -ffreestanding -fno-pie -fno-pic -O2 -c kernel/main.c -o build/main.o

build/start.o: kernel/start.asm | build
	nasm -f elf32 kernel/start.asm -o build/start.o

build/kernel.elf: build/start.o build/main.o kernel/linker.ld | build
	ld -m elf_i386 -T kernel/linker.ld -o build/kernel.elf build/start.o build/main.o

build/kernel.bin: build/kernel.elf | build
	objcopy -O binary -j .text -j .rodata -j .data build/kernel.elf build/kernel.bin

build/kernel-sector.bin: build/kernel.bin | build
	cp build/kernel.bin build/kernel-sector.bin
	truncate -s $$(( (($$(wc -c < build/kernel.bin) + 511 ) / 512) * 512 )) build/kernel-sector.bin

build/pete-os.img: build/stage1.bin build/stage2.bin build/kernel-sector.bin | build
	cat build/stage1.bin build/stage2.bin build/kernel-sector.bin > build/pete-os.img

run: build/pete-os.img
	NO_AT_BRIDGE=1 GDK_BACKEND=x11 GDK_SCALE=2 \
	qemu-system-i386 -display gtk -drive format=raw,file=build/pete-os.img,if=floppy

clean:
	rm -rf build

tar:
	tar --exclude='./.git' \
			--exclude='./build' \
			-cf ../pete-os.tar .
