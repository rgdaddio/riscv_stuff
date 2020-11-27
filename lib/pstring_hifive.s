#a0 pointer to string
#a1 len of string
	
.global pstring
.type pstring,@function
pstring:

	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)

	li    s2, 1
	mv    s3, a1

spin:
	lb    a0, 0(s3)
#	lb a0,0(a1)
	jal   pchar
	beq   s2, a2, done
	addi  s2, s2, 1
	addi  s3, s3, 1
#	addi a1, a1, 1
	mv    a0, zero
	j     spin

done:	
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret
