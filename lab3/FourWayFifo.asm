# Program: 4-way associative - FIFO
# Author: 
# Nov 10, 2016

.data  
comma:		.asciiz ","
name:		.asciiz "4-way associative - FIFO\n"
newLine:	.asciiz "\n"
KB:		.asciiz " KB\n"
B:		.asciiz " B\n"
tipCacheSize:	.asciiz "cache size is: "
tipBlockSize:	.asciiz "block size is: "
tipBlockNumber:	.asciiz "block number is: "
tipOffset:	.asciiz "offset has bits: "
tipIndexBit:	.asciiz "index has bits: "
tipTag:		.asciiz "tag has bits: "

tipTagValue:	.asciiz "tag = "
cacheSize: 	.word 	512		 # cacheSize, the unit is KB
blockSize: 	.word 	1024		 # block size, the unit is Byte
dataFile: 	.asciiz "data.txt"      # filename of the reference data
buffer: 	.space 	40		 # buffer to read one line of the input file, actually it is an address reference
tag:		.word	0
index: 		.word 	0
index_bits:	.word	0		# bits of index
tagArray1: 	.word 	-1:65536		 # the array store the tag of the reference
tagArray2: 	.word 	-1:65536		 # the array store the tag of the reference
tagArray3: 	.word 	-1:65536		 # the array store the tag of the reference
tagArray4: 	.word 	-1:65536		 # the array store the tag of the reference
clockArray1:	.word	-1:2048
clockArray2:	.word	-1:2048
clockArray3:	.word	-1:2048
clockArray4:	.word	-1:2048
blockNumber: 	.word  	0 		 # # of blocks (e.g. 2^8=256)
tagBits:	.word 	0
offsetBits:	.word 	0
setNumber:	.word 	0		# number of sets
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
#   			calculate the number of sets, stored in setNumber
#################################################################################### 
srl $t3, $t3, 2
sw $t3, setNumber

#################################################################################### 
#   			calculate the bits of index, stored in index
#################################################################################### 
li $t4, 0
loop_cal_index_bits:
beq $t3, 1, stop_cal_index_bits
srl $t3, $t3, 1 
add $t4, $t4, 1
j loop_cal_index_bits
stop_cal_index_bits:
sw $t4, index_bits
#################################################################################### 
#   			calculate the tag bits, stored in tagBits
#################################################################################### 
li $t1, 32
lw $t2, offsetBits
sub $t1, $t1, $t2
sub $t1, $t1, $t4
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
la  $a0, tipIndexBit     
syscall 
li $v0, 1
lw $a0, index_bits
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






########################################### 
#		loop 100w times t0 = 100w , when debug we loop 5 times and log them
########################################### 
li $t0, 0
loop:
beq $t0, 1000000, stop
li   $v0, 14       # system call for reading from file
move $a0, $s0      # file descriptor 
la   $a1, buffer   # address of buffer from which to read
li   $a2, 31  # hardcoded buffer length
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

#####################################################################
########################################### 
#		calculate index 
########################################### 
lw $t4, index_bits
add $t4, $t4, $t3
li $t5, 0		# t5 is the result of index, which is parsed from input string line

loopIndex:
lb $t2, buffer($t1)	# t2 is loaded the t1-th bits from the line buffer
beq $t1, $t4, stopLoopIndex	# if t1 == tagbits, stop
beq $t2, '0', continueIndex	# if the loaded char is '0', do nothing
li $t7, 1			# if the loaded char is '1', calculate, put t7 with 1
sub $t8, $t4, $t1		# t8 = tagbits - current value of t1
sub $t8, $t8, 1			# t8 --
sllv $t7, $t7, $t8		# shift left, store into t7
add $t5, $t5, $t7		# t9 = t9 + t7

continueIndex:
add $t1, $t1, 1			# t1++
j loopIndex			# loop
stopLoopIndex:
sw $t5, index			# when stop , store the result t5 into index


###############
# 
##############

