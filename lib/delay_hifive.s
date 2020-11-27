
.global delayit
.type delayit,@function
delayit:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	
	mv s2, x0        	#counter
	li s3, 0x25000	 	#some loop time
loop:
	addi s2, s2, 1
	bne s2, s3, loop

	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret	
