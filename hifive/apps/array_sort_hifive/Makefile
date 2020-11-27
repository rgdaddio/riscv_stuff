LIB = ../../../lib/
TOOLS = /opt/riscvNewlib/bin/
HOME = /home/rich/new_risc5/

all: array_sort_hifive
	cp array_sort_hifive $(HOME)/freedom/freedom-e-sdk
array_sort_hifive: test_driver_hifive.o
	$(TOOLS)riscv32-unknown-elf-ld -T$(HOME)freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds --defsym=__heap_max=1 test_driver_hifive.o -o array_sort_hifive

test_driver_hifive.o: simple_array_sort.s $(LIB)uart_hifive.s $(LIB)/delay_hifive.s $(LIB)pchar_hifive.s $(LIB)pstring_hifive.s $(LIB)swap_hifive.s $(LIB)sort_hifive.s
	$(TOOLS)/riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_array_sort.s $(LIB)uart_hifive.s $(LIB)delay_hifive.s $(LIB)pchar_hifive.s $(LIB)pstring_hifive.s $(LIB)swap_hifive.s $(LIB)sort_hifive.s -o test_driver_hifive.o

clean:
	 rm test_driver_hifive.o array_sort_hifive
