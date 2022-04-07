# program for linked lists

main:		li 	$a0, 0xc0debabe 		# First node with 0xc0debabe
		li 	$a1, 0xffffffff
		jal 	add_head
		move	$a1, $v0
		li	$a0, 0xdeadbeef 		# Add 0xdeadbeef to tail
		jal 	add_tail
		move 	$a0, $a1 			# Print all elements
		jal 	print_all
		li 	$a0, 0xbeefdead 		# Add 0xbeefdead to tail
		jal 	add_tail
		move 	$a0, $a1 			# Print all elements
		jal 	print_all
		li 	$a0, 0xbabec0de 		# Add 0xbabec0de to head
		jal 	add_head
		move 	$a0, $v0 			# Print all elements
		jal 	print_all
		j 	exit

							# Params: $a0 = value to add, $a1 = address of old head
							# Return: $v0 = address of new head
						
add_head:	
		addi    $sp, $sp, -12			# allocate stack space for 3 slots
		sw      $ra, 8($sp)			# store return address on stack
		sw	$s0, 4($sp)			# store $s0 on stack
		sw	$s1, 0($sp)			# store $s1 on stack
							
							# Before issuing syscall, preserve arg across subroutine by
		add	$s0, $a0, $zero			# saving $a0 register value (value or data of node) to $s0 and
		add	$s1, $a1, $zero			# saving $a1 register value (address of current head) to $s1 and then
		
							# Allocate 8 bytes (first 4 for data, last 4 for address of next node) in heap memory by
		li	$a0, 8				# setting the value of $a0 to 8 (because 8 bytes to allocate) and
		li	$v0, 9				# setting the value of $v0 to 9 (sbrk service number) and then
		syscall					# issuing a system call, resulting in $v0 containing the address of the allocated memory
		
							# After syscall, reinstate function parameters by
		move	$a0, $s0			# placing back to $a0 from $s0 and
		move	$a1, $s1			# and  placing back to $a1 from $s01
		
		sw	$a0, 0($v0)			# Store data of node ($a0 parameter value) in first 4 bytes of allocated address ($v0 + 0)
		sw	$a1, 4($v0)			# Store old head address ($a1) as address next to new head in last 4 bytes of allocated
							# address ($v0 + 4)
							# $v0 still has new address of head (address of allocated memory)
							
		lw	$s1, 0($sp)			# get $s1 value from stack
		lw	$s0, 4($sp)			# get $s0 value from stack					
		lw	$ra, 8($sp)			# get $ra value from stack
		addi	$sp, $sp, 12			# deallocate space in stack
							
		jr	$ra				# Return to main
						
							# Params: $a0 = value to add, $a1 = address of head
						
add_tail:	addi    $sp, $sp, -12			# allocate stack space for 3 slots
		sw      $ra, 8($sp)			# store return address on stack
		sw	$s0, 4($sp)			# store $s0 on stack
		sw	$s1, 0($sp)			# store $s1 on stack

		add	$t2, $a0, $zero			# Store in $t2 (new node value) a copy of first parameter by storing sum of $a0 and 0 in $t2
		add 	$t0, $a1, $zero			# Store in $t0 (currentnode addr) a copy of second parameter by storing sum of $a1 and 0 in $t0
		
							# Find current tail by looping through all current nodes
loop_tail:	lw	$t1, 4($t0)			# Store in $t1 address of the next node of the current node
		beq	$t1, 0xffffffff, tail		# if address of next node == NULL, branch to tail
		move	$t0, $t1			# else move to $t0 (current node address) value of $t1 (next node address) and
		j	loop_tail			# jump to start of loop (loop_tail)
		
tail:							# Once tail node is found, syscall will be called

							# Before issuing syscall, preserve arg across subroutine by
		add	$s0, $a0, $zero			# saving $a0 register value (value or data of node) to $s0 and
		add	$s1, $a1, $zero			# saving $a1 register value (address of current head) to $s1 and then
											 
							# Allocate 8 bytes (first 4 for data, last 4 for address of next node) in heap memory by
		li	$a0, 8				# setting the value of $a0 to 8 (because 8 bytes to allocate) and
		li	$v0, 9				# setting the value of $v0 to 9 (sbrk service number) and then
		syscall					# issuing a system call, resulting in $v0 containing the address of the allocated memory
		
							# After syscall, reinstate function parameters by
		move	$a0, $s0			# placing back to $a0 from $s0 and
		move	$a1, $s1			# and  placing back to $a1 from $s01
							
		sw	$t2, 0($v0)			# Store in allocated address ($v0 + 0) data of new node ($t2)
		li	$t5, 0xffffffff			# Store NULL value (0xffffffff) in $t5
		sw	$t5, 4($v0)			# Store NULL value (value in $t5) to second part of allocated address ($v0 + 4)
		sw	$v0, 4($t0) 			# Store in current_node.(next_node.address) ($t0 + 4) new allocated address ($v0 + 4)
		
		lw	$s1, 0($sp)			# get $s1 value from stack
		lw	$s0, 4($sp)			# get $s0 value from stack					
		lw	$ra, 8($sp)			# get $ra value from stack
		addi	$sp, $sp, 12			# deallocate space in stack
		
		jr	$ra				# Return to main
		
							# Params: $a0 = address of head
							
print_all:	
		addi    $sp, $sp, -8			# allocate stack space for 2 slots
		sw      $ra, 4($sp)			# store return address on stack
		sw	$s0, 0($sp)			# store $s0 on stack

		add	$t0, $a0, $zero			# Store address of head ($a0) to $t0 (address of current node)
		
							# Loop through all nodes but for each node
							# Print data of current node in hex by
loop_print:						# First, before issuing syscall, preserve arg across subroutine by
		add	$s0, $a0, $zero			# saving $a0 register value (value or data of node) to $s0
		
		lw	$a0, 0($t0)			# loading to $a0 data of current node ($t0 + 0) and
		li	$v0, 34				# setting the value of $v0 to 34 (print integer in hexadecimal) and then
		syscall					# issuing a system call, resulting the current node data to be printed in hex
		
							# Print space by
		li	$a0, 32				# setting the value of $a0 to 32 (ASCII code of space) and
		li	$v0, 11				# setting the value of $v0 to 11 (print character service number) and then
		syscall					# issuing a system call, resulting in a space character being printed
		
							# After syscall, reinstate function parameters by
		move	$a0, $s0			# placing back to $a0 from $s0

		lw	$t1, 4($t0)			# Store in $t1 address of next node ($t0 + 4)
		beq	$t1, 0xffffffff, end_print	# if address of next node == NULL (0xffffffff), branch to end_print
		move	$t0, $t1			# else current_node.address = next_node.address by moving address of the next node ($t1)
							# to address of current node ($t0) and
		j	loop_print			# loop (loop_print)
		
							# Once all node values have been printed, print newline by
end_print:						# First, before issuing syscall, preserve arg across subroutine by
		add	$s0, $a0, $zero			# saving $a0 register value (value or data of node) to $s0
		
		li	$a0, 10				# setting $a0 to 10 (ASCII code of newline) and
		li	$v0, 11				# setting $v0 to 11 (print character service number) and then
		syscall					# issuing a system call, resulting in a newline character being printed
		
							# After syscall, reinstate function parameters by
		move	$a0, $s0			# placing back to $a0 from $s0 
		
		lw	$s0, 0($sp)			# get $s0 value from stack					
		lw	$ra, 4($sp)			# get $ra value from stack
		addi	$sp, $sp, 8			# deallocate space in stack
		
		jr	$ra				# Return to main

exit:
		li $v0, 10
		syscall
