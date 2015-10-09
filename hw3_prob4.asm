.text
.globl main

.macro print_str($arg)
	la	$a0,$arg	# put address of format string in a0
	li	$v0,4		# set up system call 4 (print_string)
	syscall			# print
.end_macro

.macro print_int($arg)
	move	$a0,$arg	# set up int for printing
	li	$v0,1		# set up system call 1 (print_int)
	syscall
.end_macro




.data 
out1:	.asciiz	"\n"
fp1:	.float 0.5

.text
main:
	subu	$sp,$sp,12	# stack frame is 16 bytes long
	sw 	$ra,4($sp)	# save the return address
	sw	$fp,8($sp)	# save old frame epointer
	addiu	$fp,$sp,12	# set up frame pointer

	li	$a0, 1		# set up arguments
	move	$s0, $a0	#save $a0 so it can be used in macros
	li	$a1, 2
	li	$a2, 3
	l.s 	$f0, fp1
	mfc1	$a3, $f0

	print_int($a0)
	print_str(out1)
	print_int($a1)	
	print_str(out1)
	print_int($a2)	
	print_str(out1)
	mtc1	$a3,$f12	# print float
	li	$v0,2		# sadly floating point instr
	syscall			# don't work in macros
	print_str(out1)
	print_str(out1)

	move	$a0, $s0	# restore $a0 since changed during printing

	jal	f		# call f

	mtc1	$v0,$f12	# print float
	li	$v0,2		# sadly floating point instr
	syscall			# don't work in macros
	print_str(out1)	
						
	lw	$ra, 4($sp)	# restore the stack
	lw	$fp, 8($sp)
	addu	$sp, $sp, 12
#	jr	$ra		# return to caller
# in MARS this call results in an invalid program counter error. The
# reason is that there is no actual OS to call our main, and so the $ra
# register does not have a valid instruction address (pointing to some
# OS code) before our main is called. One way to get rid of that error
# is to do an exit system call at the end of main as follow:
	li	$v0,10		# set up system call 10 (exit)
	syscall	
		

.text

func:	subu	$sp,$sp,8	# stack frame is 16 bytes long
	sw 	$ra,0($sp)	# save the return address
	sw	$fp,4($sp)	# save old frame epointer
	addiu	$fp,$sp,8	# set up frame pointer
	
	add	$v0, $a0, $a1

	lw	$ra, 0($sp)	# restore the stack
	lw	$fp, 4($sp)
	addu	$sp, $sp, 8
	jr	$ra		#and return

## Implement the function f below
#float f(int a, int b, int c, float d ){
#   return func(func(a, b), c) * d;
#}
f: 	subu	$sp,$sp,8	# stack frame is 16 bytes long
	sw 	$ra,0($sp)	# save the return address
	sw	$fp,4($sp)	# save old frame epointer
	addiu	$fp,$sp,8	# set up frame pointer
	
	# a0 and a1 need to be passed, already in the right place though
	jal func		#call func

	move $a0, $v0 		# move the result to first arg
	move $a1, $a2 		# move c to second arg
	
	jal func		# call func again
	
	mtc1 $v0, $f1		# move result to a float register
	cvt.s.w $f1, $f1	# convert from int to float
	mtc1 $a3, $f2		# move d to fpu (it wants the d)
	mul.s $f0, $f1, $f2	# mmmmm dat sexy mutliplication bby
	mfc1 $v0, $f0		# move result of mult back to v0

	lw	$ra,0($sp)	# restore the stack
	lw	$fp,4($sp)
	addiu	$sp, $sp, 8
	jr	$ra		#and return
