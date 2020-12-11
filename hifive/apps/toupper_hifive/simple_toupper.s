###riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_riscv_test_driver_hifive.s ../lib/uart_hifive.s ../lib/delay_hifive.s ../lib/pchar_hifive.s ../lib/pstring_hifive.s ../lib/swap_hifive.s ../lib/sort_hifive.s -o simple_riscv_test_driver_hifive.o

###riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds simple_riscv_test_driver_hifive.o -o simple_riscv_test_driver_hifivev2	

	


.equ STACK_SIZE, 1024
.equ MEM_BASE, 0x80000000
.equ MEM_SIZE, 0x4000
.equ ARR_SIZE, 0xa
.equ UARTTX, (1 << 17)
.equ UARTRX, (1 << 16)
.equ GPIOBASE, 0x10012000
.equ UARTBASE, 0x10013000
	

		.section 	.rodata

testgreeting:
		.string "\n\n\tarray_sortxx:\n\t"
	glen = . - testgreeting

testgreetingv:
		.string "\n\n\ttest_sortqqr:\n\t"
		vlen = . - testgreetingv	

makespace:
		.string "\n\t\n"
		slen = . - makespace
	

.align 2 #######2**2	
array_initialized:
.word 0x35,0x33,0x36,0x37,0x32,0x38,0x34,0x31,0x39,0x35	
	

# Using hardware detection and stack sizing per Hart. Trick code into thinking
# it is going to 'c' when it is really going to Assembly _enter...
	
.global _enter
.type _enter,@function
_enter:
	#Thanks to Adventures in RISC-V for this little piece of init code
	#It is not really needed for this level of assembly code but is used
	#in case as a test and just if 'c' is ever needed. Also using _enter quiets the
	#whining linker

	# setup stacks per hart
	csrr t0, mhartid                	# read current hart id
	slli t0, t0, 10                 	# shift left the hart id by 1024
    	

	li sp, MEM_BASE                 	# set the initial stack pointer
	addi sp, sp, STACK_SIZE 
        					# to the end of the stack space
	add  sp, sp, t0                 	# move the current hart stack pointer
        					# to its place in the stack space

						# park harts with id != 0
	csrr a0, mhartid			# read current hart id
	bnez a0, park                   	# if we're not on the hart 0
        				# we park the hart

	jal    _start                      	# jump to assembly _enter

park:
		wfi
		j park

	ret

stacks:
	.skip STACK_SIZE * 4            # allocate


.globl _start
.type _start,@function		
_start:
	sw              ra, -0x60(sp)
	jal		inituart			#; initialize the uart
	jal             delayit
	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; add in the lower
	li 		a2, glen			#; use the const string len
	jal             pstring

	jal             shutdownuart
	li              a3, 0xdeadcafe
	lw              ra, -0x60(sp)
	ret

	
