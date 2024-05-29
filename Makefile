os.img: boot/boot_sect.bin kernel/kernel.bin
	cat $^ > $@

boot/boot_sect.bin: boot/boot_sect.asm
	nasm $^ -f bin -o $@

kernel/kernel.bin: kernel/kernel.asm
	nasm $^ -f bin -o $@
