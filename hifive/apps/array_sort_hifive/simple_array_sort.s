###riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 simple_riscv_test_driver_hifive.s ../lib/uart_hifive.s ../lib/delay_hifive.s ../lib/pchar_hifive.s ../lib/pstring_hifive.s ../lib/swap_hifive.s ../lib/sort_hifive.s -o simple_riscv_test_driver_hifive.o

###riscv32-unknown-elf-ld -T/home/rich/new_risc5/freedom/freedom-e-sdk/bsp/sifive-hifive1/metal.default.lds simple_riscv_test_driver_hifive.o -o simple_riscv_test_driver_hifivev2	

	


.equ STACK_SIZE, 1024
.equ MEM_BASE, 0x80000000
.equ MEM_SIZE, 0x4000
.equ ARR_SIZE, 0xa	

		.section 	.rodata

testgreeting:
		.string "\narray_sort:\n\t"
		glen = . - testgreeting

makespace:
		.string "\n\t\n"
		slen = . - makespace
	

.align 2 #######2**2	
array_initialized:
.word 0x35,0x33,0x36,0x37,0x32,0x38,0x34,0x31,0x39,0x35	
	

# Using hardware detection and stack sizing per Hart. Trick code into thinking
# it is going to 'c' when it is really going to Assembly _enter...
	
.global _start
.type _start,@function
_start:
	#Thanks to Adventures in RISC-V for this little piece of init code
	#It is not really needed for this level of assembly code but is used
	#in case as a test and just if 'c' is ever needed. Also using _enter quiets the
	#whining linker

	# setup stacks per hart
   csrr t0, mhartid                	# read current hart id
   slli t0, t0, 10                 	# shift left the hart id by 1024
   la   sp, stacks + STACK_SIZE    	# set the initial stack pointer 
        				# to the end of the stack space
   add  sp, sp, t0                 	# move the current hart stack pointer
        				# to its place in the stack space

    # park harts with id != 0
    csrr a0, mhartid			# read current hart id
    bnez a0, park                   	# if we're not on the hart 0
        				# we park the hart

    j    _enter                      	# jump to assembly _enter

park:
		wfi
		j park

stacks:
	.skip STACK_SIZE * 4            # allocate


.globl _enter
.type _enter,@function
		
_enter:							
	jal		inituart			#; initialize the uart
	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; add in the lower
	li 		a2, glen			#; use the const string len
	jal             pstring

	lui             a1, %hi(array_initialized)
	addi            a1, a1, %lo(array_initialized)
	li 		s4, MEM_BASE
	mv              s5, s4
	li              s2, 0
	li              s3, ARR_SIZE
walk:							#; walk the sting in rodata and push into ram
	lb              a0, 0(a1)
	sb              a0, 0(s4)
	jal             pchar

        addi            a1, a1, 4                       #; increment counters mems are byte(4) index (1)
	addi            s4, s4, 4
	addi            s2, s2, 1
	blt             s2, s3, walk                    #; walk it to ARR_SIZE
	
	lui             a1, %hi(makespace)              #; pretty print shit
	addi            a1, a1, %lo(makespace)
	li              a2, slen
	jal             pstring
	
	mv		a0, s5				#; move local data to args for function
	mv		a1, s3
	jal             sort_hifive

	li              s2, 0
	mv              a1, s5				#; saved off memory base address
walk2:	
	lb		a0, 0(a1)                       #; walk sorted array in memory
        jal 		pchar
	addi            a1, a1, 4
	addi            s2, s2, 1
	blt             s2, s3, walk2
	ret
