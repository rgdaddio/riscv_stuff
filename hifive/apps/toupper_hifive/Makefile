LIB = ../../../lib/
TOOLS = /opt/riscvNewlib/bin/
HOME = /home/rich/new_risc5/

all: toupper_hifive
	cp toupper_hifive $(HOME)freedom/freedom-e-sdk
toupper_hifive: test_driver_hifive.o
	$(TOOLS)riscv32-unknown-elf-ld -T$(HOME)freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds --defsym=__heap_max=1 test_driver_hifive.o -o toupper_hifive

test_driver_hifive.o: simple_toupper_riscv_hifive.s $(LIB)uart_hifive.s $(LIB)/delay_hifive.s $(LIB)pchar_hifive.s
	$(TOOLS)/riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_toupper_riscv_hifive.s $(LIB)uart_hifive.s $(LIB)delay_hifive.s $(LIB)pchar_hifive.s -o test_driver_hifive.o

clean:
	 rm test_driver_hifive.o toupper_hifive
