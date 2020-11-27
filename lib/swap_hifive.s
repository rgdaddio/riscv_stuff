#Basic swap routine. This shows the similarity between RISCV and MIPS as this is essentially the
#same code shown in Patterson and Hennessy	

#a0 contains address of array
#a1 contains the index of element to swap
	
.section .text
	

.globl swap_hifive
.type swap_hifive,@function
swap_hifive:
		
		addi sp, sp, -0x20 	#get some stack and store the ra & tmps
		sw   ra, 0x1c(sp)
		sw   s3, 0x18(sp)
		sw   s2, 0x14(sp)
		sw   s1, 0x10(sp)
		sw   s0, 0xc(sp)
	
		sll s1, a1, 2 	##assume 32bit words adjust
		add s1, a0, s1	##get the indexed address

		lw  s0, 0(s1)	#get data from base
		lw  s2, 4(s1)	#get data from next

		sw  s2, 0(s1)	#swap it
		sw  s0, 4(s1)	#swap it

		lw   s0, 0xc(sp) 	
		lw   s1, 0x10(sp)
		lw   s2, 0x14(sp)
		lw   s3, 0x18(sp)
		lw   ra, 0x1c(sp)
		addi sp, sp, 0x20

	
		ret

		
