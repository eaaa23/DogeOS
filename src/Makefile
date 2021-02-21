include config.make

main.img: Makefile ipl.bin sipl.bin os.bin
	$(PYTHON) -m Scripts dogefs createEmpty 65536 main.img ipl.bin sipl.bin os.bin

ipl.bin : Makefile src/ipl.asm
	$(ASM) src/ipl.asm -o ipl.bin -l ipl.lst

sipl.bin: Makefile src/sipl/Makefile FORCE
	$(MAKE) -C src/sipl sipl.bin
	$(PYTHON) -m Scripts copy sipl.bin src/sipl/sipl.bin

os.bin: Makefile src/main/Makefile FORCE
	$(MAKE) -C src/main os.bin

%.o : Makefile ./src/%/Makefile FORCE
	$(MAKE) -C src/%




.PHONY:run
run: Makefile main.img
	qemu-img convert -f raw -O qcow2 main.img main_qemu.img
	qemu-system-i386 -hda main_qemu.img -boot c -m 32
#$(PYTHON) -m Scripts copy /Volumes/DATA/Dev/main.img main.img

.PHONY:clean
clean: Makefile
	$(MAKE) -C src/sipl/ clean
	$(RM) main_qemu.img cmain.bin empty.bin head.bin ipl.bin sipl.bin ipl.lst

src_only: Makefile
	$(MAKE) clean
	$(RM) main.img

.PHONY:FORCE
FORCE:;