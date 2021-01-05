#Take a short hello string and uppperized it. Just a little test to work out the uart interface

#build	
#riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 toupper_risc.s  -o toupper_risc.o
#riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds --defsym=__heap_max=1 toupper_risc.o -o toupper_risc

#Load it onto Riscv HiFive using freedom metal loader
#scripts/upload --elf toupper_risc --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg	


###Note sometimes the UART goes out to lunch and board needs a reboot for UPPER'd string to print.
	
.equ UARTTX, (1 << 17)
.equ UARTRX, (1 << 16)
.equ GPIOBASE, 0x10012000
.equ UARTBASE, 0x10013000
.section 	.rodata
	
testgreeting:
	                .string "hellostring\n"
	                glen = . - testgreeting

#basicteststr:
#	                .string "@Rte|st\n"
#	                len = .- basicteststr

#resultstr:
#	                .string " is the upper version\n"
#	                rlen = . - resultstr

space: .ascii "\t"
#	splen = . - endLine	

.section		.text

	                .global _start                  #;set up a start routine
	                .type _start, @function

_start:


	
	###########################################
	###########Initialize gp register##########
#	.option push
#	.option norelax
#	1:auipc gp, %pcrel_hi(__global_pointer$)
#	addi  gp, gp, %pcrel_lo(1b)
#	.option pop
#	.option relax
	###########################################

	jal inituart
#again:	
	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; or in the lower 16
	li		a2, glen
	mv 		a6, a1
	la              s3, space
	lb 		a0, 0(s3)
	jal             pchar
	li 		a3, 0x0
spin:
	lb 		a4, 0(a1)
	mv 		a0, a4

	jal 		txuart
	jal             delayit
	beq		a3, a2, done
	addi 		a3, a3, 1
	addi 		a1, a1, 1
	j		spin
done:
	jal upperizeit
#	j again 				#keep looping
	ret

.global upperizeit
.type upperizeit,@function
upperizeit:
	lb 		a4, 0(a6)
	mv 		a0, a4
	li 		a3, 0x0
	
	li 		a7, 0xa
	beq 		a0, a7, finish
	li 		a7, 0x61
	blt		a0, a7, finish
	li		a7, 0x7a
	bgt		a0, a7, finish
	addi 		a0, a0, -0x20
	addi 		sp, sp, 16
	sw 		ra, 0(sp)	
	jal 		txuart
	jal             delayit
	lw 		ra, 0(sp)		#get the return address of caller(_start)
	addi 		sp, sp, -16
	addi 		a6, a6, 1
	j 		upperizeit
finish:	
	ret
