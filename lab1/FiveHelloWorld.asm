# Program: FiveHelloWorld

# Objective: Print out "Hello World" five times.
.data
	myString:	.asciiz "Hello World \n"
.text
	main: 	
		addi $t0, $zero, 0
		while:
			beq $t0, 5 exit        # after five times, call exit subroutine
			jal Hello              # call Hello subroutine
			addi $t0, $t0, 1       # $t0 plus one everytime to count how many times "Hello World" have been printed
			j while		       # jump to while subroutine
		exit:
			jal quit	       # call quit subroutine
			
################################################		
# Subroutine to print Hello World
	Hello :
		la $a0, myString   		# load mystring address to $a0             
		li $v0, 4			# specify Print String Service (#4)
		syscall				# syscall to execute requested service specified in Register $v0 (#4)
		jr $ra				# return from subroutine
		
################################################		
# Subroutine to quit the program
	quit :	
		li $v0, 10			# specify Print String Service (#10)
		syscall				# syscall to execute requested service specified in Register $v0 (#10)

