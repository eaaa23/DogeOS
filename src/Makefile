include ../config.make

main.img: Makefile ipl.bin sipl/sipl.bin main/os.bin
	$(PYTHON) ../Scripts/main.py dogefs createEmpty 65536 main.img ipl.bin sipl/sipl.bin main/os.bin

ipl.bin : Makefile ipl.asm
	$(ASM) ipl.asm -o ipl.bin -l ipl.lst

sipl/sipl.bin: Makefile sipl/Makefile FORCE
	$(MAKE) -C sipl sipl.bin

main/os.bin: Makefile main/Makefile FORCE
	$(MAKE) -C main os.bin
#$(PYTHON) -m Scripts copy /Volumes/DATA/Dev/main.img main.img

.PHONY:clean
clean:
	$(MAKE) -C sipl/ clean
	$(MAKE) -C main/ clean
	$(RM) ipl.bin ipl.lst


.PHONY:FORCE
FORCE:;