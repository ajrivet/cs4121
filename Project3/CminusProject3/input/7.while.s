	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
.string_const0: .string "enter a:"
	.comm _gp, 12, 4
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
	addq $0, %rbx
	movl $.int_rformat, %edi
	movl %ebx, %esi
	movl $0, %eax
	call scanf
	movl $0, %ebx
	movq $_gp, %rcx
	addq $8, %rcx
	movl %ebx, (%rcx)
	movl $0, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L1:	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r9d
	cmpl %r9d, %r8d
	movl $0, %r8d
	movl $1, %r9d
	cmovle %r9d, %r8d
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r9d
	movl $100, %ebx
	cmpl %ebx, %r9d
	movl $0, %r9d
	movl $1, %ebx
	cmovle %ebx, %r9d
	andl %r9d, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L2
	movq $_gp, %rcx
	addq $8, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r9d
	addl %r9d, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $8, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl $1, %ebx
	addl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	jmp .L1
.L2:	movq $_gp, %rcx
	addq $8, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	leave
	ret
