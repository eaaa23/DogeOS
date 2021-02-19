include ../../config.make

sipl.bin: Makefile ipl2.bin sipl0.bin siplmain.bin
	$(PYTHON) ../../Scripts/main.py copy sipl.bin ipl2.bin sipl0.bin siplmain.bin

ipl2.bin: ipl2.asm
	$(ASM) ipl2.asm -o ipl2.bin -l ipl2.lst

sipl0.bin: sipl.asm
	$(ASM) sipl.asm -o sipl0.bin -l sipl.lst

siplmain.s: siplmain.c
	$(CC) -S siplmain.c -o siplmain.s

siplmain.bin: siplmain.s
	$(AS) siplmain.s -o siplmain.bin

clean:
	$(RM) ipl2.bin sipl.bin sipl0.bin siplmain.s siplmain.bin
	$(RM) ipl2.lst sipl.lst