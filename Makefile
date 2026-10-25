.DEFAULT_GOAL := all
.PHONY: run clean all tar test-loader

all: build/pete-os.img

build:
	mkdir -p build

build/stage1.bin : boot/stage1.asm | build
	nasm -f bin boot/stage1.asm -o build/stage1.bin

build/stage2.bin: boot/stage2.asm build/kernel.bin | build
	nasm -f bin -D KERNEL_SECTORS=$$(( ($$(wc -c < build/kernel.bin) + 511) / 512 )) boot/stage2.asm -o build/stage2.bin

build/vga.o: kernel/vga.c kernel/vga.h | build
	gcc -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -O2 -c kernel/vga.c -o build/vga.o

build/kprintf.o: kernel/kprintf.c kernel/kprintf.h kernel/vga.h | build
	gcc -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -O2 -c kernel/kprintf.c -o build/kprintf.o

build/main.o: kernel/main.c kernel/vga.h kernel/kprintf.h | build
	gcc -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -O2 -c kernel/main.c -o build/main.o

build/start.o: kernel/start.asm | build
	nasm -f elf32 kernel/start.asm -o build/start.o

build/kernel.elf: build/start.o build/main.o build/vga.o build/kprintf.o kernel/linker.ld | build
	ld -m elf_i386 -T kernel/linker.ld -o build/kernel.elf build/start.o build/main.o build/vga.o build/kprintf.o

build/kernel.bin: build/kernel.elf | build
	objcopy -O binary -j .text -j .rodata -j .data build/kernel.elf build/kernel.bin

build/kernel-sector.bin: build/kernel.bin | build
	@test "$$(wc -c < build/kernel.bin)" -le $$((512 * 1024)) || \
		{ echo "ERROR: kernel exceeds provisional 512 KiB limit"; exit 1; }
	cp build/kernel.bin build/kernel-sector.bin
	truncate -s $$(( (($$(wc -c < build/kernel.bin) + 511 ) / 512) * 512 )) build/kernel-sector.bin

build/pete-os.img: build/stage1.bin build/stage2.bin build/kernel-sector.bin | build
	cat build/stage1.bin build/stage2.bin build/kernel-sector.bin > build/pete-os.img
	truncate -s 1474560 build/pete-os.img

build/main-test.o: kernel/main.c kernel/vga.h kernel/kprintf.h | build
	gcc -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -O2 -DLOADER_TEST -c kernel/main.c -o build/main-test.o

build/kernel-test.elf: build/start.o build/main-test.o build/vga.o build/kprintf.o kernel/linker.ld | build
	ld -m elf_i386 -T kernel/linker.ld -o build/kernel-test.elf build/start.o build/main-test.o build/vga.o build/kprintf.o

build/kernel-test-raw.bin: build/kernel-test.elf | build
	objcopy -O binary -j .text -j .rodata -j .data build/kernel-test.elf build/kernel-test-raw.bin

build/stage2-test.bin: boot/stage2.asm build/kernel-test.bin | build
	nasm -f bin -D KERNEL_SECTORS=34 boot/stage2.asm -o build/stage2-test.bin

build/kernel-test.bin: build/kernel-test-raw.bin | build
	cp build/kernel-test-raw.bin build/kernel-test.bin
	printf '\xA5' | dd of=build/kernel-test.bin bs=1 seek=7680 conv=notrunc
	printf '\x5A' | dd of=build/kernel-test.bin bs=1 seek=16896 conv=notrunc
	truncate -s 17408 build/kernel-test.bin

build/pete-os-test.img: build/stage1.bin build/stage2-test.bin build/kernel-test.bin | build
	cat build/stage1.bin build/stage2-test.bin build/kernel-test.bin > build/pete-os-test.img
	truncate -s 1474560 build/pete-os-test.img

test-loader: build/pete-os-test.img
	NO_AT_BRIDGE=1 GDK_BACKEND=x11 GDK_SCALE=2 \
	qemu-system-i386 -display gtk -drive format=raw,file=build/pete-os-test.img,if=floppy

run: build/pete-os.img
	NO_AT_BRIDGE=1 GDK_BACKEND=x11 GDK_SCALE=1 \
	qemu-system-i386 -display gtk -drive format=raw,file=build/pete-os.img,if=floppy

clean:
	rm -rf build

tar:
	tar --exclude='./.git' \
			--exclude='./build' \
			-cf ../pete-os.tar .
