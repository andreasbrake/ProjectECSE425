#             Min/Max/Average
#
# This routine computes the min/max and average of
# a variable length array.
#

#Array:		.word	34, 78, 43, 67, 91, 56, 25, 69

	addi $11,  $0, 2000  	# initializing the beginning of Data Section address in memory
	addi $15, $0, 4 		# word size in byte
	
	addi $10, $0, 0
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,34 
	sw	 $2, 0($13)
	
	addi $10, $0, 1
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,78 
	sw	 $2, 0($13)
	
	addi $10, $0, 2
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,43 
	sw	 $2, 0($13)
	
	addi $10, $0, 3
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,67 
	sw	 $2, 0($13)
	
	addi $10, $0, 4			# word number 
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,91 			# Saved value into memory
	sw	 $2, 0($13)
	
	addi $10, $0, 5			# word number 
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,56 			# Saved value into memory
	sw	 $2, 0($13)
	
	addi $10, $0, 6			# word number 
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,25 			# Saved value into memory
	sw	 $2, 0($13)
	
	addi $10, $0, 7			# word number 
	mult $10, $15			# $lo=4*$10, for word alignment 
	mflo $12				# assume small numbers
	add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
	addi $2,$0,69 			# Saved value into memory
	sw	 $2, 0($13)
	
	

Main:	add	$1, $0, $11	# init starting ptr
		addi	$2, $0, 8	# init length
		add	$10, $31, $0	# preserve return addres
		jal	MinMaxAvg	# call routine
		jr	$10		# return to os

# inputs: $1= array ptr, $2= array length, $31 return address
# outputs: $3= min, $4= max, $5= avg
# working: $6= end ptr, $7= current element, $8= predicate

MinMaxAvg:	lw	$3, 0($1)	# load init min
		lw	$4, 0($1)	# load init max
		lw	$5, 0($1)	# load init sum
		sll	$6, $2, 2	# length x 4
		add	$6, $6, $1	# end = start + 4 x length
		addi	$1, $1, 4	# increment ptr
Loop:		lw	$7, 0($1)	# load next element
		slt	$8, $7, $3	# if current >= min
		beq	$8, $0, Skip1	# then skip update
		add	$3, $7, $0	# update min
Skip1:		slt	$8, $4, $7	# if current <= max
		beq	$8, $0, Skip2	# then skip update
		add	$4, $7, $0	# update max
Skip2:		add	$5, $5, $7	# add element to sum
		addi	$1, $1, 4	# point to next element
		bne	$1, $6, Loop	# if not done, loop
		
		div	$5, $2		# compute avg
		mflo	$5
		
		addi $11,  $0, 3000  	# initializing the beginning of Section for saving data in memory
		addi $15, $0, 4 		# word size in byte
	
		addi $10, $0, 0
		mult $10, $15			# $lo=4*$10, for word alignment 
		mflo $12				# assume small numbers
		add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
		add $2,$0,$3			#Min Value 
		sw	 $2, 0($13)
		
		addi $10, $0, 1
		mult $10, $15			# $lo=4*$10, for word alignment 
		mflo $12				# assume small numbers
		add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
		add $2,$0,$4			# Man Value 
		sw	 $2, 0($13)
	
		
		
		addi $10, $0, 2
		mult $10, $15			# $lo=4*$10, for word alignment 
		mflo $12				# assume small numbers
		add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
		add $2,$0,$5			# Avg. Value 
		sw	 $2, 0($13)
		
EoP:		beq	 $11, $11, EoP 		#end of program (infinite loop)