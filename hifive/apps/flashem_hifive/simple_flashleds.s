#Flash leds on Sifive Hifive test board and print to terminal. This will likely work on most HiFive board revs
#This does use the freedom metal environment for some basics and won't work unless that is used
#The freedom metal libs and elf loader requirements/expectations are needed.
#Use other examples in the toplevel dir if you want to use Spike simulator with more standard syscalls(like write).	 

#Barebones LED flasher and UART test print.
#Assemble and link the old fashioned way
#riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 flashem_riscv_hifive.s -o flashem.o
#riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds flashem.o -o flashem
#scripts/upload --elf flashem --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg

#now requires libs see Makefile standalone version is in ../../../hifive	
	
#Using GCC instead of assembler and linker	
#####riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medlow --specs=nano.specs -O0 -g  -Wl,--gc-sections -Wl,-Map,hello.map -nostartfiles -nostdlib -L/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/install/lib/debug/ -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds flashem.S  -Wl,--start-group -lc -lgcc -lm -lmetal -lmetal-gloss -Wl,--end-group -o flashem

#upload it to your target via serial/usb using freedom metal loader script
#####scripts/upload --elf flashem --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg


#RGD 2020	
	
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

.equ STACK_SIZE, 1024
.equ MEM_BASE, 0x80000000
.equ MEM_SIZE, 0x4000
.equ ARR_SIZE, 0xa	


	.section 	.rodata	
flash_array_initialized:
	.word 0x46,0x4C,0x41,0x53,0x48,0x45,0x4d,0x0a

	

	.section 	.init

.globl _enter
.type _enter,@function
_enter:
	j _start
	ret


	.section	.data
live_arry:	
	.word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0	


	.section 	.text
	
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

	jal flashem_lprint

	j repeat

.global sequenceit
.type sequenceit,@function
sequenceit:
	addi sp, sp, -16 	#get some stack
	sw ra, 0(sp)		#save the return address (for nested funcs)
	jal flashit
	jal delayit
	jal clearit
	lw ra, 0(sp)		#get the return address of caller(_start)
	addi sp, sp, 16
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


.global flashit
.type flashit,@function
flashit:
	li t0, GPIOBASE		#base address 	
	mv t1, a1		#color bit
	
	sw t1, 0x08(t0)		#ctrls & port
	sw t1, 0x0C(t0)
	sw t1, 0x40(t0)
	ret


.global flashem_lprint
.type flashem_lprint,@function
flashem_lprint:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
	sw   s5, 0xc(sp)
	
	lui             a1, %hi(flash_array_initialized)
	addi            a1, a1, %lo(flash_array_initialized)
	li 		s4, MEM_BASE

	li              s2, 0
	li              s3, 0xa

lwalk:							#; walk the string in rodata and push into ram
	lb              a0, 0(a1)
	sb              a0, 0(s4)
	mv              s5, a0
	jal             pchar

	addi            a1, a1, 4                       #; increment counters mems are byte(4) index (1)
	addi            s4, s4, 4
	addi            s2, s2, 1

	bne             s5, s3, lwalk               
							#; get the return address of caller(_start)
	lw   s5, 0xc(sp)
	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret



	
