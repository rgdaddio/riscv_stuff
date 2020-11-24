#Basic swap routine
#a0 contains address of array
#a1 contains the index of element to swap
	
.section .text
	

.globl swap_hifive
.type swap_hifive,@function
swap_hifive:
		sll t1, a1, 2 	##assume 32bit words adjust 
		add t1, a0, t1	##get the index

		lw  t0, 0(t1)	#get data from base
		lw  t2, 4(t1)	#get data from next

		sw  t2, 0(t1)	#swap it
		sw  t0, 4(t1)	#swap it
	
		ret

		
