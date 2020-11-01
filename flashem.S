#Flash leds on Sifive Hifive test board. This will likely work on most HiFive board revs
#This does use the freedom metal compiler environment and won't work unless that is used
#The metal libs and elf requirements/expectations are used. 	

#build it	
#####riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medlow --specs=nano.specs -O0 -g  -Wl,--gc-sections -Wl,-Map,hello.map -nostartfiles -nostdlib -L/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/install/lib/debug/ -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds flashem.S  -Wl,--start-group -lc -lgcc -lm -lmetal -lmetal-gloss -Wl,--end-group -o flashem

#upload it to your target via serial/usb using freedom script
#####scripts/upload --elf hello --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg

	
#pin 19 green
#pin 21 blue
#pin 22 red
	
.equ RED, (1 << 22)
.equ BLUE, (1 << 21)
.equ GREEN, (1 << 19)
	
.section .text
.globl _start
.type _start,@function

_start:

	li a1, RED
	jal sequenceit

	li a1, BLUE
	jal sequenceit

	li a1, GREEN
	jal sequenceit

	j _start

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
	mv t3, x1
	li t0, 0x10012000
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
	li t0, 0x10012000	#base address 	
	mv t1, a1		#color bit
	
	sw t1, 0x08(t0)		#ctrls & port
	sw t1, 0x0C(t0)
	sw t1, 0x40(t0)
	ret

