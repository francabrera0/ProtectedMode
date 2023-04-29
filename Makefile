img = ./img
out = ./out
elf = ./elf

all: protected protectedMacro

protected: $(img)/protectedMode.img
$(img)/protectedMode.img: $(elf)/protectedMode.elf
	mkdir -p $(img)/
	objcopy -O binary $^ $@

$(elf)/protectedMode.elf: linker.ld $(out)/protectedMode.o 
	mkdir -p $(elf)/
	ld -melf_i386 -nostdlib -o $@ -T $^

$(out)/protectedMode.o: protectedMode.S
	mkdir -p $(out)/
	gcc -m32 -c -ggdb3 -o $@ $^

protectedMacro: $(img)/protectedModeMacro.img
$(img)/protectedModeMacro.img: $(elf)/protectedModeMacro.elf
	mkdir -p $(img)/
	objcopy -O binary $^ $@

$(elf)/protectedModeMacro.elf: linker.ld $(out)/protectedModeMacro.o 
	mkdir -p $(elf)/
	ld -melf_i386 -nostdlib -o $@ -T $^

$(out)/protectedModeMacro.o: protectedModeMacro.S
	mkdir -p $(out)/
	gcc -m32 -c -ggdb3 -o $@ $^

test:
	qemu-system-x86_64 -fda ./img/protectedMode.img

testMacro:
	qemu-system-x86_64 -fda ./img/protectedModeMacro.img

debug:
	gnome-terminal --title=qemu -- qemu-system-i386 -fda ./img/protectedMode.img -boot a -s -S -monitor stdio
	gnome-terminal --title=gdb -- gdb --eval-command="target remote localhost:1234"

clean:
	rm -rf $(img)/ $(out)/ $(elf)/