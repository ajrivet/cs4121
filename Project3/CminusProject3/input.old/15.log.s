.data
.newline: .asciiz "\n"
.text
.globl main
main: nop
	li $t0, 1
	sw $t0, 0($gp)
	li $t1, 2
	sw $t1, 4($gp)
	li $t2, 3
	sw $t2, 8($gp)
	li $t3, 4
	sw $t3, 12($gp)
	lw $t4, 0($gp)
	lw $t5, 4($gp)
	slt $t6, $t4, $t5
	sw $t6, 16($gp)
	lw $t7, 16($gp)
	li $s0, 1
	and $s1, $t7, $s0
	move $a0, $s1
	li $v0, 1
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	lw $s1, 12($gp)
	lw $s2, 8($gp)
	sgt $s3, $s1, $s2
	move $a0, $s3
	li $v0, 1
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	lw $s3, 12($gp)
	lw $s4, 8($gp)
	sgt $s5, $s3, $s4
	xori $s6, $s5, 1
	move $a0, $s6
	li $v0, 1
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	li $s6, 0
	lw $s7, 0($gp)
	lw $t8, 4($gp)
	slt $t9, $s7, $t8
	lw $t4, 8($gp)
	lw $t5, 12($gp)
	sne $t7, $t4, $t5
	and $s0, $t9, $t7
	or $s1, $s6, $s0
	move $a0, $s1
	li $v0, 1
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	li $v0, 10
	syscall
.data
