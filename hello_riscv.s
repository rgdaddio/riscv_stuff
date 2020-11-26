########;Using GNU LD and GNU AS
########;Port from old Openrisc and Arm code the old hello world standby 

#################################################################################
#Old standby  Some extra function calls for the hell of it
#For use in spike the risc5 simulator

#test run 	
#riscv64-unknown-linux-gnu-as stringlen_riscv.s -o stringlen_riscv.o
#riscv64-unknown-linux-gnu-ld -o strlen stringlen_riscv.o
#spike pk strlen
#
#	
#################################################################################

	.data

myStr:
	.string "hello riscv new world!!\n"  #;basic string data

	len = . - myStr                      #;get the length via intrinsic



	.text

################################General start function###########################
#Input:                                                                         #
#Output:                                                                        #
#Returns to system                                                              #
#################################################################################	
.global _start                  #;set up a start routine
.type _start, @function
_start:

	###########################################
	###########Initialize gp register##########
	.option push
	.option norelax
	1:auipc gp, %pcrel_hi(__global_pointer$)
	addi  gp, gp, %pcrel_lo(1b)
	.option pop
	.option relax
	###########################################
	
	li a0, 1 			#stdout
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
