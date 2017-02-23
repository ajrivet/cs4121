.data
.newline: .asciiz "\n"
.text
.globl main
main: nop
	la $t0, __str0
	move $a0, $t0
	li $v0, 4
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	addi $t0, $gp, 0
	li $v0, 5
	syscall
	move $t1, $v0
	sw $t1, -1($gp)
	addi $t1, $gp, 0
	lw $t2, 0($t1)
	li $t3, 0
	sne $t4, $t2, $t3
	xori $t4, $t4, 1
	beq $t4, $zero, .L0
	li $t4, 1
	move $a0, $t4
	li $v0, 1
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
.L0:

	la $t4, __str1
	move $a0, $t4
	li $v0, 4
	syscall
	la $a0, .newline
	li $v0, 4
	syscall
	li $v0, 10
	syscall
.data
__str0: .asciiz "enter a:"
__str1: .asciiz "complete!"