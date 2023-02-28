%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "ccngen/ast.h"
#include "ccngen/enum.h"
#include "parser.h"
#include "palm/str.h"
#include "global/globals.h"
#include "palm/ctinfo.h"


#define FILTER(token) \
  global.col += yyleng;  \
  return( token);

#define LINEBUF_SIZE 256
#define YY_NO_UNPUT
#define YY_NO_INPUT

static inline void token_action();

int yycolumn = 1;
#define YY_USER_ACTION token_action();


%}

%p 6000 /* set positions to 6000 */
%e 2000 /* set nodes to 1100 */
%option noyywrap
%option nounput
%option yylineno

%x IN_COMMENT

%%
<INITIAL>{
"/*"                       { BEGIN(IN_COMMENT); }


"("                        { FILTER( BRACKET_L); }
")"                        { FILTER( BRACKET_R); }
"{"                        { FILTER( CBRACKET_L); }
"}"                        { FILTER( CBRACKET_R); }
"["                        { FILTER( SBRACKET_L); }
"]"                        { FILTER( SBRACKET_R); }
","                        { FILTER( COMMA); }
";"                        { FILTER( SEMICOLON); }

"-"                        { FILTER( MINUS); }
"+"                        { FILTER( PLUS);  }
"*"                        { FILTER( STAR);  } 
"/"                        { FILTER( SLASH);  } 
"%"                        { FILTER( PERCENT);  } 

"<="                       { FILTER( LE);    }
"<"                        { FILTER( LT);    } 
">="                       { FILTER( GE);    }
">"                        { FILTER( GT);    }
"=="                       { FILTER( EQ);    }
"!="                       { FILTER( NE);    }
"&&"                       { FILTER( AND);    }
"||"                       { FILTER( OR);    }

"="                        { FILTER( LET);    }

"true"                     { yylval.cbool = true;
                             FILTER( TRUEVAL); }

"false"                    { yylval.cbool = false;
                             FILTER( FALSEVAL); }

[A-Za-z][A-Za-z0-9_]*      { yylval.id = STRcpy(yytext);
                             FILTER( ID);
                           }

0|([-]?[1-9][0-9]*)        { yylval.cint=atoi(yytext);
                             FILTER( NUM);
                           }



[ \t]                      { global.col += yyleng; }

"do"                       { FILTER( DO); }

"while"                    { FILTER(WHILE); }

"if"                       { FILTER(IF); }

"else"                     { FILTER(ELSE); }

"for"                      { FILTER(FOR); }

"int"                      { FILTER(INT); }

"float"                    { FILTER(FLOAT); }

"bool"                     { FILTER(BOOL); }

"extern"                   { FILTER(EXTERN); }

"export"                   { FILTER(EXPORT); }

"return"                   { FILTER(RETURN); }

"void"                     { FILTER(VOID); }

\n.*                       { 
                             yycolumn = 1;
                             global.line += 1;
                             global.col = 0;
                             yyless(1);
                           }

}
<IN_COMMENT>{
            "*/"      { BEGIN(INITIAL); FILTER(COMMENT); }
            [^*\n]+   { global.col += yyleng; }
            "*"       { global.col += yyleng; }
            \n        { yylineno++; }
}
%%

static inline void token_action() {
    yylloc.first_line = yylloc.last_line = yylineno;
    yylloc.first_column = yycolumn;
    yylloc.last_column = yycolumn + yyleng - 1;
    yycolumn += yyleng;
}
