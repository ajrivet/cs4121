#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <util/general.h>
#include <util/symtab.h>
#include <util/symtab_stack.h>
#include <util/dlink.h>
#include <util/string_utils.h>
#include "mips_mgmt.h"

extern SymTable symtab;

int   g_STRING_INDEX    = 0;
long   g_GP_NEXT_OFFSET = 0;

#ifdef TEST_ME
#define PRINTF(...) printf(__VA_ARGS__)
#define PUTS(str) puts(str)
#else
#define PRINTF(...)
#define PUTS(str)
#endif

register_file_t g_RF = {
	{
/* 
 * Register names and availability initialization.
 * Only registers t0-t9 and s0-s7 are initially free.
 * Other registers are reserved for specific use.
 * Note: doesn't mean registers can never be used;
 * they just need to be used in a specific context.
 */
// 	Read-only", returns 0
		{ "zero",	false	},	
// 	Reserved for assembler
		{ "at",		false	},	
// 	Holds syscall values and expression values
		{ "v0",		false	},
		{ "v1",		false	},
// 	Function calls args
		{ "a0",		false	}, 
		{ "a1",		false	}, 
		{ "a2",		false	}, 
		{ "a3",		false	},
// 	Temporaries
		{ "t0",		true	}, 
		{ "t1",		true	}, 
		{ "t2",		true	}, 
		{ "t3",		true	}, 
		{ "t4",		true	}, 
		{ "t5",		true	},
		{ "t6",		true	},
		{ "t7",		true	},
// 	Preserved
		{ "s0",		true	}, 
		{ "s1",		true	}, 
		{ "s2",		true	},
		{ "s3",		true	},
		{ "s4",		true	}, 
		{ "s5",		true	}, 
		{ "s6",		true	}, 
		{ "s7",		true	},
// 	More temporaries
		{ "t8",		true	}, 
		{ "t9",		true	},
// 	Reserverd for OS Kernel
		{ "k0",		false	}, 
		{ "k1",		false	},
// 	Global pointer
		{ "gp",		false	},
// 	Frame pointer
		{ "fp",		false	}, 
// 	Stack pointer
		{ "sp",		false	},
// 	Return address
		{ "ra",		false	}	
	},
/* 
 * Number of free registers equals 
 * the number of regs which *can* be free
 */
	T9-T0,
/* 
 * Index of latest free register 
 */
	T0 
};



/*
 * Allocates a new register from the list of free registers.
 * Note: complexity is O(n), but the number of potentially free registers 
 * is very small (18), and (1) we start by checking if there is ANY free
 * register available, (2) we start from the latest place we found a free
 * register: hopefully this means we minimize the search time (not necessarily
 * true due to "fragmentation" of indices).
 */
reg_idx_t 
reg_alloc()
{
//	Should never happen in our context. WILL happen in more realistic ones!
	assert(g_RF.n_free > 0 && "no more registers available!"); 

//	Start where we left. 
	reg_idx_t i = g_RF.latest_free;
	do {
		if ( REG_FREE(i) ) {
			g_RF.latest_free = i;
			REG_FREE(i) = false;
			--g_RF.n_free;
			return i;
		}
// Reach end of regs which can be free? Then wrap to first reg which can be free 
		if ( ++i > T9 )	
			i = T0;	
	}  while ( i != g_RF.latest_free );

	return INVALID; // we should never get here.
}

/* 
 * Frees a register
 * Note: this implementation considers freeing an already-free register is 
 * an error. In practice, freeing a free register is not really a problem, 
 * but it most likely means you're freeing the *wrong* register...
 */
void
reg_free(reg_idx_t reg) 
{
	//assert(reg >= T0 && reg <= T9 && "reg index is not an allocatable register!");
	if (reg < T0 || reg > T9) {
		fprintf(stderr, "register index out of bounds. Index = %d\n", reg);
		abort();
	}
	assert(REG_FREE(reg) == false && "reg was not allocated!");
	REG_FREE(reg) = true;
	++g_RF.n_free;
}

/*
 * Issues the MIPS code sequence to print a new line on the standard output
 */
void 
write_new_line() 
{
	PUTS("#\tprint new line");
    if ( IS_EMPTY ) 
        printf("\tla $a0, .newline\n\tli $v0, 4\n\tsyscall\n");
    else 
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tla $a0, .newline\n\tli $v0, 4\n\tsyscall\n");
}

/*
 * Issues the MIPS code sequence to load and print a constant integer
 */
