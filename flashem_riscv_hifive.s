#Flash leds on Sifive Hifive test board. This will likely work on most HiFive board revs
#This does use the freedom metal environment for some basics and won't work unless that is used
#The freedom metal libs and elf loader requirements/expectations are required.
#Use other examples in the directory if you want to use Spike simulator with more standard syscalls(like write). 	

#Barebones LED flasher and UART test print.
#Assemble and link the old fashioned way
#riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 flashem_riscv_hifive.s -o flashem.o
#riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds flashem.o -o flashem
#scripts/upload --elf flashem --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg	
	
#Using GCC instead of assembler and linker	
#####riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medlow --specs=nano.specs -O0 -g  -Wl,--gc-sections -Wl,-Map,hello.map -nostartfiles -nostdlib -L/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/install/lib/debug/ -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds flashem.S  -Wl,--start-group -lc -lgcc -lm -lmetal -lmetal-gloss -Wl,--end-group -o flashem

#upload it to your target via serial/usb using freedom script
#####scripts/upload --elf flashem --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg

	
	
#pin 19 green
#pin 21 blue
#pin 22 red
	
.equ RED, (1 << 22)
.equ BLUE, (1 << 21)
.equ GREEN, (1 << 19)
.equ UARTTX, (1 << 17)
.equ UARTRX, (1 << 16)
.equ GPIOBASE, 0x10012000
.equ UARTBASE, 0x10013000	
	
.section .text
.globl _start
.type _start,@function

_start:
	jal inituart

repeat:	
	li a1, RED
	jal sequenceit

	li a1, BLUE
	jal sequenceit

	li a1, GREEN
	jal sequenceit

	jal txuart

	j repeat

.global sequenceit
.type sequenceit,@function
sequenceit:
	addi sp, sp, 16 	#get some stack
	sw ra, 0(sp)		#save the return address (for nested funcs)
	jal flashit
	jal delayit
	jal clearit
	lw ra, 0(sp)		#get the return address of caller(_start)
	addi sp, sp, -16
	ret
	
.global clearit
.type clearit,@function
clearit:
	li t0, GPIOBASE
	li t1, 0x000000 	#pin clear it

	sw t1, 0x08(t0)		#ctrls & port
	sw t1, 0x0C(t0)
	sw t1, 0x40(t0)
	ret

.global delayit
.type delayit,@function
delayit:
	mv t2, x0        	#counter
	li t3, 0x500000 	#some loop time
loop:
	addi t2, t2, 1
	bne t2, t3, loop
	ret

.global flashit
.type flashit,@function
flashit:
	li t0, GPIOBASE		#base address 	
	mv t1, a1		#color bit
	
	sw t1, 0x08(t0)		#ctrls & port
	sw t1, 0x0C(t0)
	sw t1, 0x40(t0)
	ret


.global inituart
.type inituart,@function
inituart:
#GPIO section	
	li t4, GPIOBASE 	#GPIO BASE
	lw t5, 0x38(t4)		#GPIO OUTPUT ENABLE
	li t6, UARTRX		#RX BIT
	or t5, t5, t6
	li t6, UARTTX		#TX BIT
	or t5, t5, t6
	sw t5, 0x38(t4)		#END RMW
#UART section
	li t4, UARTBASE		#UART BASE
	sw x0, 0x10(t4)		#DISABLE INTRPTS
	lw t5, 0x08(t4)		
	ori t5, t5, 0x1		#ENABLE TX
	sw t5, 0x08(t4)
	lw t5, 0x0C(t4)		#RX
	ori t5, t5, 0x1 	#ENABLE RX
	sw t5, 0x0c(t4)
	li t5, 160		#SET DIVISOR ~160 on the HiFive rev 1
	sw t5, 0x18(t4)
	ret

.global txuart
.type txuart,@function
txuart:
	li a0, 0x46
	li t3, 0x0
	li t4, UARTBASE		#BASE
	li t5, 0x80000000	#TXFULL
	lw t6, 0(t4)
txloop:	and t3, t5, t6
	bnez t3, txloop
	andi a0, a0, 0x000000FF	#TXDATA
	
#Hand craft FLASHEM print message####################	
	sw a0, 0(t4)
	li a0, 0x4C
	sw a0, 0(t4)
	li a0, 0x41
	sw a0, 0(t4)
	li a0, 0x53
	sw a0, 0(t4)
	li a0, 0x48
	sw a0, 0(t4)
	li a0, 0x45
	sw a0, 0(t4)
	li a0, 0x4d
	sw a0, 0(t4)
	li a0, 0x0a
	sw a0, 0(t4)
#####################################################	
	ret
