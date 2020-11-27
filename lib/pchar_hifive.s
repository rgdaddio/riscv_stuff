.global pchar
.type pchar,@function
pchar:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	
	jal  txuart				#; print the byte to uart
	jal  delayit				#; let uart catch up

	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20

	ret
