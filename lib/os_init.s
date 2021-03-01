####
# Setup global pointers
####
	
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
