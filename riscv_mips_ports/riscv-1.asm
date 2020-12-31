#test run 	
#riscv64-unknown-linux-gnu-as riscv-1.asm -o riscv-1.o
#riscv64-unknown-linux-gnu-ld -o riscv-1 riscv-1.o
#spike pk riscv-1
#This is a quick port from MIPs example by https://github.com/ffcabbar/MIPS-Assembly-Language-Examples
#It is mostly a straight copy MIPs just has more system call support remove $ from MIPs and change
#syscall to ecall and change MIPs v0 reg to RISCV a0 and done

#Current limitations RISCV kernel(pk) is not as rich as MIPs linux kernal and does support print int so
#the ascii adder support lib only prints to 18 and needs zero padding this should be cleaned up too lazy 
	
.data
string1: .ascii "Enter a number:"
	elen = . - string1
string2: .ascii "Enter the second number:"
	elen2 = . - string2
string3: .ascii "Sum:"
	slen = . - string3
endLine: .ascii "\n"
	enlen = . - endLine

.comm myArr2, 16, 1	

.text
main:

	li a0 , 1				#print string1 
	la a1 , string1
	li a2, elen
	li a7, 64
	ecall

	li a0 , 1	 			#read integer
	la a1, myArr2
	li a2, 5
	li a7, 63
	ecall
	
	lb t0, 0(a1)

	li a0 , 1
	la a1, endLine
	li a2 , enlen        			#(mips guys)Boşluk vermek için.
	li a7, 64
	ecall
	
	li a0 , 1
	la a1 , string2
        li a2, elen2
	li a7, 64
	ecall
	
	li a0, 1
	la a1, myArr2
	li a2, 5
	li a7, 63
	ecall

        lb t1, 0(a1)
	
	li a0 , 1
	la a1 , string3
	li a2, slen
	li a7, 64
	ecall

	li t3, 0x30303000      #ascii zero pads for ascii adder
	add t1, t1, t3
	li t3, 0x30303000
	add t0, t0, t3
				#(mips guys)İki tane yazdığımız integer değerleri toplayıp t2 temporary değere aktardık.s
	jal asciiadd

	la t3, myArr2
	sw t2, 0(t3)

	mv a1, t3
	li a0, 1
	li a2, 4		#print zero padded integer
	li a7, 64
	ecall	
		 
	li a7, 93              #exit
	ecall


	
.global _start                  #;set up a start routine
.type _start, @function
_start:
#bare metal pk setup
	.option push
	.option norelax
	1:auipc gp, %pcrel_hi(__global_pointer$)
	addi  gp, gp, %pcrel_lo(1b)
	.option pop
	.option relax	

	j main

