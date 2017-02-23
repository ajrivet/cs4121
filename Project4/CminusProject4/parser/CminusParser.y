/*******************************************************/
/*                     Cminus Parser                   */
/*                                                     */
/*******************************************************/

/*********************DEFINITIONS***********************/
%{
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <util/general.h>
#include <util/symtab.h>
#include <util/symtab_stack.h>
#include <util/dlink.h>
#include <util/string_utils.h>
#include "mips_mgmt.h"

#define SYMTABLE_SIZE 100
#define SYMTAB_VALUE_FIELD     "value"

/*********************EXTERNAL DECLARATIONS***********************/

EXTERN(void,Cminus_error,(const char*));

EXTERN(int,Cminus_lex,(void));

char *fileName;

SymTable symtab;

extern int Cminus_lineno;

extern FILE *Cminus_in;

long getValue(int);
int  setValue(int,long);

%}

%name-prefix="Cminus_"
%defines

%start Program

%token AND
%token ELSE
%token EXIT
%token FOR
%token IF 		
%token INTEGER 
%token NOT 		
%token OR 		
%token READ
%token WHILE
%token WRITE
%token LBRACE
%token RBRACE
%token LE
%token LT
%token GE
%token GT
%token EQ
%token NE
%token ASSIGN
%token COMMA
%token SEMICOLON
%token LBRACKET
%token RBRACKET
%token LPAREN
%token RPAREN
%token PLUS
%token TIMES
%token IDENTIFIER
%token DIVIDE
%token RETURN
%token STRING	
%token INTCON
%token MINUS

%left OR
%left AND
%left NOT
%left LT LE GT GE NE EQ
%left PLUS MINUS
%left TIMES DIVDE

/***********************PRODUCTIONS****************************/
%%
   Program		: Procedures 
		{
			//printf("<Program> -> <Procedures>\n");
		}
	  	| DeclList Procedures
		{
			//printf("<Program> -> <DeclList> <Procedures>\n");
		}
          ;

Procedures 	: ProcedureDecl Procedures
		{
			//printf("<Procedures> -> <ProcedureDecl> <Procedures>\n");
		}
	   	|
		{
			//printf("<Procedures> -> epsilon\n");
		}
	   	;

ProcedureDecl : ProcedureHead ProcedureBody
		{
			//printf("<ProcedureDecl> -> <ProcedureHead> <ProcedureBody>\n");
		}
              ;

ProcedureHead : FunctionDecl DeclList 
		{
			//printf("<ProcedureHead> -> <FunctionDecl> <DeclList>\n");
		}
	      | FunctionDecl
		{
			//printf("<ProcedureHead> -> <FunctionDecl>\n");
		}
              ;

FunctionDecl :  Type IDENTIFIER LPAREN RPAREN LBRACE 
		{
			//printf("<FunctionDecl> ->  <Type> <IDENTIFIER> <LP> <RP> <LBR>\n"); 
		}
	      	;

ProcedureBody : StatementList RBRACE
		{
			//printf("<ProcedureBody> -> <StatementList> <RBR>\n");
		}
	      ;


DeclList 	: Type IdentifierList  SEMICOLON 
		{
			//printf("<DeclList> -> <Type> <IdentifierList> <SC>\n");
		}		
	   	| DeclList Type IdentifierList SEMICOLON
	 	{
			//printf("<DeclList> -> <DeclList> <Type> <IdentifierList> <SC>\n");
	 	}
          	;


IdentifierList 	: VarDecl  
		{
			//printf("<IdentifierList> -> <VarDecl>\n");
		}
						
                | IdentifierList COMMA VarDecl
		{
			//printf("<IdentifierList> -> <IdentifierList> <CM> <VarDecl>\n");
		}
                ;

VarDecl 	: IDENTIFIER
		{ 
			setValue($1, g_GP_NEXT_OFFSET);
			g_GP_NEXT_OFFSET += 4; // next slot for a 4B value.
		}
		| IDENTIFIER LBRACKET INTCON RBRACKET
                {
			setValue($1, g_GP_NEXT_OFFSET);
			g_GP_NEXT_OFFSET += (4*$3); // next slot for a 4B value.
		}
		;

Type     	: INTEGER 
		{ 
			//printf("<Type> -> <INTEGER>\n");
		}
                ;

Statement 	: Assignment
		{ 
			//$$=$1;
			//printf("<Statement> -> <Assignment>\n");
		}
                | IfStatement
		{ 
                    // if-then/if-then-else was completely parsed, but needs to be printed
                    // placing the code here so it is written only once

                    // if there is an else-block we need to print its end-of-block label
                    print_label(IS_IN_ELSE? ELSE_LBL : IF_LBL);
                    if (IDX_TOP == 0) {   // if there is only 1 element left in the stack
                        elt_t* e = POP(); // stack is empty here
                        puts(e->buffer);  // print to file
                        elt_destroy(e);   // free memory
                    } else {
                        MERGE_LEVELS(2ul);
                    }
		}
		| WhileStatement
		{ 
                    issue_jmp(WHILE_START_LBL);
                    print_label(WHILE_END_LBL);
                    if (IDX_TOP == 0) {   // if there is only 1 element left in the stack
                        elt_t* e = POP(); // stack is empty here
                        puts(e->buffer);  // print to file
                        elt_destroy(e);   // free memory
                    } else {
                        MERGE_LEVELS(2ul);
                    }
		}
		| IOStatement 
		{ 
			//printf("<Statement> -> <IOStatement>\n");
		}
		| ReturnStatement
		{ 
			//printf("<Statement> -> <ReturnStatement>\n");
		}
		| ExitStatement	
		{ 
			//printf("<Statement> -> <ExitStatement>\n");
		}
		| CompoundStatement
		{ 
			//printf("<Statement> -> <CompoundStatement>\n");
		}
                ;

Assignment      : Variable ASSIGN Expr SEMICOLON
		{
			// $1 == reg index of target addr
			// $3 == reg index of value to store
			issue_sw($3, $1, 0);
			reg_free($3);
			reg_free($1);
		}
                ;
				
IfStatement	: IF TestAndThen ELSE CompoundStatement
		{
		}
		| IF TestAndThen
		{
		}
		;
		
				
TestAndThen	: Test CompoundStatement
		{
		}
		;
				
Test		: LPAREN Expr RPAREN
		{
                    // $2 == register containing result of test expression
                    PUSH(); // enter new ctrl flow context
                    IF_LBL = g_NXT_LBL_ID++;
                    // if condition result in $2 is false goto end of if-block
                    issue_beq($2, ZERO, IF_LBL);
                    reg_free($2);
		}
		;
	

WhileStatement  : WhileToken WhileExpr Statement
		{
		}
        ;
                
WhileExpr	: LPAREN Expr RPAREN
		{
                    // $2 == register containing result of test expression
                    // if condition result in $2 is false goto end of while-block
                    issue_beq($2, ZERO, WHILE_END_LBL);
                    reg_free($2);
		}
		;
				
WhileToken	: WHILE
		{
                    PUSH(); // enter new ctrl flow context
                    WHILE_START_LBL = g_NXT_LBL_ID++;
                    print_label(WHILE_START_LBL);
                    WHILE_END_LBL   = g_NXT_LBL_ID++;
		}
		;


IOStatement     : READ LPAREN Variable RPAREN SEMICOLON
		{
		  reg_idx_t reg = reg_alloc();
		  read_int(reg); // read value from stdin and store into reg
		  issue_sw(reg, $3, 0); // store reg's content at variable's location
		  reg_free(reg);
		}
                | WRITE LPAREN Expr RPAREN SEMICOLON
		{
			write_reg_value($3);
			write_new_line();
			reg_free($3);
		}
                | WRITE LPAREN StringConstant RPAREN SEMICOLON         
		{
			write_const_string($3);
			write_new_line();
			reg_free($3);
		}
                ;

ReturnStatement : RETURN Expr SEMICOLON
		{
			//printf("<ReturnStatement> -> <RETURN> <Expr> <SC>\n");
		}
                ;

ExitStatement 	: EXIT SEMICOLON
		{
			//printf("<ExitStatement> -> <EXIT> <SC>\n");
		}
		;

CompoundStatement : LBRACE StatementList RBRACE
		{
			//printf("<CompoundStatement> -> <LBR> <StatementList> <RBR>\n");
		}
                ;

StatementList   : Statement
		{		
			//printf("<StatementList> -> <Statement>\n");
		}
                | StatementList Statement
		{		
			//printf("<StatementList> -> <StatementList> <Statement>\n");
		}
                ;

