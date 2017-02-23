#ifndef MIPS_MGMT_H_GUARD
#define MIPS_MGMT_H_GUARD

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
extern int 		g_GP_NEXT_OFFSET;
extern int              g_STRING_INDEX;

void      print_prolog          ();
void      print_epilog          ();
void      print_string_labels   ();
reg_idx_t reg_alloc             ();
void      reg_free              (reg_idx_t   reg);
void      write_new_line        ();
void      read_int              (reg_idx_t   dst);
void      write_const_int       (int         value);
void      write_reg_value       (reg_idx_t   reg);
void      write_const_string    (reg_idx_t   reg);
void      issue_op              (const char* op,  reg_idx_t dst,  reg_idx_t src1, reg_idx_t src2);
void      issue_op_imm          (const char* op,  reg_idx_t dst,  reg_idx_t src,  int value);
void      issue_lw              (reg_idx_t   dst, reg_idx_t base,                 int offset);
void      issue_sw              (reg_idx_t   src, reg_idx_t base,                 int offset);
void      issue_li              (reg_idx_t   dst, int offset);
void      issue_la              (reg_idx_t   dst, const char* str_label);

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


#endif	// MIPS_MGMT_H_GUARD
