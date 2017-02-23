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

int   g_STRING_INDEX   = 0;
int   g_GP_NEXT_OFFSET = 0;

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
	puts("\tla $a0, .newline");
	puts("\tli $v0, 4");
	puts("\tsyscall");
}

/*
 * Issues the MIPS code sequence to load and print a constant integer
 */
void
write_const_int(int value)
{
	PUTS("#\tprint constant value");
	printf("\tli $a0, %d\n", value);
	puts("\tli $v0, 1");
	puts("\tsyscall");
}

/*
 * Issues the MIPS code sequence to print the (integer) content of a register
 */
void 
write_reg_value(reg_idx_t reg) 
{
	assert(reg != INVALID && "reg != INVALID");
	PUTS("#\tprint register content");
	printf("\tmove $a0, $%s\n", REG_NAME(reg) );
	puts("\tli $v0, 1");
	puts("\tsyscall");
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
	printf("\tmove $a0, $%s\n", REG_NAME(reg) ); 
	puts("\tli $v0, 4");
	puts("\tsyscall");
}

void
read_int(reg_idx_t dst)
{
	PRINTF("#\t%s = <stdin>\n");
	puts("\tli $v0, 5");
	puts("\tsyscall");
	printf("\tmove $%s, $v0\n", REG_NAME(dst));
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
	printf("\t%s $%s, $%s, $%s\n", 
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
issue_op_imm(const char* op, reg_idx_t dst, reg_idx_t src, int value)
{
	PRINTF("#\t%s = %s (%s %d)\n", 
		REG_NAME(dst), op, REG_NAME(src), value);
	printf("\t%si $%s, $%s, %d\n", op, REG_NAME(dst), REG_NAME(src), value);
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
issue_lw(reg_idx_t dst, reg_idx_t base, int offset)
{
	assert((base == GP || base == SP || base == FP) && "base is not a good base address!");
	PRINTF("#\t%s = %s[%d]\n", REG_NAME(dst), REG_NAME(base), offset);
	printf("\tlw $%s, %d($%s)\n", REG_NAME(dst), offset, REG_NAME(base));
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
issue_sw(reg_idx_t src, reg_idx_t base, int offset)
{
	assert((base == GP || base == SP || base == FP) && "base is not a good base address!");
	PRINTF("#\t%s[%d] = %s\n", REG_NAME(base), offset, REG_NAME(src));
	printf("\tsw $%s, %d($%s)\n", REG_NAME(src), offset, REG_NAME(base));
}

/*
 * Issues a load-immediate (<dst> = <value>)
 * <dst> register which will hold the value
 * <value> immediate value to load
 */
void
issue_li(reg_idx_t dst, int value)
{
	PRINTF("#\t%s = %d\n", REG_NAME(dst), value);
	printf("\tli $%s, %d\n", REG_NAME(dst), value);
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
	printf("\tla $%s, %s\n", REG_NAME(dst), str);
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

int getValue(int);
int setValue(int,int);
/*
 * Prints all the strings that were found during the parse, one after the other
 * all string keys start with __str (which is not in the namespace of the Cminus language)
 */
void print_string_labels() {
	int i = 0;
	char string[10]; // we should never go beyond 10 characters for a string index...
	printf(".data\n");
	for (i = 0 ; i < g_STRING_INDEX; ++i) {
		sprintf(string, "__str%d", i);
		printf("%s: .asciiz \"%s\"\n", string, getValue(SymIndex(symtab, string)));
	}
}


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
