include config.make

main.img: Makefile ipl.bin sipl.bin
	$(PYTHON) -m Scripts dogefs createEmpty 65536 main.img ipl.bin sipl.bin

ipl.bin : Makefile src/ipl.asm
	$(ASM) src/ipl.asm -o ipl.bin -l ipl.lst

sipl.bin: Makefile src/sipl/Makefile FORCE
	$(MAKE) -C src/sipl sipl.bin
	$(PYTHON) -m Scripts copy sipl.bin src/sipl/sipl.bin

%.o : Makefile ./src/%/Makefile FORCE
	$(MAKE) -C src/%




.PHONY:run
run: Makefile main.img
	$(PYTHON) -m Scripts copy /Volumes/DATA/Dev/main.img main.img

.PHONY:clean
clean: Makefile
	$(MAKE) -C src/sipl/ clean
	$(RM) main.img cmain.bin empty.bin head.bin ipl.bin sipl.bin ipl.lst

.PHONY:FORCE
FORCE:;