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
			//printf("<VarDecl> -> <IDENTIFIER> <LBK> <INTCON> <RBK>\n");
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
			//printf("<Statement> -> <IfStatement>\n");
		}
		| WhileStatement
		{ 
			//printf("<Statement> -> <WhileStatement>\n");
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
			int offset = getValue($1);
			issue_sw($3, GP, offset);
		}
                ;
				
IfStatement	: IF TestAndThen ELSE CompoundStatement
		{
			//printf("<IfStatement> -> <IF> <TestAndThen> <ELSE> <CompoundStatement>\n");
		}
		| IF TestAndThen
		{
			//printf("<IfStatement> -> <IF> <TestAndThen>\n");
		}
		;
		
				
TestAndThen	: Test CompoundStatement
		{
			//printf("<TestAndThen> -> <Test> <CompoundStatement>\n");
		}
		;
				
Test		: LPAREN Expr RPAREN
		{
			//printf("<Test> -> <LP> <Expr> <RP>\n");
		}
		;
	

WhileStatement  : WhileToken WhileExpr Statement
		{
			//printf("<WhileStatement> -> <WhileToken> <WhileExpr> <Statement>\n");
		}
                ;
                
WhileExpr	: LPAREN Expr RPAREN
		{
			//printf("<WhileExpr> -> <LP> <Expr> <RP>\n");
		}
		;
				
WhileToken	: WHILE
		{
			//printf("<WhileToken> -> <WHILE>\n");
		}
		;


IOStatement     : READ LPAREN Variable RPAREN SEMICOLON
		{
		  reg_idx_t reg = reg_alloc();
		  read_int(reg); // read value from stdin and store into reg
		  issue_sw(reg, GP, getValue($3)); // store reg's content at variable's location
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
			reg_idx_t reg    = reg_alloc();
			int       offset = getValue($1);
			issue_lw(reg, GP, offset);
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
			$$ = $1; // index in symtable
		}
                | IDENTIFIER LBRACKET Expr RBRACKET    
               	{
			//printf("<Variable> -> <IDENTIFIER> <LBK> <Expr> <RBK>\n");
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
	
	print_prolog();

        Cminus_parse();

	print_epilog();

	print_string_labels();
  
  	finalize();
  
  	return 0;
}

int getValue(int index)
{
  return (int)SymGetFieldByIndex(symtab, index, SYMTAB_VALUE_FIELD); 
}

int setValue(int index, int value)
{
  SymPutFieldByIndex(symtab, index, SYMTAB_VALUE_FIELD, (Generic)value); 
}
/******************END OF C ROUTINES**********************/
