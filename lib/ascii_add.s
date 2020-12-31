#Expects 4 digit ascii numbers in a0 and a1 returns a1

#This is a a quick and dirty assembly code up of the ideas in
#http://homepage.divms.uiowa.edu/~jones/bcd/bcd.html

#A great paper on a topic that runs our lives yet we hardly
#recognize what he is talking about ----till day comes when
#you have bare metal... :)	

.comm mArr2, 16, 1	
	
.global asciiadd
.type asciiadd,@function
asciiadd:

	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
	sw   s5, 0xc(sp)
	sw   s6, 0x8(sp)

	add s2, a1, a0
	li s5, 0x0000000096969696

	add  s2, s2, s5

	li s3, 0
	
	li s5, 0x0000000030303030

	and  s3, s2, s5

	srli s4, s3, 3
	sub  s4, s2, s4

	li s5, 0x000000000f0f0f0f
	and s4, s4, s5
	

	li s5, 0x0000000030303030
	or  t2, s4, s5

	mv a0, t2
	jal htonl_riscv
	
	lw   s6, 0x8(sp)
	lw   s5, 0xc(sp)
	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret
