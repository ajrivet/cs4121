	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
	.comm _gp, 40, 4
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
	leave
	ret
