	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
	.comm _gp, 64, 4
	.text
	.globl main
	.type main, @function
main:		nop
	pushq %rbp
	movq %rsp, %rbp
	movl $3, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	movl $4, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	movl $5, %ebx
	movq $_gp, %rcx
	addq $8, %rcx
	movl %ebx, (%rcx)
	movl $13, %ebx
	movq $_gp, %rcx
	addq $52, %rcx
	movl %ebx, (%rcx)
	movl $14, %ebx
	movq $_gp, %rcx
	addq $56, %rcx
	movl %ebx, (%rcx)
	movl $15, %ebx
	movq $_gp, %rcx
	addq $60, %rcx
	movl %ebx, (%rcx)
	movl $0, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	subl %r8d, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl %r8d, %r14d
	movslq %r14d, %r14
	imulq $4, %r14
	addq $12, %r14
	movq $_gp, %rcx
	addq %r14, %rcx
	movl (%rcx), %r9d
	movl %r9d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movl $11, %ebx
	movq $_gp, %rcx
	addq $56, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $60, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movl $12, %ebx
	movl $100, %ebx
	movq $_gp, %rcx
	addq $60, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $60, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	leave
	ret
