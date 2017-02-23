#ifndef MIPS_MGMT_H_GUARD
#define MIPS_MGMT_H_GUARD

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <unistd.h>


#ifndef bool
#define true 1
#define false 0
#endif

typedef enum mips_idx_e {
	INVALID	= -1,
	ZERO	= 0,			// read-only, returns 0
	AT,				// reserved for assembler
	V0, V1,				// holds syscall values and expression values
	A0, A1, A2, A3, 		// syscall args
	T0, T1, T2, T3, T4, T5, T6, T7,	// temporaries
	S0, S1, S2, S3, S4, S5, S6, S7,	// preserved
	T8, T9, 			// more temporaries
	K0, K1, 			// reserved for OS kernel
	GP, 				// Global pointer
	FP, SP, 			// frame and stack pointers
	RA,				// return address
	N_MIPS_REGS			// number of MIPS registers
} reg_idx_t;

#if 0
char reg_names[N_MIPS_REGS][5] {
	"ZERO",						// read-only", returns 0
	"AT",						// reserved for assembler
	"V0", "V1",					// holds syscall values and expression values
	"A0", "A1", "A2", "A3", 			// syscall args
	"T0", "T1", "T2", "T3", "T4", "T5", "T6", "T7",	// temporaries
	"S0", "S1", "S2", "S3", "S4", "S5", "S6", "S7",	// preserved
	"T8", "T9", 					// more temporaries
	"K0", "K1", 					// reserved for OS kernel
	"GP", 						// Global pointer
	"FP", "SP", 					// frame and stack pointers
	"RA",						// return address
};
#endif 

typedef struct reg_s {
	char*	name;
	int	is_free;
} reg_t;


typedef struct register_file_s {
	reg_t	registers[N_MIPS_REGS];		// name and availability of registers
	int	n_free,				// how many free regs are left
		latest_free;			// index of latest free reg available
} register_file_t;

extern register_file_t	g_RF;
extern long 		g_GP_NEXT_OFFSET;
extern int              g_STRING_INDEX;

void      print_prolog          ();
void      print_epilog          ();
void      print_string_labels   ();
reg_idx_t reg_alloc             ();
void      reg_free              (reg_idx_t   reg);
void      write_new_line        ();
void      read_int              (reg_idx_t   dst);
void      write_const_int       (long        value);
void      write_reg_value       (reg_idx_t   reg);
void      write_const_string    (reg_idx_t   reg);
void      issue_op              (const char* op,  reg_idx_t dst,  reg_idx_t src1, reg_idx_t src2);
void      issue_op_imm          (const char* op,  reg_idx_t dst,  reg_idx_t src,  long value);
void      issue_lw              (reg_idx_t   dst, reg_idx_t base,                 long offset);
void      issue_sw              (reg_idx_t   src, reg_idx_t base,                 long offset);
void      issue_li              (reg_idx_t   dst, long offset);
void      issue_la              (reg_idx_t   dst, const char* str_label);
void      issue_jmp             (long label_id);
void      issue_move            (reg_idx_t   dst, reg_idx_t src); 
void      issue_beq             (reg_idx_t   op1, reg_idx_t op2, long label_id);
void      print_label           (long label_id);

#define REG_NAME(idx) g_RF.registers[(idx)].name
#define REG_FREE(idx) g_RF.registers[(idx)].is_free

#define ISSUE_ADD(dst, src1, src2)	do { issue_op("add", (dst), (src1), (src2)); } while (0)
#define ISSUE_SUB(dst, src1, src2)	do { issue_op("sub", (dst), (src1), (src2)); } while (0)
#define ISSUE_MUL(dst, src1, src2)	do { issue_op("mul", (dst), (src1), (src2)); } while (0)
#define ISSUE_DIV(dst, src1, src2)	do { issue_op("div", (dst), (src1), (src2)); } while (0)
#define ISSUE_XOR(dst, src1, src2)	do { issue_op("xor", (dst), (src1), (src2)); } while (0)
#define ISSUE_OR(dst,  src1, src2)	do { issue_op("or", (dst), (src1), (src2));  } while (0)
#define ISSUE_AND(dst, src1, src2)	do { issue_op("and", (dst), (src1), (src2)); } while (0)

