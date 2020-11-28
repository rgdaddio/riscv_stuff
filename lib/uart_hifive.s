#Basic init and transmit for hifive board

.equ UARTTX, (1 << 17)
.equ UARTRX, (1 << 16)
.equ GPIOBASE, 0x10012000
.equ UARTBASE, 0x10013000

.global inituart
.type inituart,@function
inituart:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
#GPIO section	
	li   s2, GPIOBASE 	#GPIO BASE
	lw   s3, 0x38(s2)	#GPIO OUTPUT ENABLE
	li   s4, UARTRX		#RX BIT
	or   s3, s3, s4
	li   s4, UARTTX		#TX BIT
	or   s3, s3, s4
	sw   s3, 0x38(s2)	#END RMW
#UART section
	li   s2, UARTBASE	#UART BASE
	sw   x0, 0x10(s2)	#DISABLE INTRPTS
	lw   s3, 0x08(s2)		
	ori  s3, s3, 0x1	#ENABLE TX
	sw   s3, 0x08(s2)
	lw   s3, 0x0C(s2)	#RX
	ori  s3, s3, 0x1 	#ENABLE RX
	sw   s3, 0x0c(s2)
	li   s3, 150		#SET DIVISOR ~160 on the HiFive rev 1 TX/RX
	sw   s3, 0x18(s2)

	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret
	
.global txuart
.type txuart,@function
txuart:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
	sw   s5, 0xc(sp)
	
	li s2, 0x0
	li s3, UARTBASE		#BASE
	li s4, 0x80000000	#TXFULL
	lw s5, 0(s3)
txloop:	and s2, s4, s5
	bnez s2, txloop
	andi a0, a0, 0x000000FF	#TXDATA
	sw a0, 0(s3)
	li a0, 0

	lw   s5, 0xc(sp)
	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret



.global shutdownuart
.type shutdownuart,@function
shutdownuart:
	addi sp, sp, -0x20
	sw   ra, 0x1c(sp)
	sw   s2, 0x18(sp)
	sw   s3, 0x14(sp)
	sw   s4, 0x10(sp)
#GPIO section	
	li   s2, GPIOBASE 	#GPIO BASE
	lw   s3, 0x38(s2)	#GPIO OUTPUT ENABLE
	li   s4, 0x0		#RX BIT
	and   s3, s3, s4
	li   s4, 0x0		#TX BIT
	and   s3, s3, s4
	sw   s3, 0x38(s2)	#END RMW

	lw   s4, 0x10(sp)
	lw   s3, 0x14(sp)
	lw   s2, 0x18(sp)
	lw   ra, 0x1c(sp)
	addi sp, sp, 0x20
	ret
	
	
