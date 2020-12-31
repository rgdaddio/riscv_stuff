#htonl since riscv is little endian
#Takes a0 and return result in a1
#RGD	

.comm swap_buf, 8, 1 #8 byte array for swap buffer
		     #could use the stack or regs
		     #mem is just as easy if you have

	
.global htonl_riscv
.type htonl_riscv,@function
htonl_riscv:

	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
	sw   s5, 0xc(sp)
	sw   s6, 0x8(sp)

	lui s2, %hi(swap_buf)
	addi s2, s2, %lo(swap_buf)

	sw a0, 0(s2)  #incoming 4 bytes stored in array
	lb s3, 0(s2)
	lb s4, 1(s2)
	lb s5, 2(s2)
	lb s6, 3(s2)

	sb s3, 3(s2)  #swap em
	sb s6, 0(s2)
	sb s4, 2(s2)
	sb s5, 1(s2)

	lw a1, 0(s2) #return a1 with the swapped value
	
	lw   s6, 0x8(sp)
	lw   s5, 0xc(sp)
	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret
