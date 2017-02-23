	.section	.rodata
.int_wformat: .string "%d\n"
.str_wformat: .string "%s\n"
.int_rformat: .string "%d"
.string_const0: .string "enter a:"
.string_const1: .string "enter b:"
.string_const2: .string "a = "
.string_const3: .string "b = "
.string_const4: .string "a = "
.string_const5: .string "b = "
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
	movl $.string_const1, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rbx
	addq $4, %rbx
	movl $.int_rformat, %edi
	movl %ebx, %esi
	movl $0, %eax
	call scanf
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r9d
	cmpl %r9d, %r8d
	movl $0, %r8d
	movl $1, %r9d
	cmovg %r9d, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L1
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $0, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovg %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L3
	movl $.string_const2, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L4
.L3:	movl $.string_const3, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L4
.L4:	jmp .L5
.L1:	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl $0, %ebx
	cmpl %ebx, %r8d
	movl $0, %r8d
	movl $1, %ebx
	cmovl %ebx, %r8d
	movl $-1, %ebx
	testl %ebx, %r8d
	je .L6
	movl $.string_const4, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $0, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L7
.L6:	movl $.string_const5, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.str_wformat, %edi
	call printf
	movq $_gp, %rcx
	addq $4, %rcx
	movl (%rcx), %r8d
	movl %r8d, %ebx
	movl %ebx, %esi
	movl $0, %eax
	movl $.int_wformat, %edi
	call printf
	jmp .L7
.L7:	jmp .L8
.L5:	jmp .L8
.L8:	leave
	ret
