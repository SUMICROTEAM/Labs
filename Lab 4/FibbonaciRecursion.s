.data

A: .word 0
B: .word 0
C: .word 0

.text

addi a0,zero,3
add t0, zero, zero
jal Fib_Check
add t4, a0, zero #Save result to t4 for viewing

addi a0,zero,10
add t0, zero, zero
jal Fib_Check 
add t5, a0, zero #Save result to t5 for viewing

addi a0,zero,30
add t0, zero, zero
jal Fib_Check 
add t6, a0, zero #Save result to t6 for viewing

j Exit

Fib_Check:
	addi t1, zero, 1
	bgt a0, t1, Fib_Loop #Go to loop if n>1
	mv a1, a0 
	ret

Fib_Loop:
	addi sp, sp, -12
	sw ra, 0(sp)	#save ra
	
	sw a0, 4(sp)    #save n
	addi a0, a0, -1 #n-1
	jal Fib_Check   
	
	lw a0, 4(sp)    #restore n
	sw a1, 8(sp)	#save retval from fib(n-1)
	
	addi a0, a0, -2 #n-2
	jal Fib_Check
	
	lw t0, 8(sp)
	add a1, t0, a1 	#our return value
 	
	lw ra, 0(sp)	#restore ra
	addi sp, sp, 12 #return stack to normal
	ret
	

Exit: