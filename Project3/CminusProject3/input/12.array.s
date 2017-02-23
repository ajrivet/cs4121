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
	movl $3, %ebx
	movl $4, %ebx
	movq $_gp, %rcx
	addq $12, %rcx
	movl %ebx, (%rcx)
	movl $3, %ebx
	movq $_gp, %rcx
	addq $12, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movl $3, %ebx
	movq $_gp, %rcx
	addq $40, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $40, %rcx
	movl (%rcx), %r8d
	movl $7, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $40, %rcx
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
	movq $_gp, %rcx
	addq $40, %rcx
	movl (%rcx), %r8d
	movl $2, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $40, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $40, %rcx
	movl (%rcx), %r8d
	movl $22, %ebx
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $0, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl %ebx, (%rcx)
	movl $5, %ebx
	movq $_gp, %rcx
	addq $20, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	leave
	ret
