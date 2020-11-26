#Basic bubble sort

#Input:	
#a0 contains address of array
#a1 contain the index of the array

.section .text

.globl sort_hifive
.type sort_hifive,@function
sort_hifive:

		addi sp, sp, -0x20 	#get some stack and store the ra & tmps
		sw   ra, 0x1c(sp)
		sw   s3, 0x18(sp)
		sw   s2, 0x14(sp)
		sw   s1, 0x10(sp)
		sw   s0, 0xc(sp)


		mv  s2, a0 	 	#arg 0
		mv  s3, a1		#arg 1

		mv  s0, zero		#set a 0 
Oloop:
		slt  t0, s0, s3		#check passed in index for 0
		beq  t0, zero, ExitO	#finished
		addi s1, s0, -1
Iloop:
		slti t0, s1, 0
		bne  t0, zero, ExitI
		sll  t1, s1, 2
		add  t2, s2, t1
		lw   t3, 0(t2)
		lw   t4, 4(t2)
		slt  t0, t4, t3
		beq  t0, zero, ExitI

		mv  a0, s2
		mv  a1, s1
		jal  swap_hifive

		addi s1, s1, -1
		j Iloop

ExitO:
		addi s0, s0, 1
		j Oloop
	
ExitI:

		lw   s0, 0xc(sp) 	
		lw   s1, 0x10(sp)
		lw   s2, 0x14(sp)
		lw   s3, 0x18(sp)
		lw   ra, 0x1c(sp)
		addi sp, sp, 0x20

		ret
	
	
