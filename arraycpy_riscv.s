#; Originally on Openrisc 3/1/2009 RGD
#; Ported to RISCV 10 years later same shit LOL.
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;#
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;#
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;#

#################################################################################
#Small array copying test code. Some extra function calls for the hell of it
#For use in spike the risc5 simulator

#Test run 	
#riscv64-unknown-linux-gnu-as arraycpy_riscv.s -o arraycpy_riscv.o
#riscv64-unknown-linux-gnu-ld -o arraycpy array_riscv.o
#spike pk arraycpy
#
#The norelax option can probably be removed on real linux	
#################################################################################
				.data
	
	.type myStr,@object		#; define an array that hold a string
	.size myStr, 12			#; myStr[] = {"hello world"}
myStr:
	.string "hello world"
				.option norelax
testgreeting:
	.string "Array copy using for loop:\n"
	glen = . - testgreeting
				.option norelax
resultstr:
	.string " => is in first array\n"
	rlen = . - resultstr
				.option norelax

	.comm myArr2, 16, 1		#; array with 1 char alignment
					#; myStr hello world copied to myArr
	
				.option norelax
endresultstr:
	.string " => is now byte byte copied into second array\n"
	elen = . - endresultstr
	
				.text
################################################################################
.global _start
.type _start,@function
_start:
	li		a0, 0x1				#; stdfile no 1
	lui		a1, %hi(testgreeting)		#; move upper 16 in
        addi 		a1, a1, %lo(testgreeting)	#; or in the lower 16
	li		a2, glen			#; strnlen
	li		a7, 0x40			#; write sys call 4
	ecall		  	 			#; call os print initial
	
	li		a0, 0x1			#; stdfile no 1
	lui		a1, %hi(myStr)		#; move upper 16 in
        addi 		a1, a1, %lo(myStr)	#; or in the lower 16
	mv		x27, a1			#; preserve x27
	li		a3, 0			
	li		a2,  0xc		#; strnlen
	li		a7, 0x40		#; write sys call 4
	ecall 	 		#; call os print initial



	li		a0, 0x1		#; stdfile no 1
	lui		a1, %hi(resultstr)	#; move upper 16 in
        addi 		a1, a1, %lo(resultstr)	#; or in the lower 16
	li		a3, 0
	li		a2, rlen		#; strnlen
	li		a7, 0x40		#; write sys call 4
	ecall
	
	jal		copyarr
	li		a0, 0x1
	mv		a1, t2
	li 		a3, 0
	li 		a2, 0xc
	li 		a7, 0x40
	ecall

	li		a0, 0x1			#; stdfile no 1
	lui		a1, %hi(endresultstr)	#; move upper 16 in
        addi 		a1, a1, %lo(endresultstr)	#; or in the lower 16
	li		a3, 0
	li		a2, elen		#; strnlen
	li		a7, 0x40		#; write sys call 4
	ecall
	j		local_exit
	
################################################################################  	
.global copyarr
.type copyarr,@function
copyarr:
	mv t3, x27
	li t6, 0     #counter
	lui t5, %hi(myArr2)
	addi t5, t5, %lo(myArr2)
	mv t2, t5
not_done:
	lb t4, 0(t3)
	beq t4, x0, done
	sb t4, 0(t5)
	addi t3, t3, 1
	addi t5, t5, 1
	addi t6, t6, 1
	j not_done
done:	
	ret

################################################################################	
.global local_exit
.type local_exit,@function
local_exit:
	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93				#load syscall number
	ecall   	 		#; call os call val in delay	

