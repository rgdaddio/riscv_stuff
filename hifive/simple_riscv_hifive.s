#Take a short hello string and print it with the hifive UART. Just a little test to work out the uart interface

#build	
#riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_riscv_hifive.s  -o simple_riscv_hifive.o
#riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds --defsym=__heap_max=1 simple_riscv_hifive.o -o simple_riscv_hifive

#Load it onto Riscv HiFive using freedom metal loader or debug it
#scripts/upload --elf simple_riscv_hifive --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg	
	
.equ UARTTX, (1 << 17)
.equ UARTRX, (1 << 16)
.equ GPIOBASE, 0x10012000
.equ UARTBASE, 0x10013000
.equ STACK_SIZE, 1024
.equ MEM_BASE, 0x80000000
.equ MEM_SIZE, 0x4000	

	.section 	.rodata

testgreeting:
		.string "\nhellostring\n"
		glen = . - testgreeting

.section .text
	

.globl _start
.type _start,@function
_start:

	jal inituart
	jal delayit

	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; or in the lower 16
	li		a2, glen
	li 		a3, 0x1
spin:
	lb		a0, 0(a1)
	jal 		txuart
	jal             delayit
	beq		a3, a2, done
	addi 		a3, a3, 1
	addi 		a1, a1, 1
	j		spin
done:
	ret

.global txuart
.type txuart,@function
txuart:
	li 		t3, 0x0
	li 		t4, UARTBASE		#BASE
	li 		t5, 0x80000000	#TXFULL
	lw 		t6, 0(t4)
txloop:	and 		t3, t5, t6
	bnez 		t3, txloop
	andi 		a0, a0, 0x000000FF	#TXDATA
	sw 		a0, 0(t4)
	li 		a0, 0
	ret

.global inituart
.type inituart,@function
inituart:
#GPIO section	
	li 		t4, GPIOBASE 		#GPIO BASE
	lw 		t5, 0x38(t4)		#GPIO OUTPUT ENABLE
	li 		t6, UARTRX		#RX BIT
	or 		t5, t5, t6
	li 		t6, UARTTX		#TX BIT
	or 		t5, t5, t6
	sw 		t5, 0x38(t4)		#END RMW
#UART section
	li 		t4, UARTBASE		#UART BASE
	sw 		x0, 0x10(t4)		#DISABLE INTRPTS
	lw 		t5, 0x08(t4)		
	ori 		t5, t5, 0x1		#ENABLE TX
	sw 		t5, 0x08(t4)
	lw 		t5, 0x0C(t4)		#RX
	ori 		t5, t5, 0x1 		#ENABLE RX
	sw 		t5, 0x0c(t4)
	li 		t5, 160			#SET DIVISOR ~10 on the HiFive rev 1 TX/RX
	sw 		t5, 0x18(t4)
	ret


.global delayit
.type delayit,@function
delayit:
	mv 		t2, x0        		#counter
	li 		t3, 0x25000	 	#some loop time
loop:
	addi 		t2, t2, 1
	bne 		t2, t3, loop
	ret	
