.data

A: .word 0
B: .word 0
C: .word 0

.text

addi a0,zero,3
add t0, zero, zero
jal Fib_Check

addi a0,zero,10
add t0, zero, zero
jal Fib_Check 

addi a0,zero,20
add t0, zero, zero
jal Fib_Check

j Exit

Fib_Check:
	addi t6, zero, 1
	bgt a0, t6, Fib_Loop #Go to loop if n>1
	mv a1, a0
	ret

Fib_Loop:
	addi sp, sp, -12
	sw ra, 0(sp)
	
	sw a0, 4(sp)
	addi a0, a0, -1
	jal Fib_Check
	
	lw a0, 4(sp)
	sw a1, 8(sp)
	
	addi a0, a0, -2
	jal Fib_Check
	
	lw t0, 8(sp)
	add a1, t0, a1
	
	lw ra, 0(sp)
	addi sp, sp, 12
	ret
	

Exit: