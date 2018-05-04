.data

A: .word 0
B: .word 0
C: .word 0

.text

addi a0,zero,3
jal Fib

addi a0,zero,10
jal Fib 

addi a0,zero,20
jal Fib

j exit

Fib:
#t0 will always hold value
#a0 should go to t1 for saving convention



Exit: