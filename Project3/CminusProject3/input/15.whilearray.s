	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
	.comm _gp, 44, 4
	.text
	.globl main
	.type main, @function
main:		nop
	pushq %rbp
	movq %rsp, %rbp
	movl $0, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L1:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $10, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L2
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r9d
	movl %r9d, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $4, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L2:	movl $0, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L4
.L4:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $10, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L5
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $5, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L7
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $4, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl (%rcx), %r9d
	movl %r9d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L8
.L7:	movl $0, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L8
.L8:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L4
.L5:	leave
	ret
