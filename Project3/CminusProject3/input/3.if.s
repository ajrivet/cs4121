	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
.string_const0: .string "Enter a:"
	.comm _gp, 8, 4
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
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L1
	movl $1, %ebx
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
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L2
.L1:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L2
.L2:	leave
	ret
