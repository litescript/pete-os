.PHONY: run clean

build:
	mkdir -p build

build/stage1.bin : boot/stage1.asm | build
	nasm -f bin boot/stage1.asm -o build/stage1.bin

build/stage2.bin: boot/stage2.asm | build
	nasm -f bin boot/stage2.asm -o build/stage2.bin

build/pete-os.img: build/stage1.bin build/stage2.bin | build
	cat build/stage1.bin build/stage2.bin > build/pete-os.img

run: build/pete-os.img
	qemu-system-i386 -drive format=raw,file=build/pete-os.img,if=floppy

clean:
	rm -rf build