void
write_const_int(long value)
{
	PUTS("#\tprint constant value");
    if ( IS_EMPTY ) 
        printf("\tli $a0, %ld\n\tli $v0, 1\n\tsyscall\n", value);
    else 
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tli $a0, %ld\n\tli $v0, 1\n\tsyscall\n", 
                            value);
}

/*
 * Issues the MIPS code sequence to print the (integer) content of a register
 */
void 
write_reg_value(reg_idx_t reg) 
{
	assert(reg != INVALID && "reg != INVALID");
	PUTS("#\tprint register content");
    if ( IS_EMPTY ) {
        printf("\tmove $a0, $%s\n\tli $v0, 1\n\tsyscall\n", REG_NAME(reg) );
    } else {
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tmove $a0, $%s\n\tli $v0, 1\n\tsyscall\n", 
                            REG_NAME(reg) );
    }
}

/*
 * Issues the MIPS code sequence to print a constant string whose address 
 * is contained in register <reg>.
 */
void 
write_const_string(reg_idx_t reg) 
{
	assert(reg != INVALID && "reg != INVALID");
	PUTS("#\tprint constant string");
    if ( IS_EMPTY ) 
        printf("\tmove $a0, $%s\n\tli $v0, 4\n\tsyscall\n", REG_NAME(reg) ); 
    else 
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tmove $a0, $%s\n\tli $v0, 4\n\tsyscall\n", 
                            REG_NAME(reg) ); 
}

void
read_int(reg_idx_t dst)
{
	PRINTF("#\t%s = <stdin>\n");
    if ( IS_EMPTY ) 
        printf("\tli $v0, 5\n\tsyscall\n\tmove $%s, $v0\n", REG_NAME(dst));
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tli $v0, 5\n\tsyscall\n\tmove$%s, $v0\n",
                            REG_NAME(dst));
}

void
issue_move(reg_idx_t dst, reg_idx_t src)
{
	PRINTF("#\t%s = %s\n", REG_NAME(dst), REG_NAME(src));
    if ( IS_EMPTY )
        printf("\tmove %s, %s\n", REG_NAME(dst), REG_NAME(src));
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tmove %s, %s\n", 
                            REG_NAME(dst), REG_NAME(src));
}

/*
 * Issues a reputogister-to-register arithmetic or logic operation
 * <op> contains a string to the actual instruction name
 * <dst> holds the final result
 * <src1> is the register which holds the 1st operand
 * <src2> is the register which holds the 2nd operand
 */
void
issue_op(const char* op, reg_idx_t dst, reg_idx_t src1, reg_idx_t src2) 
{
	PRINTF("#\t%s = %s (%s,%s)\n", 
		REG_NAME(dst), op, REG_NAME(src1), REG_NAME(src2));
    if ( IS_EMPTY ) 
        printf("\t%s $%s, $%s, $%s\n", 
                op, REG_NAME(dst), REG_NAME(src1), REG_NAME(src2));
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\t%s $%s, $%s, $%s\n", 
                            op, REG_NAME(dst), REG_NAME(src1), REG_NAME(src2));
}

/*
 * Issues an arithmetic or logic operation with 
 * one register and one immediate as operands
 * <op> contains a string to the actual instruction name
 * <dst> holds the final result
 * <src> is the register which holds the reg value
 * <value> is the constant integer to use for 2nd operand
 */
void 
issue_op_imm(const char* op, reg_idx_t dst, reg_idx_t src, long value)
{
	PRINTF("#\t%s = %s (%s %ld)\n", 
		REG_NAME(dst), op, REG_NAME(src), value);
    if ( IS_EMPTY ) 
        printf("\t%si $%s, $%s, %ld\n", op, REG_NAME(dst), REG_NAME(src), value);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\t%si $%s, $%s, %ld\n", 
                            op, REG_NAME(dst), REG_NAME(src), value);
}

void
issue_beq(reg_idx_t op1, reg_idx_t op2, long label_id)
{
	PRINTF("# if %s != %s goto .L%ld\n", REG_NAME(dst), REG_NAME(base), label_id);
    if ( IS_EMPTY )
        printf("\tbeq $%s, $%s, .L%ld\n", REG_NAME(op1), REG_NAME(op2), label_id);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP,
                            "\tbeq $%s, $%s, .L%ld\n", 
                            REG_NAME(op1), REG_NAME(op2), label_id);
}

/*
 * Issues a load-word operation.
 * 	Synopsis: <dst> = *(<base> + <offset>);
 * <dst> holds the final result
 * <base> contains the base address where the word is stored. 
 * 	<base> can be one of $fp, $sp, or $gp
 * <offset> where to locate the word to load, starting from <base>
 */
void
issue_lw(reg_idx_t dst, reg_idx_t base, long offset)
{
//	the next line is not useful anymore
//	assert((base == GP || base == SP || base == FP) && "base is not a good base address!");
	PRINTF("#\t%s = %s[%ld]\n", REG_NAME(dst), REG_NAME(base), offset);
    if ( IS_EMPTY )
        printf("\tlw $%s, %ld($%s)\n", REG_NAME(dst), offset, REG_NAME(base));
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP, 
                            "\tlw $%s, %ld($%s)\n", 
                            REG_NAME(dst), offset, REG_NAME(base));
}

/*
 * Issues a store-word operation.
 * 	Synopsis: *(<base> + <offset>) = <src>;
 * <src> register which holds the value to write.
 * <base> contains the base address where the word is stored. 
 * 	<base> can be one of $fp, $sp, or $gp
 * <offset> where to locate the word to load, starting from <base>
 */
void
issue_sw(reg_idx_t src, reg_idx_t base, long offset)
{
//	the next line is not useful anymore
//	assert((base == GP || base == SP || base == FP) && "base is not a good base address!");
	PRINTF("#\t%s[%ld] = %s\n", REG_NAME(base), offset, REG_NAME(src));
    if ( IS_EMPTY )
        printf("\tsw $%s, %ld($%s)\n", REG_NAME(src), offset, REG_NAME(base));
    else 
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP, 
                            "\tsw $%s, %ld($%s)\n", 
                            REG_NAME(src), offset, REG_NAME(base));
}

/*
 * Issues a load-immediate (<dst> = <value>)
 * <dst> register which will hold the value
 * <value> immediate value to load
 */
void
issue_li(reg_idx_t dst, long value)
{
	PRINTF("#\t%s = %ld\n", REG_NAME(dst), value);
    if ( IS_EMPTY )
        printf("\tli $%s, %ld\n", REG_NAME(dst), value);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP, "\tli $%s, %ld\n", REG_NAME(dst), value);
}

/*
 * Issues a load-address (<dst> = <address>)
 * <dst> register which will hold the value
 * <address> immediate value to load
 */
void
issue_la(reg_idx_t dst, const char* str)
{
	PRINTF("#\t%s = %s\n", REG_NAME(dst), str);
    if ( IS_EMPTY )
        printf("\tla $%s, %s\n", REG_NAME(dst), str);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP, "\tla $%s, %s\n", REG_NAME(dst), str);
}

void
issue_jmp(long label_id)
{
    PRINTF("#\tgoto L%ld\n", label_id);
    if ( IS_EMPTY )
        printf("\tj .L%ld\n", label_id);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP, BUFFER_SZ-LEN_TOP, "\tj .L%ld\n", label_id);
}

void
print_label(long label_id)
{
    if ( IS_EMPTY )
        printf(".L%ld:\n", label_id);
    else
        LEN_TOP += snprintf(BUF_TOP+LEN_TOP,BUFFER_SZ-LEN_TOP, ".L%ld:\n", label_id);
}

void 
print_rf_state() {
#ifdef TEST_ME
	printf ("Register names and status:\n");
	for (reg_idx_t i = INVALID+1;  i < N_MIPS_REGS; ++i) {
		printf("%s is %s\n", REG_NAME(i), REG_FREE(i) ? "free" : "busy");
	}
#endif
}

void
print_prolog() 
{
	PUTS("# prolog");
	puts(".data");
	puts(".newline: .asciiz \"\\n\"");
	puts(".text");
	puts(".globl main");
	puts("main: nop");
}

void
print_epilog()
{
	PUTS("#\texit()ing the program");
	puts("\tli $v0, 10");
	puts("\tsyscall");
}

long getValue(int idx);
int setValue(int idx,long value);
/*
 * Prints all the strings that were found during the parse, one after the other
 * all string keys start with __str (which is not in the namespace of the Cminus language)
 */
void print_string_labels() {
	int i = 0;
	char string[10]; // we should never go beyond 10 characters for a string index...
	printf(".data\n");
	for (i = 0 ; i < g_STRING_INDEX; ++i) {
		snprintf(string, 10u, "__str%d", i);
		printf("%s: .asciiz \"%s\"\n", string, (char*)getValue(SymIndex(symtab, string)));
	}
}

stack_t g_STACK;

void 
stack_init(stack_t* stack)
{
    assert(stack != NULL && "Stack is null!");
    memset(stack, 0, sizeof(stack_t));
    stack->is_empty = true;
}

void
elt_init(elt_t** elt)
{
    elt_t *e = *elt;
    if (!e) {
        e = XMALLOC( sizeof(elt_t) );
        memset( e, 0, sizeof(elt_t) );
    }
    if (!e->buffer) {
        e->buffer = XMALLOC( BUFFER_SZ );
        memset(e->buffer, 0, BUFFER_SZ);
    }

    *elt = e;
}

elt_t*
stack_top(stack_t* stack) 
{
    assert(stack != NULL && "stack is null!");
    assert(stack->is_empty == false && "Stack is empty!");
    return stack->elts[stack->top];
}

elt_t*
stack_pop(stack_t* stack)
{
    elt_t* elt = NULL;

    assert(stack != NULL && "stack is null!");
    assert(stack->is_empty == false && "Cannot pop from empty stack!");

    size_t top = stack->top;
    elt = stack->elts[top];

    if (top == 0) /* Found the last element of the stack */
        stack->is_empty = true;
    else 
        --stack->top;

    stack->elts[top] = NULL;

    return elt;
}

void
stack_push(stack_t* stack) 
{
    assert(stack != NULL && "stack is null!");
    assert(stack->top < STACK_SZ && "stack is full!");

    size_t top = stack->top;
    if (stack->is_empty) {
        stack->is_empty = false;
    } else {
        ++top;
    }

    if (stack->elts[top] == NULL) {
        elt_init( &stack->elts[top] );
    } 

    stack->top = top;
}

int 
elt_merge(elt_t* dst, elt_t* src)
{
    size_t rem_len = 0; 
    int    success = -1;

    assert(dst && "destination is null!");
    assert(src && "source is null!");

    rem_len = BUFFER_SZ - dst->buf_len;
    if (rem_len >= src->buf_len) {
        strcpy(dst->buffer + dst->buf_len, src->buffer);
        dst->buf_len += src->buf_len;
        // should not be needed, but you never know...
        dst->buffer[dst->buf_len] = '\0';
        success = 0; // In traditional C, 0 is the value for success
    }

    return success;
}

void
elt_destroy(elt_t* e)
{
    XFREE(e->buffer);
    XFREE(e);
}

void 
merge_levels(stack_t* stack, const size_t n_levels)
{
    assert(stack && "stack is null!");
    assert(n_levels > 1UL && "need at least 2 levels to merge");
    assert(n_levels <= stack->top+1 && "asking to merge more levels than exist!");

    size_t cur_lvl;
    for (cur_lvl = n_levels; cur_lvl > 1; --cur_lvl) {
        elt_t *elt_to_mrg = stack_pop(stack),
              *top_elt    = stack_top(stack);
        elt_merge(top_elt, elt_to_mrg);
        elt_destroy(elt_to_mrg);
//      Technically, the next line is not needed, but it may help with detecting 
//      off-by-one errors/buffer overflows.        
//      memset(elt_to_mrg->buffer, 0, BUFFER_SZ);
    }
}

void
stack_destroy_content(stack_t* stack)
{
    while ( ! stack->is_empty ) {
        elt_t* e  = NULL;
        if (stack->top == 0) {
            stack->is_empty = true;
            e = stack->elts[0];
        } else {
            e = stack_pop(stack);
        }
        elt_destroy(e);
    }
}

void
stack_print(stack_t* stack)
{
    puts("printing stack state");
    if (stack->is_empty) return;
    long i = (long)stack->top;
    do {
        if (!stack->elts[i]) {
            fprintf(stderr, "Huh? stack level %ld is null\n", i);
            continue;
        } 
        if (!stack->elts[i]->buffer) {
            fprintf(stderr, "Huh? buffer @ stack level %ld is null\n", i);
            continue;
        }
        printf (
            "L%ld:\t%s\t(%lu chars)\n", 
            stack->elts[i]->label_id[0], stack->elts[i]->buffer, stack->elts[i]->buf_len
        );
        fflush(stdout);
    } while (--i >= 0);
}

size_t g_NXT_LBL_ID;

#ifdef TEST_ME
#	ifdef MAIN
int 
main(void)
{
	print_prolog();

//	Compute 1 + 2
	reg_idx_t r1     = reg_alloc(), 
		  r2     = reg_alloc(), 
		  result = reg_alloc();
	issue_li(r1, 1);
	issue_li(r2, 2);
	ISSUE_ADD(result, r1, r2);
	reg_free(r1);
	reg_free(r2);

//	Compute result *= 3
	r1 = reg_alloc();
	issue_li(r1, 3);
	ISSUE_MUL(result, result, r1); 
	reg_free(r1);
	reg_free(result);

//	Display result
	write_reg_value(result);
	write_new_line();

	return 0;
}
#	endif // MAIN
#endif // TEST_ME
