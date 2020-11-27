.global pchar
.type pchar,@function
pchar:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	
	jal  txuart				#; print the byte to uart
	jal  delayit				#; let uart catch up

	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20

	ret
