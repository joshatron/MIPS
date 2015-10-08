.text
.globl main

.macro print_int($arg)
	move	$a0,$arg	# set up int for printing
	li	$v0,1		# set up system call 1 (print_int)
	syscall
.end_macro

main:
	subu	$sp,$sp,24	# stack frame is 24 bytes long
	sw 	$ra,20($sp)	# save the return address
	sw	$fp,16($sp)	# save old frame epointer
	addiu	$fp,$sp,24	# set up frame pointer
	
	li	$a0,3		# put argument in $a0                    HERE IS THE INPUT FOR THE FUNCTION
	move	$s0,$a0		# save the argument
	jal	fib		# call the factorial function
	nop 
	move	$s1,$v0		# save the result
	
	la	$a0,out1	# put address of format string in a0
	li	$v0,4		# set up system call 4 (print_string)
	syscall			# print
	move	$a0,$s0		# set up argument for printing
	li	$v0,1		# set up system call 1 (print_int)
	syscall			# print
	la	$a0,out2	# put address of format string in a0
	li	$v0,4		# set up system call 4 (print_string)
	syscall	
	print_int($s1)
#	move	$a0,$s1		# set up return for printing
#	li	$v0,1		# set up system call 1 (print_int)
#	syscall
	la	$a0,out3	# put address of format string in a0
	li	$v0,4		# set up system call 4 (print_string)
	syscall	
						
	lw	$ra,20($sp)	# return return address
	lw	$fp,16($sp)	# restore frame pointer
	addiu	$sp,$sp,24	# pop the stack frame
#	jr	$ra		# return to caller
# in MARS this call results in an invalid program counter error. The
# reason is that there is no actual OS to call our main, and so the $ra
# register does not have a valid instruction address (pointing to some
# OS code) before our main is called. One way to get rid of that error
# is to do an exit system call at the end of main as follow:
	li	$v0,10		# set up system call 10 (exit)
	syscall	
		
	
.data 
out1:	.asciiz	"The fibonacci of "
out2:	.asciiz	" is "
out3:	.asciiz	"\n"

.text
fib:
    #adminstrative stuff
	subu	$sp,$sp,24
	sw 	    $ra,20($sp)
	sw	    $fp,16($sp)
	addiu	$fp,$sp,24
	sw	    $a0,0($fp)

    #if greater than 1, go to recursive part, otherwise add n to return
	slti    $t0, $a0, 2
	beq     $t0, $zero, L1
	add 	$v0, $zero, $a0

    #adminstrative stuff and return
	lw	    $ra,20($sp)
	lw	    $fp,16($sp)
	addiu	$sp,$sp,24
	jr	    $ra
	nop

    #recursively go into n - 1
L1:	addi 	$a0, $a0, -1
	jal  	fib
	nop
	lw   	$a0, 0($fp)
	add  	$v0, $a0, $v0

    #recursively go into n - 2
	addi 	$a0, $a0, -1
	jal  	fib
	nop
	lw   	$a0, 0($fp)
	add  	$v0, $a0, $v0

    #adminstrative stuff and return
	lw	    $ra,20($sp)
	lw	    $fp,16($sp)
	addiu	$sp,$sp,24
	jr	    $ra
	nop
