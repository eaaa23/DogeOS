include config.make

main.img: Makefile src/Makefile FORCE
	$(MAKE) -C src main.img
	$(PYTHON) -m Scripts copy main.img src/main.img
	$(RM) src/main.img


.PHONY:run
run: Makefile main.img
	qemu-img convert -f raw -O qcow2 main.img main_qemu.img
	qemu-system-i386 -fda main_qemu.img -boot a -m 32
	$(RM) main_qemu.img

rerun: Makefile
	$(MAKE) clean_src_only
	$(MAKE) main.img
	$(MAKE) run

.PHONY:clean
clean: Makefile
	$(MAKE) -C src/ clean


.PHONY:src_only
clean_src_only: Makefile
	$(MAKE) clean
	$(RM) main.img

.PHONY:FORCE
FORCE:;