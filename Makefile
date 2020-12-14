ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./moduOS.ld

ASM_SRCS = $(wildcard boot/*.s)
ASM_OBJS = $(patsubst boot/%.s, build/%.o, $(ASM_SRCS))

moduOS = build/moduOS.axf
moduOS_bin = build/moduOS.bin

.PHONY: all clean run debug gdb

all: $(moduOS)

clean:
	@rm -fr build

run: $(moduOS)
	qemu-system-arm -M realview-pb-a8 -kernel $(moduOS)

debug: $(moduOS)
	qemu-system-arm -M realview-pb-a8 -kernel $(moduOS) -S -gdb tcp::1234,ipv4

gdb:
	gdb-multiarch

$(moduOS): $(ASM_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(moduOS) $(ASM_OBJS)
	$(OC) -O binary $(moduOS) $(moduOS_bin)

build/%.o: boot/%.s
	mkdir -p $(shell dirname $@)
	$(AS) -march=$(ARCH) -mcpu=$(MCPU) -g -o $@ $<