Expr            : SimpleExpr
		{
			$$ = $1;
		}
                | Expr OR SimpleExpr 
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_OR(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | Expr AND SimpleExpr 
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_AND(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | NOT SimpleExpr 
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_XORI(reg, $2, 1);
			reg_free($2);
			$$ = reg;
		}
                ;

SimpleExpr	: AddExpr
		{
			$$ = $1;
		}
                | SimpleExpr EQ AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("seq", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | SimpleExpr NE AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("sne", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | SimpleExpr LE AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("sle", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | SimpleExpr LT AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("slt", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | SimpleExpr GE AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("sge", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                | SimpleExpr GT AddExpr
		{
			reg_idx_t reg = reg_alloc();
			issue_op("sgt", reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                ;

AddExpr		:  MulExpr            
		{
			$$ = $1;
		}
                |  AddExpr PLUS MulExpr
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_ADD(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                |  AddExpr MINUS MulExpr
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_SUB(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                ;

MulExpr		:  Factor
		{
			$$ = $1;
		}
                |  MulExpr TIMES Factor
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_MUL(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}
                |  MulExpr DIVIDE Factor
		{
			reg_idx_t reg = reg_alloc();
			ISSUE_DIV(reg, $1, $3);
			reg_free($1);
			reg_free($3);
			$$ = reg;
		}		
                ;
				
Factor          : Variable
		{ 
			reg_idx_t reg = reg_alloc();
			issue_lw(reg, $1, 0);
			reg_free($1);
			$$ = reg; 
		}
                | Constant
		{ 
			reg_idx_t reg = reg_alloc();
			issue_li(reg, $1);
			$$ = reg;
		}
                | IDENTIFIER LPAREN RPAREN
       		{	
			//printf("<Factor> -> <IDENTIFIER> <LP> <RP>\n");
		}
         	| LPAREN Expr RPAREN
		{
			$$ = $2;
		}
                ;  

Variable        : IDENTIFIER
		{
			// $1 == index of symbol in symtable
			reg_idx_t reg    = reg_alloc();
			long      offset = getValue($1);
			ISSUE_ADDI(reg, GP, offset);
			$$ = reg;
		}
                | IDENTIFIER LBRACKET Expr RBRACKET    
               	{
			// $1 == index of symbol in symtable
			// $3 == reg idx for result of expr
			reg_idx_t reg    = reg_alloc(),
				  r2	 = reg_alloc();
			// load offset and add sizeof(int) * idx value
			long      offset = getValue($1); // load base offset
			ISSUE_ADDI(reg, GP, offset);	 // base + offset
			issue_li(r2, 4);
			ISSUE_MUL($3, $3, r2);           // idx * sizeof(int)
			ISSUE_ADD($3, $3, reg);          // base + offset + idx * 4
			reg_free(reg);
			reg_free(r2);
			$$ = $3;
               	}
                ;			       

StringConstant 	: STRING
		{ 
			reg_idx_t reg   = reg_alloc();
			char*     label = SymGetFieldByIndex(symtab, $1, SYM_NAME_FIELD);
			issue_la(reg, label);
			$$ = reg;
		}
                ;

Constant        : INTCON
		{ 
			$$ = $1;
		}
                ;

%%


/********************C ROUTINES *********************************/

void Cminus_error(const char *s)
{
  fprintf(stderr,"%s: line %d: %s\n",fileName,Cminus_lineno,s);
}

int Cminus_wrap() {
	return 1;
}

static void initialize(char* inputFileName) {

	Cminus_in = fopen(inputFileName,"r");
        if (Cminus_in == NULL) {
          fprintf(stderr,"Error: Could not open file %s\n",inputFileName);
          exit(-1);
        }

	char* dotChar = rindex(inputFileName,'.');
	int endIndex = strlen(inputFileName) - strlen(dotChar);
	char *outputFileName = nssave(2,substr(inputFileName,0,endIndex),".s");
	stdout = freopen(outputFileName,"w",stdout);
        if (stdout == NULL) {
          fprintf(stderr,"Error: Could not open file %s\n",outputFileName);
          exit(-1);
        }

	 symtab = SymInit(SYMTABLE_SIZE);
	 SymInitField(symtab,SYMTAB_VALUE_FIELD,(Generic)-1,NULL);
}

static void finalize() {

    SymKillField(symtab,SYMTAB_VALUE_FIELD);
    SymKill(symtab);
    fclose(Cminus_in);
    fclose(stdout);

}

int main(int argc, char** argv)

{	
	fileName = argv[1];
	initialize(fileName);
    stack_init(&g_STACK);
	
	print_prolog();

        Cminus_parse();

	print_epilog();

	print_string_labels();
  
    stack_destroy_content(&g_STACK); // clear/clean the stack from remaining levels

  	finalize();
  
  	return 0;
}

long getValue(int index)
{
  return (long)SymGetFieldByIndex(symtab, index, SYMTAB_VALUE_FIELD); 
}

int setValue(int index, long value)
{
  SymPutFieldByIndex(symtab, index, SYMTAB_VALUE_FIELD, (Generic)value); 
}
/******************END OF C ROUTINES**********************/
