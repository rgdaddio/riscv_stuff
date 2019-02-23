########;as --gdwarf-2 helloriscv.s -o helloriscv.o
########;ld -s -o hellorisv helloriscv.o
########;Using GNU LD and GNU AS
########;Port from old Openrisc code the old hello world standby 



	.data

myStr:
	.string "hello riscv new world!!\n" #;basic string data

	len = . - myStr                 #;get the length via intrinsic

	.text

	.global _start                  #;set up a start routine
	.type _start, @function

_start:	
	
	li a0, 0 			#stdout
	lui a1, %hi(myStr)		#high part of message
	addi a1, a1, %lo(myStr)		#low part of messate
	li a2, len			#len
	li a3, 0			#0-out a3
	li a7, 64			#load syscall number
	ecall

	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93			#exit system call
	ecall
