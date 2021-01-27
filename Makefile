ARCH = armv7-a
MCPU = cortex-a8

TARGET = rvpb

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./moduOS.ld
MAP_FILE = build/moduOS.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

VPATH = boot 			\
		hal/$(TARGET)	\
		lib

C_SRCS  = $(notdir $(wildcard boot/*.c))
C_SRCS += $(notdir $(wildcard hal/$(TARGET)/*.c))
C_SRCS += $(notdir $(wildcard lib/*.c))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))

INC_DIRS  = -I include			\
			-I hal				\
			-I hal/$(TARGET) 	\
			-I lib

CFLAGS = -c -g -std=c11

LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

moduOS = build/moduOS.axf
moduOS_bin = build/moduOS.bin

.PHONY: all clean run debug gdb

all: $(moduOS)

clean:
	@rm -fr build

run: $(moduOS)
	qemu-system-arm -M realview-pb-a8 -kernel $(moduOS) -nographic

debug: $(moduOS)
	qemu-system-arm -M realview-pb-a8 -kernel $(moduOS) -S -gdb tcp::1234,ipv4

gdb:
	gdb-multiarch

$(moduOS): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(moduOS) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(moduOS) $(moduOS_bin)

build/%.os: %.S 
	mkdir -p $(shell dirname $@)
	$(CC) -mcpu=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<

build/%.o: %.c 
	mkdir -p $(shell dirname $@)
	$(CC) -mcpu=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<
