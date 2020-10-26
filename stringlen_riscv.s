###########################################################################
			.data
testgreeting:
	.string "strlntst\n"
	glen = . - testgreeting
#Note Risc5/binutils ld seems to have problems with multiple symbols and gp
############################################################################	
			.text
	.global _start                  #;set up a start routine
	.type _start, @function

##############################################################################	
	_start:
	li a0, 1 				#stdout
	lui a1, %hi(testgreeting)		#high part of message
	addi a1, a1, %lo(testgreeting)		#low part of messate
	li a2, glen				#len
	li a3, 0				#0-out a3
	li a7, 64				#load syscall number
	ecall

	jal get_test_string			#simple function
	jal string_len				#get the len of testgreeting string

	li a0, 1
	addi sp, sp, 8
	mv a1, sp
	li a2, 1
	li a3, 0
	li a7, 64
	ecall					#print the length up to 9 chars
	jal riscv_exit
#################################################################################
.global string_len
	.type string_len,%function
string_len:
	mv t3, a0
	li t6, 0  #counter                     #we only count to 9 for test
not_done:
	lb t4, 0(t3)
	beq t4, x0, done			#find \0 termination
	addi t3, t3, 1				#advance ptr
	addi t6, t6, 1				#incr couner
	j not_done				#loop till done
done:
	addi t6, t6, 0x30
	sb t6, 8(sp)				#save the count on the stack
	ret
################################################################################
.global get_test_string
	.type get_test_string,%function
get_test_string:	
	mv a0, a1				#move the string ptr to a0
	ret
################################################################################	
.global riscv_exit
	.type riscv_exit,%function
riscv_exit:
	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93			#exit system call
	ecall


 
