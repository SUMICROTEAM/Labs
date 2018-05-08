.data

begn:	.asciz	"Enter a number in Fahrenheit: "
announce:	.asciz  "The result in Celsius is: "
announ:	.asciz	"The result in Kelvin is: "
newln:	.asciz	"\r\n"
startingPt: .float 0.0
temp1: .float -32.0
temp2: .float 5.0
temp3: .float 9.0
temp4: .float 273.15

.text

	li	a7,4			#system call for print string
	la	a0,begn
	ecall
	li	a7,6			#system call for reading floating point
	ecall
	
	fmv.s	f0,fa0		#save result in ft1
	jal Celsius
	jal Kelvin
	j Exit
	
	Celsius:
	flw f1, temp1, t0
	flw f2, temp2, t0
	flw f3, temp3, t0
	fadd.s f1, f0, f1
	fmul.s f1, f1, f2
	fdiv.s f1, f1, f3
	
	fmv.s	fa0, f1
	
	li	a7,4			
	la	a0,newln
	ecall
	li	a7,4			#system call for print string
	la	a0,announce
	ecall
	li	a7,2			#system call for printing float fa0 in ascii
	ecall
	ret
	
	Kelvin:
	flw f1, temp4, t0
	fadd.s f1, fa0, f1
	
	fmv.s	fa0, f1
	
	li	a7,4			#system call for print string
	la	a0,newln
	ecall
	li	a7,4			#system call for print string
	la	a0,announ
	ecall
	li	a7,2			#system call for printing float fa0 in ascii
	ecall
	li	a7,4			#system call for print string
	la	a0,newln
	ecall
	ret
	
	Exit: