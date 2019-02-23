########;riscv64-unknown-elf-as helloriscv_t.s -o helloriscv_t.o
########;riscv64-unknown-elf-ld -o ttest helloriscv_t.o
#or
########;riscv64-unknown-linux-gnu-as helloriscv_t.s -o helloriscv_t.riscv64
########;risc64-unknown-linux-gnu-ld -o ttest helloriscv_t.o
########;Run using Spike Sim: spike pk ttest 
########;Port from old Openrisc code the old hello world standby 



	.data

myStr:
	.string "hello riscv new world!!\n" 	#;basic string data
	len = . - myStr                 	#;get the length via intrinsic


	.text



	.global _start				#;linker start point
	.type _start, @function
	

_start:	

main:	
	
	li a0, 1 			#stdout FD
	lui a1, %hi(myStr)		#high part of message
	addi a1, a1, %lo(myStr)		#low part of message
	li a2, len			#len
	li a3, 0			#0-out a3
	li a7, 64			#load write syscall number
	ecall

	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93			#load exit system call number
	ecall

	.global main                  #;main routine for Spike PK
	.type main, @function
