# Program: Fully associative - FIFO
# Oct 26, 2016

.data  
comma:		.asciiz ","
name:		.asciiz "fully associative - fifo\n"
newLine:	.asciiz "\n"
KB:		.asciiz " KB\n"
B:		.asciiz " B\n"
tipCacheSize:	.asciiz "cache size is: "
tipBlockSize:	.asciiz "block size is: "
tipBlockNumber:	.asciiz "block number is: "
tipOffset:	.asciiz "offset has bits: "
tipTag:		.asciiz "tag has bits: "

tipTagValue:	.asciiz "tag = "
cacheSize: 	.word 	16		 # cacheSize, the unit is KB
blockSize: 	.word 	64		 # block size, the unit is Byte
dataFile: 	.asciiz "data.txt"      # filename of the reference data
buffer: 	.space 	40		 # buffer to read one line of the input file, actually it is an address reference
tag:		.word	0
tagArray: 	.word 	-1:262144		 # the array store the tag of the reference

blockNumber: 	.word  	0 		 # # of blocks (e.g. 2^8=256)
tagBits:	.word 	0
offsetBits:	.word 	0
misCount: 	.word 	0
hitCount:	.word 	0
tipMisCount:	.asciiz "mis count is : "
tipHitCount: 	.asciiz "hit count is : "
ema:		.asciiz "effective memory access is : "
mr:		.asciiz "miss rate is : "
.text
li $v0, 4
la $a0, name
syscall
#################################################################################### 
#			calculate the offset, stored in offsetBits 
#################################################################################### 
lw $t1, blockSize	# t1 = block size
#calculate the bits of the offset
li $t4, 0
loop_cal_offset_bits:
	beq $t1, 1, stop_cal_offset_bits
	srl $t1, $t1, 1		# t1 = block size, t1/2 until t1 == 1
	add $t4, $t4, 1		# every time t4++
	j loop_cal_offset_bits
stop_cal_offset_bits:
sw $t4, offsetBits		# now 2^t4 = block size, store t4 into offsetBits
#################################################################################### 
############## calculate the number of blocks, stored in blockNumber############
#################################################################################### 
lw $t1, blockSize	# t1 = block size
lw $t2, cacheSize	# t2 = cache size
sll $t2, $t2, 10		# t2 = t2 * 2^10, because t2 is cache size, the unit is KB, we need get B
div $t2, $t1			# low = t2 / t1, 
mflo $t3			# store the low to t3
sw $t3, blockNumber		# store the number of blocks to blockNumber


#################################################################################### 
#   			calculate the tag bits, stored in tagBits
#################################################################################### 
li $t1, 32
lw $t2, offsetBits
sub $t1, $t1, $t2
sw $t1, tagBits
#################################################################################### 
#			 print the params calculated above
#################################################################################### 
li  $v0, 4          
la  $a0, tipCacheSize     
syscall 
li $v0, 1
lw $a0, cacheSize
syscall 
li  $v0, 4          
la  $a0, KB     
syscall

li  $v0, 4          
la  $a0, tipBlockSize     
syscall 
li $v0, 1
lw $a0, blockSize
syscall 
li  $v0, 4          
la  $a0, B     
syscall
li  $v0, 4          
la  $a0, tipBlockNumber     
syscall 
li $v0, 1
lw $a0, blockNumber
syscall 
jal printNewline

li  $v0, 4          
la  $a0, tipOffset     
syscall 
li $v0, 1
lw $a0, offsetBits
syscall 
jal printNewline

li  $v0, 4          
la  $a0, tipTag     
syscall 
li $v0, 1
lw $a0, tagBits
syscall 
jal printNewline

#################################################################################### 
#			 	fileRead 
#################################################################################### 
# Open file for reading
li   $v0, 13       # system call for open file
la   $a0, dataFile      # input file name
li   $a1, 0        # flag for reading
li   $a2, 0        # mode is ignored
syscall            # open a file 
move $s0, $v0      # save the file descriptor 



lw $s1, blockNumber 
la $s2, tagArray
move $s3, $s2
sll $s7, $s1, 2
add $s3, $s3, $s7	# t6 = outer edge
la $s4, tagArray
########################################### 
#		loop 100w times t0 = 100w , when debug we loop 5 times and log them
########################################### 
li $t0, 0
loop:
beq $t0, 1000000, stop
li   $v0, 14       # system call for reading from file
move $a0, $s0      # file descriptor 
la   $a1, buffer   # address of buffer from which to read
li   $a2, 33  # hardcoded buffer length
syscall            # read from file

jal coreLogic ############## produce the integer form of tag, index ***core

#continue:
add $t0, $t0, 1
j loop

########################################### 
#		Close the file 
########################################### 

stop:
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

la $a0, tipMisCount
li $v0, 4
syscall
lw $a0, misCount

li $v0, 1
syscall
la $a0, newLine
li $v0, 4
syscall
la $a0, tipHitCount
li $v0, 4
syscall
lw $a0, hitCount
li $v0, 1
syscall
jal printNewline
#calculate miss rate and mp and ema
lw $t1, misCount
sw   $t1, -88($fp)
lwc1 $f4, -88($fp)
cvt.s.w $f6, $f4		# f6 is the float format of miscount

li $t1, 1000000
sw   $t1, -88($fp)
lwc1 $f4, -88($fp)
cvt.s.w $f5, $f4		# f5 is the float format of 100w

la $a0, mr
li $v0, 4
syscall

li $v0, 2
div.s $f12,$f6,$f5
syscall

quit:
li $v0, 10
syscall
########################################### 
#		core logic 
########################################### 
coreLogic:
## get the tag integer
lw $t3, tagBits
move $t4, $t3
li $t9, 0		# t9 is the result of tag, which is parsed from input string line
li $t1, 0		# t1 is the count 
loopTag:
lb $t2, buffer($t1)	# t2 is loaded the t1-th bits from the line buffer
beq $t1, $t3, stopLoopTag	# if t1 == tagbits, stop
beq $t2, '0', continueTag	# if the loaded char is '0', do nothing
li $t7, 1			# if the loaded char is '1', calculate, put t7 with 1
sub $t8, $t3, $t1		# t8 = tagbits - current value of t1
sub $t8, $t8, 1			# t8 --
sllv $t7, $t7, $t8		# shift left, store into t7
add $t9, $t9, $t7		# t9 = t9 + t7

continueTag:
add $t1, $t1, 1			# t1++
j loopTag			# loop
stopLoopTag:
sw $t9, tag			# when stop , store the result t9 into tag



move $t1, $s4
li $s5, 0
innerLoop:
lw $t8, ($t1)
beq $t9, $t8, hit
beq $s5, 1, branch
j branch2

branch:
beq $t1, $s4, notfound
add $t1, $t1, 4
j con
branch2:
add $t1, $t1, 4
j con
con:
bne $t1, $s3, innerLoop
la $t1, tagArray
li $s5, 1
j innerLoop

hit:
lw $t8, hitCount
add $t8, $t8, 1
sw $t8, hitCount	# hitCount++
j continue

notfound:
sw $t9, ($s4)
lw $t8, misCount
add $t8, $t8, 1
sw $t8, misCount	# misCount++
add $s4, $s4, 4
bne $s4, $s3, continue
la $s4, tagArray
continue:
jr $ra				# this line is the outer , pay more attention. not delete

########################################### 
#		print NewLine
########################################### 
printNewline:
li  $v0, 4          
la  $a0, newLine     
syscall             
jr $ra

