	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
	.comm _gp, 412, 4
	.text
	.globl main
	.type main, @function
main:		nop
	pushq %rbp
	movq %rsp, %rbp
	movl $0, %ebx
	movq $_gp, %rcx
	addq $200, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L1:	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $50, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L2
	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $0, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $200, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L2:	movl $0, %ebx
	movq $_gp, %rcx
	addq $204, %rcx
	movl %ebx, (%rcx)
	jmp .L4
.L4:	movq $_gp, %rcx
	addq $204, %rcx
	movl (%rcx), %r8d
	movl $50, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L5
	movq $_gp, %rcx
	addq $204, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $204, %rcx
	movl (%rcx), %r9d
	movl $50, %ebx
	addl %ebx, %r9d
	movl %r9d, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $212, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $204, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $204, %rcx
	movl %ebx, (%rcx)
	jmp .L4
.L5:	movl $0, %ebx
	movq $_gp, %rcx
	addq $200, %rcx
	movl %ebx, (%rcx)
	movl $0, %ebx
	movq $_gp, %rcx
	addq $208, %rcx
	movl %ebx, (%rcx)
	jmp .L7
.L7:	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $100, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L8
	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $50, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L10
	movq $_gp, %rcx
	addq $208, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r9d
	movl %r9d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl (%rcx), %r10d
	addl %r10d, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $208, %rcx
	movl %ebx, (%rcx)
	jmp .L11
.L10:	movq $_gp, %rcx
	addq $208, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r9d
	movl $50, %ebx
	subl %ebx, %r9d
	movl %r9d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $212, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl (%rcx), %r10d
	addl %r10d, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $208, %rcx
	movl %ebx, (%rcx)
	jmp .L11
.L11:	movq $_gp, %rcx
	addq $200, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $200, %rcx
	movl %ebx, (%rcx)
	jmp .L7
.L8:	movq $_gp, %rcx
	addq $208, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movl $5, %ebx
	movq $_gp, %rcx
	addq $20, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movl $10, %ebx
	movq $_gp, %rcx
	addq $252, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	leave
	ret
