os.img: boot/boot_sect.bin kernel/kernel.bin
	cat $^ > $@

boot/boot_sect.bin: boot/boot_sect.asm
	nasm $^ -f bin -o $@

kernel/kernel.bin: kernel/kernel.o
	ld -m elf_i386 -Ttext 0x7e00 -o $@ $^ --oformat binary

kernel/kernel.o: kernel/kernel.asm
	nasm $^ -f elf32 -o $@

