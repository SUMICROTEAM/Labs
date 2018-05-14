.data

A: .word 0
B: .word 0
C: .word 0

.text

addi t1, zero, 1 #initial temp used throughout program

addi a0,zero,3
jal NegativeCheck
jal Fib_Check
add t4, zero, a1 #display n=3

addi a0,zero,10
jal NegativeCheck
jal Fib_Check
add t5, zero, a1 #display n=10

addi a0,zero,30
jal NegativeCheck
jal Fib_Check 
add t6, zero, a1 #Display n=30

j Exit

NegativeCheck:
	blt a0, t1, setNegative
	ret
	setNegative:
		add a0, zero, zero
		j Fib_Check

Fib_Check:
	
	bgt a0, t1, Fib_Loop #Go to loop if n>1
	mv a1, a0 
	ret

Fib_Loop:
	addi sp, sp, -12
	sw ra, 0(sp)	#save return address
	
	sw a0, 4(sp)    #save n
	addi a0, a0, -1 #n-1
	jal Fib_Check   
	
	lw a0, 4(sp)    #restore n
	sw a1, 8(sp)	#save value from Fib_Check(n-1)
	
	addi a0, a0, -2 #n-2
	jal Fib_Check
	
	lw t0, 8(sp)
	add a1, t0, a1 	#our return value
 	
	lw ra, 0(sp)	#restore ra
	addi sp, sp, 12 #clean stack
	ret
	
Exit: