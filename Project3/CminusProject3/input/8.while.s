	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
	.comm _gp, 8, 4
	.text
	.globl main
	.type main, @function
main:		nop
	pushq %rbp
	movq %rsp, %rbp
	movl $1, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L1:	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl $10, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovle %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L2
	movl $1, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L3
.L3:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $10, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovle %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L4
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r9d
	imull %r9d, %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	jmp .L3
.L4:	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L2:	leave
	ret
