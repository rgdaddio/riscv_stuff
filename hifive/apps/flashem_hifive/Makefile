LIB = ../../../lib/
TOOLS = /opt/riscvNewlib/bin/
HOME = /home/rich/new_risc5/

all: flashem_hifive
	cp flashem_hifive $(HOME)freedom/freedom-e-sdk

flashem_hifive: test_driver_hifive.o
	$(TOOLS)riscv32-unknown-elf-ld -T$(HOME)freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds test_driver_hifive.o -o flashem_hifive

test_driver_hifive.o: simple_flashleds.s $(LIB)uart_hifive.s $(LIB)/delay_hifive.s $(LIB)pchar_hifive.s
	$(TOOLS)/riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_flashleds.s $(LIB)uart_hifive.s $(LIB)delay_hifive.s $(LIB)pchar_hifive.s -o test_driver_hifive.o

clean:
	 rm test_driver_hifive.o flashem_hifive
