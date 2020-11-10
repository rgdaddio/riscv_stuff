#Simple print and scibble to memory

#build	
#riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_riscv_setup_hifive.s  -o simple_riscv_setup_hifive.o
#riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds --defsym=__heap_max=1 simple_riscv_setup_hifive.o -o simple_riscv_setup_hifive

#Load it onto Riscv HiFive using freedom metal loader (this will print)
#scripts/upload --elf toupper_risc --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg

#View memory with gdb
#scripts/debug --elf simple_riscv_hifive --openocd openocd --gdb riscv64-unknown-elf-gdb --openocd-config bsp/sifive-hifive1/openocd.cfg	
	
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

# Using hardware detection and stack sizing per Hart. Trick code into thinking
# it is going to 'c' when it is really going to Assembly _enter...
	
.global _start
.type _start,@function
_start:
    # setup stacks per hart
   csrr t0, mhartid                # read current hart id
   slli t0, t0, 10                 # shift left the hart id by 1024
   la   sp, stacks + STACK_SIZE    # set the initial stack pointer 
                                   # to the end of the stack space
   add  sp, sp, t0                 # move the current hart stack pointer
                                   # to its place in the stack space

    # park harts with id != 0
    csrr a0, mhartid                # read current hart id
    bnez a0, park                   # if we're not on the hart 0
                                    # we park the hart

    j    _enter                      # jump to c

park:
    wfi
    j park

stacks:
    .skip STACK_SIZE * 4            # allocat


.globl _enter
.type _enter,@function
_enter:							
	jal		inituart			#; initialize the uart
	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; add in the lower
	li 		a2, glen			#; use the const string len
	li		a3, 1				#; set a counter to 1
	li 		a5, MEM_BASE			#; load base of ram 

	
spin:	
	lb		a0, 0(a1)			#; get a byte from greetinn
	sb		a0, 0(a5)			#; stuff the byte in mem (look in debugger)
	jal 		txuart				#; print the byte to uart
	jal             delayit				#; let uart catch up
	beq		a3, a2, done			#; get out if cntr reach len
	addi 		a3, a3, 1			#; incr counter
	addi 		a1, a1, 1			#; incr string pointer 
	addi 		a5, a5, 1			#; incr mem pointer
	j		spin
done:	
	ret


.global txuart
.type txuart,@function
txuart:
	li t3, 0x0
	li t4, UARTBASE		#BASE
	li t5, 0x80000000	#TXFULL
	lw t6, 0(t4)
txloop:	and t3, t5, t6
	bnez t3, txloop
	andi a0, a0, 0x000000FF	#TXDATA
	sw a0, 0(t4)
	li a0, 0
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
	li t5, 160		#SET DIVISOR ~160 on the HiFive rev 1 TX/RX
	sw t5, 0x18(t4)
	ret


.global delayit
.type delayit,@function
delayit:
	mv t2, x0        	#counter
	li t3, 0x25000	 	#some loop time
loop:
	addi t2, t2, 1
	bne t2, t3, loop
	ret	
