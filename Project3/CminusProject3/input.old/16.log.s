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
	xori $s0, $t7, 1
	move $a0, $s0
	li $v0, 1
	syscall
	lw $s0, 0($gp)
	lw $s1, 4($gp)
	seq $s2, $s0, $s1
	move $a0, $s2
	li $v0, 1
	syscall
	lw $s2, 0($gp)
	lw $s3, 0($gp)
	seq $s4, $s2, $s3
	move $a0, $s4
	li $v0, 1
	syscall
	lw $s4, 12($gp)
	lw $s5, 8($gp)
	sgt $s6, $s4, $s5
	move $a0, $s6
	li $v0, 1
	syscall
	lw $s6, 4($gp)
	lw $s7, 4($gp)
	sge $t8, $s6, $s7
	move $a0, $t8
	li $v0, 1
	syscall
	lw $t8, 8($gp)
	lw $t9, 0($gp)
	sle $t4, $t8, $t9
	move $a0, $t4
	li $v0, 1
	syscall
	lw $t4, 0($gp)
	lw $t5, 4($gp)
	sne $t7, $t4, $t5
	move $a0, $t7
	li $v0, 1
	syscall
	lw $t7, 12($gp)
	lw $s0, 8($gp)
	sgt $s1, $t7, $s0
	xori $s2, $s1, 1
	move $a0, $s2
	li $v0, 1
	syscall
	lw $s2, 0($gp)
	lw $s3, 4($gp)
	sgt $s4, $s2, $s3
	lw $s5, 12($gp)
	lw $s6, 8($gp)
	sgt $s7, $s5, $s6
	or $t8, $s4, $s7
	move $a0, $t8
	li $v0, 1
	syscall
	lw $t8, 4($gp)
	lw $t9, 0($gp)
	sgt $t4, $t8, $t9
	lw $t5, 12($gp)
	lw $t7, 8($gp)
	sgt $s0, $t5, $t7
	and $s1, $t4, $s0
	move $a0, $s1
	li $v0, 1
	syscall
	lw $s1, 0($gp)
	lw $s2, 4($gp)
	seq $s3, $s1, $s2
	lw $s4, 0($gp)
	lw $s5, 4($gp)
	slt $s6, $s4, $s5
	or $s7, $s3, $s6
	lw $t8, 8($gp)
	lw $t9, 12($gp)
	sne $t4, $t8, $t9
	and $t5, $s7, $t4
	move $a0, $t5
	li $v0, 1
	syscall
	li $v0, 10
	syscall
.data
