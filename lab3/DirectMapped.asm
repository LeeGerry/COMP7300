# Program: Direct mapping
# Author: Group 2 (Guorui Li, Sicheng Li, Yang Cao)
# Nov 10, 2016
.data  
comma:		.asciiz ","
name:		.asciiz "directed map\n"
newLine:	.asciiz "\n"
KB:		.asciiz " KB\n"
B:		.asciiz " B\n"
tipCacheSize:	.asciiz "cache size is: "
tipBlockSize:	.asciiz "block size is: "
tipBlockNumber:	.asciiz "block number is: "
tipOffset:	.asciiz "offset has bits: "
tipIndex:	.asciiz "index has bits: "
tipTag:		.asciiz "tag has bits: "
tipIndexValue:	.asciiz "index = "
tipTagValue:	.asciiz "tag = "
cacheSize: 	.word 	256		 # cacheSize, the unit is KB
blockSize: 	.word 	4096		 # block size, the unit is Byte
dataFile: 	.asciiz "data.txt"      # filename of the reference data
buffer: 	.space 	40		 # buffer to read one line of the input file, actually it is an address reference
tag:		.word	0
index:		.word	0
tagArray: 	.word 	0:262144		 # the array store the tag of the reference
vArray: 	.word 	0:8192		 # the array to store the validate bit

blockNumber: 	.word  	0 		 # # of blocks (e.g. 2^8=256)
indexBits:	.word  	0		 # store how many bits the index have.(e.g. 8, because block number is 2^8)
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
#   			calculate the index bits, stored in indexBits
#################################################################################### 
#calculate the bits of the index, store the result into indexBits
li $t1, 0
loop_cal_index_bits:
	beq $t3, 1, stop_cal_index_bits
	srl $t3, $t3, 1		# t3 = the number of blocks, t3/2 until t3 == 1
	add $t1, $t1, 1		# every time t1++
	j loop_cal_index_bits
stop_cal_index_bits:
sw $t1, indexBits		# now 2^t1 = the number of blocks, store t1 into 

#################################################################################### 
#   			calculate the tag bits, stored in tagBits
#################################################################################### 
li $t1, 32
lw $t2, offsetBits
lw $t3, indexBits
sub $t1, $t1, $t2
sub $t1, $t1, $t3
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
la  $a0, tipOffset     
syscall 
li $v0, 1
lw $a0, offsetBits
syscall 
jal printNewline

li  $v0, 4          
la  $a0, tipIndex     
syscall 
li $v0, 1
lw $a0, indexBits
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

jal printBuf ############## produce the integer form of tag, index ***core

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
printBuf:
#li  $v0, 4          # 
#la  $a0, buffer     # buffer contains the values
#syscall             # print int
lw $t3, tagBits		# store t3 with tagbits
lw $t5, indexBits	# store t5 with indexbits
add $t4, $t3, 0		# store t4 with tagbits
add $t6, $t3, $t5	# t6 = tagbits + indexbits
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
#li $v0, 1
#move $a0, $t2
#syscall

#li $v0, 4
#la $a0, comma
#syscall
continueTag:
add $t1, $t1, 1			# t1++
j loopTag			# loop
stopLoopTag:
sw $t9, tag			# when stop , store the result t9 into tag

li $t9, 0			# init t9 = 0
loopIndex:
lb $t2, buffer($t1)		# continue to fetch the char from buffer
beq $t1, $t6, stopLoopIndex	# when loop indexbits times, then stop
beq $t2, '0', continueIndex	# when the fetched char is '0' do nothing
li $t7, 1			# when the char is '1', then begin calculate. put t7 with 1
sub $t8, $t6, $t1		# 
sub $t8, $t8, 1
sllv $t7, $t7, $t8		# t7 shift left for t8 bits
add $t9, $t9, $t7		# t9 = t9 + t7
continueIndex:
add $t1, $t1, 1
j loopIndex
stopLoopIndex:
sw $t9, index			# when stop, store the result t9 into index



############################################################################
# 
############################################################################
lw $t1, index
la $t2, vArray
la $t5, tagArray

sll $t1, $t1, 2
add $t2, $t2, $t1
lw $t3, ($t2) 		# t3 = vArray[index*4]
add $t5, $t5, $t1
lw $t4, ($t5)		# t4 = tagArray[index*4]
lw $t6, tag
beq $t3, 0, miss


bne $t4, $t6, miss
lw $t8, hitCount
add $t8, $t8, 1
sw $t8, hitCount	# hitCount++
j continueNext

miss:
lw $t8, misCount
add $t8, $t8, 1
sw $t8, misCount	# miscount++
li $t7, 1
sw $t7, ($t2)		# set vArray[index * 4] = 1
sw $t6, ($t5)		# set tagArray[index * 4] = current Tag, update

continueNext:



########## print the calculate result, will be deleted when do the real experiment
#li $v0, 4
#la $a0, tipIndexValue
#syscall
#li $v0, 1
#lw $t8, index
#move $a0, $t8
#syscall
#li  $v0, 4          
#la  $a0, newLine     
#syscall

#li $v0, 4
#la $a0, tipTagValue
#syscall
#li $v0, 1
#lw $t8, tag
#move $a0, $t8
#syscall
#li  $v0, 4          
#la  $a0, newLine     
#syscall




jr $ra				# this line is the outer , pay more attention. not delete



########################################### 
#		print NewLine
########################################### 
printNewline:
li  $v0, 4          
la  $a0, newLine     
syscall             
jr $ra

