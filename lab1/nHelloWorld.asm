# Program: nHelloWorld

# Objective: Print out "Hello World" n times according to the number user inputs.

.data
	prompt: .asciiz "Enter an integer : "
	hello:	.asciiz "Hello World \n"
	error:	.asciiz "\nout of range.\n"
	newLine:.asciiz "\n"
.text

main: 	
	jal showTips				# call showTips subroutine

	bge $a0, 11, printError			# if print times larger than 11, branch to printError subroutine
	ble $a0, 0, printError			# if print times smaller than 0, branch to printError subroutine
	
	add $a1, $zero, $a0			# $a1 gets $zero + $a0
	jal PrintNewLine			# call PrintNewLine subroutin
	while:
		beq $a1, 0 exit			# if $a1 equals 0, call exit subroutine
		jal Hello			# call Hello subroutine
		subi $a1, $a1, 1		# $a1 subtract 1 everytime to count how many times left to print "Hello World"
		j while				# jump to while subroutine	
	exit:
		jal quit			# call quit subroutine
	
###############################################################
# Subroutine to print a new line
	PrintNewLine:
		la $a0 newLine			# load the address of newLine to $a0      
		li $v0, 4			# specify Print String Service (#4)
		syscall				# syscall to execute requested service specified in Register $v0 (#4)
		jr $ra				# return from subroutine
###############################################################
# Subroutine to print Hello Word
	Hello :
		la $a0, hello			# load the address of hello to $a0
		li $v0, 4			# specify Print String Service (#4)
		syscall				# syscall to execute requested service specified in Register $v0 (#4)
		jr $ra				# return from subroutine
###############################################################
# Tip user to input how many timew (n) "Hello World" to be printed		
	showTips:
		la   $a0, prompt                # load address of prompt for syscall
      		li   $v0, 4                     # specify Print String service (See MARS Help --> Tab System Calls)
     		syscall                         # System call to execute service # 4 (in Register $v0)
      		li   $v0, 51                    # specify Read Integer service (#51)
      		syscall                         # System call to execute service # 51 (in Register $v0) : Read the number. After this instruction, the number read is in Register $a0.
      		li $v0, 1                       # specify Print String Service (#1)
		syscall		                # System call to execute service # 1 (in Register $v0)
      		jr $ra                          # return from subroutine
###############################################################
# Subroutine to print error     		
	printError:
		la $a0, error
		li $v0, 4			# specify Print String Service (#4)
		syscall				# syscall to execute requested service specified in Register $v0 (#4)
		j showTips			# jump to subroutine "showTips"
#############################################################		
# Subroutine to quit the program	
	quit :	
		li $v0, 10			# specify Print String Service (#10)
		syscall				# syscall to execute requested service specified in Register $v0 (#10)

