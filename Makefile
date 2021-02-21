include config.make

main.img: Makefile src/Makefile
	$(MAKE) -C src main.img
	$(PYTHON) -m Scripts copy main.img src/main.img
	$(RM) src/main.img


.PHONY:run
run: Makefile main.img
	qemu-img convert -f raw -O qcow2 main.img main_qemu.img
	qemu-system-i386 -hda main_qemu.img -boot c -m 32
	$(RM) main_qemu.img


.PHONY:clean
clean: Makefile
	$(MAKE) -C src/ clean


.PHONY:src_only
clean_src_only: Makefile
	$(MAKE) clean
	$(RM) main.img