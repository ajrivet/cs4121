WS	[ \t]

%{

/* This scanner approximates the Void specification.
 *
 * Major differences:
 *
 *  (1) the printed spec is wrong in about sixteen ways in its definition
 *	of numeric constants.  The scanner recognizes a fairly broad class
 * 	of things as constants - it allows both 0 and 1.0 as constants, where
 *	the document would not.
 *
 *      Feel free to accept the things that the scanner accepts as constants.
 *	The bug is in the original spec document.
 *
 *	Note: the scanner classifies all kinds of constants as "constant".
 *	It does not make a distinction between character, integer, and floating
 *	point constants.  I think of that distinction as something to look for
 *	in the type checker lab, not something that the grammar should enforce.
 *
 *
 * To hook this thing up to your parser, you will need to take the include
 * file of grammar terminals and relate them to the constants defined below.
 * You can either edit the flex spec or edit the constant defintions.  (Of
 * course, you should do that on your own copy!)  
 *
 */


#include <stdio.h>
#include <util/symtab.h>
#include <util/symtab_stack.h>
#include <util/string_utils.h>
#include <util/dlink.h>
#include "CminusParser.h"
#include "mips_mgmt.h"

long getValue(int);
int setValue(int, long);
extern SymTable symtab;
%}

%option bison-bridge
%option prefix="Cminus_"

%%

int		{ return INTEGER;}
while		{ return WHILE;  }
else		{ 
		    IS_IN_ELSE = true;            // needed when printing "tail code" of IfStatement
		    ELSE_LBL   = g_NXT_LBL_ID++;  // label for end of else-block
		    issue_jmp(ELSE_LBL);          // goto end of else-block
		    print_label(IF_LBL);          // print end of if-block
                    return ELSE; 
                }
exit				{ return EXIT; }
if				{ return IF; }
read				{ return READ; }
write				{ return WRITE; }
return				{ return RETURN; }

\!				{ return NOT;}
"||"		    		{ return OR;}
\&&				{ return AND;}
\<=				{ return LE; }
\<				{ return LT; }
\>=				{ return GE; }
\>				{ return GT; }
\==				{ return EQ; }
\!=				{ return NE; }
\=				{ return ASSIGN; }
\;				{ return SEMICOLON; }
\{			    	{ return LBRACE; }
"}"			    	{ return RBRACE; }
\[				{ return LBRACKET; }
\]				{ return RBRACKET; }
\(				{ return LPAREN; }
\)				{ return RPAREN; }
\+				{ return PLUS; }
\-          			{ return MINUS; }
\*				{ return TIMES; }
\/				{ return DIVIDE;}
","				{ return COMMA;}
\"[^\"]*\"			{ 
				  char str[10];
				  sprintf(str, "__str%d", g_STRING_INDEX++);
				  Cminus_lval = SymIndex(symtab, str);
				  setValue(Cminus_lval, (long)substr(Cminus_text, 1, Cminus_leng-2));
				//Cminus_lval = SymIndex(symtab, substr(Cminus_text, 1, Cminus_leng-2));
                                  return STRING; }
[a-zA-Z]([a-zA-Z]|[0-9])*	{ Cminus_lval = SymIndex(symtab, ssave(Cminus_text)); 
                                  return IDENTIFIER; }
[0-9]+				{ Cminus_lval = atoi(Cminus_text); return INTCON; }
{WS}				{ ; }
"\n"				{ Cminus_lineno++;}
.				{
					fprintf(stderr, "Scanner: lexical error '%s'.\n", Cminus_text); 
				}
%%
