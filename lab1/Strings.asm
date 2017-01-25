# My First MIPS program

# Objective: write an assembly program that offers three basic string functions: 
#	string length, capitalize a string, and delete m characters from a string s starting from position p.

.data 
	menuTips: .asciiz "\nPlease select operations: a. function length; b. capitalize; c. delete characters; d. quit\n"
	strInputTips: .asciiz "\nPlease input a string: "
	getlen: .asciiz "the length of the string you input is:"
	tipNum: .asciiz "please input the number of characters you want to delete: "
	tipPosition: .asciiz "please input the position you want to begin deleting: " 
	buf: .space 1024
	newLine: .asciiz "\n"
.text
	main:
	while:
		jal showMenu			# call showMenu subroutine
		
		beq $v0, 'd', exit		# if user inputs 'd', call exit subroutine	
		beq $v0, 'a', getLen		# if user inputs 'a', call getLen subroutine
		beq $v0, 'b', toCapitalize	# if user inputs 'b', call toCapitalize subroutine
		beq $v0, 'c', delete		# if user inputs 'c', call delete subroutine
		j while				# jump to while subroutine
	exit:
		jal quit			# call quit subroutine
###############################################################
# Get length function, output the length of the string user inputs
getLen:
	jal inputString 	# call inputString subroutine

	li $v0, 4 		# specify Print String Service (#4)
	la $a0, getlen		# load the address of getlen
	syscall	
	
	jal calculateLen	# call calculateLen subroutine
	
	li $v0, 1		# specify Print Service (#1) to show the length of the string
	addi $a0, $v1, 0	
	syscall
	li $v0, 4		# specify Print String Service (#4), to print a new line
	la $a0, newLine
	syscall
	j main
	
###############################################################
# Calculate the length of string which is stored in buf
calculateLen:
	la $a0, buf		# load the address of buf
	li $t0, 0		# init $t0 with 0
	loop:
		lb $t1, 0($a0)		# load the first byte of the buf into $t1
		beqz $t1, stop		# if $t1 == 0, means to the end of the string, call stop subroutine
		addi $a0, $a0, 1	# $a0 = $a0 + 1
		addi $t0, $t0, 1	# $t0 = $t0 + 1
		j loop			# jump to loop
	stop: 
		subi $v1, $t0, 1	# get the length of the string, stores the value into $v1 (the first index is 0, so need to sub 1)
		jr $ra			# return from subroutine

###############################################################
# Convert lowercase to uppercase
toCapitalize:
	jal inputString			# call inputString subroutine
	
	li $t0, 0			# init $t0 with 0
	loop1:
		lb $t1, buf($t0)	# load the $t0-th byte in the buf to $t1
		beqz $t1, kill		# if the value stores in $t1 is zero, means the end of the string, call kill subroutine
		blt $t1, 'a', skip	# if the value stores in $t1 is less than 'a' (ascii), call skip subroutine
		bgt $t1, 'z', skip	# if the value stores in $t1 is greater than 'z' (ascii), call skip subroutine
		
		sub $t1, $t1, 32	# $t1 = $t1 - 32, means convert lowercase to uppercase
		sb $t1, buf($t0)	# store the value in $t1 into buf($t0)
	skip:
		addi $t0, $t0, 1	# $t0 = $t0 + 1, means move the pointer to the next
		j loop1			# jump to the loop1
	kill:
		li $v0, 4		# specify Print String Service (#4)
		la $a0, buf
		syscall
	j main				# jump to main
###############################################################
# Delete m characters from index = p
delete:
	jal inputString			# call inputString subroutine
	
	jal calculateLen 		# calculate calculateLen subroutine
	addi $t0, $v1, 0 		# $t0 = $v1 + 0, means $t0 stores the length of the string
	
	jal inputNum			# call inputNum subroutine
	move $t3, $v0			# $t3 = $v0, means $t3 stores the number of user input
	
	jal inputPosition		# call inputPosition subroutine
	move $t2, $v0 			# $t2 = $v0, means $t2 stores the position
	
	
	add $t3, $t3, $t2		# $t3 = $t3 + $t2, means $t3 stores the first position to move
	loop2:
		bgt $t3, $t0, stop2	# if $t3 > $t0, jump to stop2
		lb $t1, buf($t3)	# load the byte buf($t3) into $t1
		sb $t1, buf($t2)	# store the byte in $t1 into buf($t2)
		
		add $t3, $t3, 1		# $t3 = $t3 + 1
		add $t2, $t2, 1		# $t2 = $t2 + 1
		j loop2			# jump to loop2
	stop2:
		sb $zero, buf($t2)	# store zero into buf($t2), because at the end of the string we need a '\0'
		li $v0, 4		# specify Print String Service (#4)
		la $a0, buf
		syscall
	j main				# jump to main
	
###############################################################
# Quit the program
quit:
	li $v0, 10
	syscall

###############################################################
# Show the menu to tip user to intput a char(a, b, c, d) to choose an option
showMenu:
	li $v0, 4			# specify Print String Service (#4)
	la $a0, menuTips
	syscall
	
	li $v0, 12			# specify Get a character Service (#12)
	syscall

	jr $ra				# return from subroutine
	
###############################################################
# Tip user to input a string
inputString:
	li $v0, 4			# specify Print String Service (#4)
	la $a0, strInputTips
	syscall
	li $v0, 8			# specify store String to memory Service (#8)
	la $a0, buf
	li $a1, 1024
	syscall
	
	jr $ra				# return from subroutine
	
###############################################################
# Tip user to input how many characters to be deleted	
inputNum:
	li $v0, 4			# specify Print String Service (#4)
	la $a0, tipNum
	syscall
	li $v0, 5			# specify get an integer Service (#5)
	syscall
	
	jr $ra				# return from subroutine
	
###############################################################
# Tip user to input which position to delete from
inputPosition:
	li $v0, 4			# specify Print String Service (#4)
	la $a0, tipPosition
	syscall
	li $v0, 5			# specify get an integer Service (#5)
	syscall
	
	jr $ra
	
