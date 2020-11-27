.equ STACK_SIZE, 1024
.equ MEM_BASE, 0x80000000
.equ MEM_SIZE, 0x4000	

		.section 	.rodata

testgreeting:
		.string "\narray_test\n"
		glen = . - testgreeting

.align 2 #2**2	
array_initialized:
.word 0x35,0x33,0x36,0x37,0x32,0x38,0x37,0x31,0x39,0x35	
	

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
	li		a3, 1				#; set a counter to 1

spin:	
	lb		a0, 0(a1)			#; get a byte from greetinn
	jal 		txuart				#; print the byte to uart
	jal             delayit				#; let uart catch up
	beq		a3, a2, done			#; get out if cntr reach len
	addi 		a3, a3, 1			#; incr counter
	addi 		a1, a1, 1			#; incr string pointer

	j		spin
done:
	ret
