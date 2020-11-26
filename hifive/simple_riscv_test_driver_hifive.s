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


	
