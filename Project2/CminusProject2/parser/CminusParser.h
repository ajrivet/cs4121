/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     AND = 258,
     ELSE = 259,
     EXIT = 260,
     FLOAT = 261,
     FOR = 262,
     IF = 263,
     INTEGER = 264,
     NOT = 265,
     OR = 266,
     READ = 267,
     WHILE = 268,
     WRITE = 269,
     LBRACE = 270,
     RBRACE = 271,
     LE = 272,
     LT = 273,
     GE = 274,
     GT = 275,
     EQ = 276,
     NE = 277,
     ASSIGN = 278,
     COMMA = 279,
     SEMICOLON = 280,
     LBRACKET = 281,
     RBRACKET = 282,
     LPAREN = 283,
     RPAREN = 284,
     PLUS = 285,
     TIMES = 286,
     IDENTIFIER = 287,
     DIVIDE = 288,
     RETURN = 289,
     STRING = 290,
     INTCON = 291,
     FLOATCON = 292,
     MINUS = 293,
     DIVDE = 294
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 96 "CminusParser.y"

	char*	name;
	int     symIndex;
	DList	idList;
	int 	offset;



/* Line 1676 of yacc.c  */
#line 100 "CminusParser.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE Cminus_lval;


