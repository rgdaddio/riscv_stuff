#################################################################################
#Small string length test code. Some extra function call for the hell of it
#For use in spike the risc5 simulator

#test run 	
#riscv64-unknown-linux-gnu-as stringlen_riscv.s -o stringlen_riscv.o
#riscv64-unknown-linux-gnu-ld -o strlen stringlen_riscv.o
#spike pk strlen
#
#The norelax option can probably be removed on real linux	
#################################################################################
			.data
testgreeting:
	.string "Simple string length test\n"
	glen = . - testgreeting

			.option norelax #kill the evil gp

testit:
	.string "\nlength\n"
	tlen = . - testit
			.option norelax

resultstr:
	.string " is the length of tested string\n\n"
	rlen = . - resultstr
		
#################################################################################	
			.text
	.global _start                  	#;set up a start routine
	.type _start, @function

#################################################################################	
	_start:
	li a0, 1 				#stdout
	lui a1, %hi(testgreeting)		#high part of message
	addi a1, a1, %lo(testgreeting)		#low part of messate
	li a2, glen				#len
	li a3, 0				#0-out a3
	li a7, 64				#load syscall number
	ecall

	lui a1, %hi(testit)			#high part of message
	addi a1, a1, %lo(testit)		#low part of message
	
	jal string_len				#get the len of testit string

	li a0, 1
	li a2, 1
	li a3, 0
	li a7, 64
	ecall					#print the length up to 9 chars

	jal results

	j riscv_exit

#################################################################################
.global string_len
	.type string_len,%function
string_len:
	mv t3, a1
	li t6, 0  #counter                     	#we only count to 9 for test
						#itoa TBD... :)
not_done:
	lb t4, 0(t3)
	beq t4, x0, done			#find \0 termination
	addi t3, t3, 1				#advance ptr
	addi t6, t6, 1				#incr couner
	j not_done				#loop till done
done:
	addi t6, t6, 0x30
	sb t6, 0(a1)
	ret

#################################################################################
.global results
	.type results,%function
results:	
	li a0, 1 				#stdout
	lui a1, %hi(resultstr)			#high part of message
	addi a1, a1, %lo(resultstr)		#low part of messate
	li a2, rlen				#len
	li a3, 0				#0-out a3
	li a7, 64
	ecall
	ret

#################################################################################	
.global riscv_exit
	.type riscv_exit,%function
riscv_exit:
	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93				#exit system call
	ecall


 