lw $t2, index
sll $t2, $t2, 2
lw $t3, tag
lw $t4, tagArray1($t2)
beq $t4, -1, compulsory1
beq $t4, $t3, hit
lw $t4, tagArray2($t2)
beq $t4, -1, compulsory2
beq $t4, $t3, hit
lw $t4, tagArray3($t2)
beq $t4, -1, compulsory3
beq $t4, $t3, hit
lw $t4, tagArray4($t2)
beq $t4, -1, compulsory4
beq $t4, $t3, hit

capacity:
lw $t1, misCount
add $t1, $t1, 1
sw $t1, misCount
lw $t5, clockArray1($t2)
lw $t6, clockArray2($t2)
lw $t7, clockArray3($t2)
lw $t8, clockArray4($t2)
move $t9, $t5
bgt $t6, $t9, setmax6
compare7:
bgt $t7, $t9, setmax7
compare8:
bgt $t8, $t9, setmax8
j stopcompare
setmax6:
move $t9, $t6
j compare7
setmax7:
move $t9, $t7
j compare8
setmax8:
move $t9, $t8

stopcompare:
beq $t9, $t5, update1
beq $t9, $t6, update2
beq $t9, $t7, update3
beq $t9, $t8, update4
update1:
sw $t3, tagArray1($t2)
sw $zero, clockArray1($t2)
lw $t5, clockArray4($t2)
add $t5, $t5, 1
sw $t5, clockArray4($t2)
lw $t5, clockArray2($t2)
add $t5, $t5, 1
sw $t5, clockArray2($t2)
lw $t5, clockArray3($t2)
add $t5, $t5, 1
sw $t5, clockArray3($t2)
j continue
update2:
sw $t3, tagArray2($t2)
sw $zero, clockArray2($t2)
lw $t5, clockArray4($t2)
add $t5, $t5, 1
sw $t5, clockArray4($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
lw $t5, clockArray3($t2)
add $t5, $t5, 1
sw $t5, clockArray3($t2)
j continue
update3:
sw $t3, tagArray3($t2)
sw $zero, clockArray3($t2)
lw $t5, clockArray4($t2)
add $t5, $t5, 1
sw $t5, clockArray4($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
lw $t5, clockArray2($t2)
add $t5, $t5, 1
sw $t5, clockArray2($t2)
j continue
update4:
sw $t3, tagArray4($t2)
sw $zero, clockArray4($t2)
lw $t5, clockArray2($t2)
add $t5, $t5, 1
sw $t5, clockArray2($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
lw $t5, clockArray3($t2)
add $t5, $t5, 1
sw $t5, clockArray3($t2)
j continue

compulsory1:
lw $t1, misCount
add $t1, $t1, 1
sw $t1, misCount
#update tag
sw $t3, tagArray1($t2)
#update clock
sw $zero, clockArray1($t2)
j continue

compulsory2:
lw $t1, misCount
add $t1, $t1, 1
sw $t1, misCount
#update tag
sw $t3, tagArray2($t2)
#update clock
sw $zero, clockArray2($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
j continue
compulsory3:
lw $t1, misCount
add $t1, $t1, 1
sw $t1, misCount
#update tag
sw $t3, tagArray3($t2)
#update clock
sw $zero, clockArray3($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
lw $t5, clockArray2($t2)
add $t5, $t5, 1
sw $t5, clockArray2($t2)
j continue
compulsory4:
lw $t1, misCount
add $t1, $t1, 1
sw $t1, misCount
#update tag
sw $t3, tagArray4($t2)
#update clock
sw $zero, clockArray4($t2)
lw $t5, clockArray1($t2)
add $t5, $t5, 1
sw $t5, clockArray1($t2)
lw $t5, clockArray2($t2)
add $t5, $t5, 1
sw $t5, clockArray2($t2)
lw $t5, clockArray3($t2)
add $t5, $t5, 1
sw $t5, clockArray3($t2)
j continue
hit:
lw $t1, hitCount
add $t1, $t1, 1
sw $t1, hitCount
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