#define ISSUE_ADDI(dst, src1, src2)	do { issue_op_imm("add", (dst), (src1), (src2)); } while (0)
#define ISSUE_SUBI(dst, src1, src2)	do { issue_op_imm("sub", (dst), (src1), (src2)); } while (0)
#define ISSUE_MULI(dst, src1, src2)	do { issue_op_imm("mul", (dst), (src1), (src2)); } while (0)
#define ISSUE_DIVI(dst, src1, src2)	do { issue_op_imm("div", (dst), (src1), (src2)); } while (0)
#define ISSUE_XORI(dst, src1, src2)	do { issue_op_imm("xor", (dst), (src1), (src2)); } while (0)
#define ISSUE_ORI(dst,  src1, src2)	do { issue_op_imm("or", (dst), (src1), (src2));  } while (0)
#define ISSUE_ANDI(dst, src1, src2)	do { issue_op_imm("and", (dst), (src1), (src2)); } while (0)

#define KB        1024U
#define MB        1024U*KB
#define BUFFER_SZ    8U*KB
#define STACK_SZ   100U

static inline void
fatal(const char* msg)
{
    perror(msg);
    exit(errno);
}

static inline void*
xmalloc(size_t sz, const char* filename, const size_t lineno)
{
    void* p = malloc( sz );
    if (!p) {
        fprintf(stderr, "%s, line %lu:\t", filename, lineno);
        fatal("malloc");
    }
    return p;
}

static inline void
xfree(void* p)
{
    if (p) 
        *(char*)p = 0;
    free(p);
}

#define XMALLOC(sz) xmalloc((sz), __FILE__, __LINE__)
#define XFREE(p)    xfree((p))

typedef struct elt_s {
    /** Current local label ID  */
    uint64_t  label_id[2];
    /** How many bytes written so far in each buffer? */
    size_t    buf_len;
    /** buffer, for both if and then */
    char     *buffer; 
    /** Am I in an else region? */
    bool      is_in_else, 
    /** Am I in a while region? */
              is_in_while;
} elt_t;

typedef struct stack_s {
    /** Array of pointers to elements in the stack */
    elt_t *elts[STACK_SZ];
    /** Index to element at the top of the stack */
    size_t top;
    /** Field to check before pop()ing or reading the top of the stack */
    bool   is_empty;
} stack_t;

extern stack_t g_STACK;
extern size_t  g_NXT_LBL_ID;


void stack_init(stack_t* stack);
void elt_init(elt_t** elt);
elt_t* stack_top(stack_t* stack);
elt_t* stack_pop(stack_t* stack);
void   stack_push(stack_t* stack);
void   stack_destroy_content(stack_t* stack);
void   merge_levels(stack_t* stack, const size_t n_levels);
void   elt_destroy(elt_t* e);

#define MERGE_LEVELS(n_lvl) merge_levels(&g_STACK,n_lvl)

#define TOP()        stack_top(&g_STACK)
#define POP()        stack_pop(&g_STACK)
#define PUSH()       stack_push(&g_STACK)

#define WHILE_START_LBL   TOP()->label_id[0]
#define WHILE_END_LBL     TOP()->label_id[1]
#define IF_LBL            TOP()->label_id[0]
#define ELSE_LBL          TOP()->label_id[1]

#define IDX_TOP           g_STACK.top
#define BUF_TOP           TOP()->buffer
#define LEN_TOP           TOP()->buf_len
#define IS_IN_WHILE       TOP()->is_in_while
#define GLOB_IS_IN_WHILE  g_STACK.in_while
#define IS_IN_ELSE        TOP()->is_in_else
#define LABEL_ID_TOP      TOP()->label_id
#define LABEL_ID_GLOB     g_STACK.label_id
#define IS_EMPTY          g_STACK.is_empty
#define IS_FULL           (g_STACK.top == (STACK_SZ - 1))

#endif	// MIPS_MGMT_H_GUARD
