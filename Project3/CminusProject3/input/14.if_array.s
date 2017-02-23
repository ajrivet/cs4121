	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
.string_const0: .string "enter i ="
.string_const1: .string "out of bound!"
	.comm _gp, 404, 4
	.text
	.globl main
	.type main, @function
main:		nop
	pushq %rbp
	movq %rsp, %rbp
	movl $.string_const0, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rbx
	addq $400, %rbx
	movl $.int_rformat, %edi
	movl %ebx, %esi
	movl $0, %eax
	call scanf
	movq $_gp, %rcx
	addq $400, %rcx
	movl (%rcx), %r8d
	movl $0, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movq $_gp, %rcx
	addq $400, %rcx
	movl (%rcx), %r9d
	movl $100, %ebx
	cmpl %ebx, %r9d
	movl $0, %r9d
	movl $1, %ebx
	cmovge %ebx, %r9d
	orl %r9d, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L1
	movl $.string_const1, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	jmp .L2
.L1:	movq $_gp, %rcx
	addq $400, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $400, %rcx
	movl (%rcx), %r9d
	movl $2, %ebx
	imull %ebx, %r9d
	movl %r9d, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movl $5, %ebx
	movl $5, %ebx
	movq $_gp, %rcx
	addq $20, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $400, %rcx
	movl (%rcx), %r8d
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl (%rcx), %r9d
	movl %r9d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L2
.L2:	leave
	ret
