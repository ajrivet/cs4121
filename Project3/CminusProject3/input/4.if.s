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
	movl $0, %ebx
	movq $_gp, %rcx
	addq $0, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $2, %ebx
	subl %ebx, %r8d
	movl %r8d, %ebx
	movq $_gp, %rcx
	addq $4, %rcx
	movl %ebx, (%rcx)
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L1
	movl $1, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L2
.L1:	movl $0, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L2
.L2:	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L4
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L6
	movl $0, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L7
.L6:	movl $1, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L7
.L7:	jmp .L8
.L4:	movl $0, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L8
.L8:	leave
	ret
