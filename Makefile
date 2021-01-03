ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./moduOS.ld
MAP_FILE = build/moduOS.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

C_SRCS = $(wildcard boot/*.c)
C_OBJS = $(patsubst boot/%.c, build/%.o, $(C_SRCS))

INC_DIRS = include

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

$(moduOS): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(moduOS) $(ASM_OBJS) $(C_OBJS) -Map=$(MAP_FILE)
	$(OC) -O binary $(moduOS) $(moduOS_bin)

build/%.os: $(ASM_SRCS) 
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I$(INC_DIRS) -c -g -o $@ $<

build/%.o: $(C_SRCS) 
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I$(INC_DIRS) -c -g -o $@ $<
