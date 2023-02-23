%{


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "palm/memory.h"
#include "palm/ctinfo.h"
#include "palm/dbug.h"
#include "palm/str.h"
#include "ccngen/ast.h"
#include "ccngen/enum.h"
#include "global/globals.h"

static node_st *parseresult = NULL;
extern int yylex();
static int yyerror( char *errname);
extern FILE *yyin;
void AddLocToNode(node_st *node, void *begin_loc, void *end_loc);


%}

%union {
 char               *id;
 int                 cint;
 float               cflt;
 bool                cbool;
 enum BinOpEnum      cbinop;
 enum Type           ctype;
 node_st             *node;
}

%locations

%token BRACKET_L BRACKET_R SBRACKET_L SBRACKET_R CBRACKET_L CBRACKET_R COMMA SEMICOLON
%token MINUS PLUS STAR SLASH PERCENT LE LT GE GT EQ NE OR AND
%token TRUEVAL FALSEVAL LET
%token INT FLOAT VOID BOOL EXTERN EXPORT DO WHILE IF ELSE FOR RETURN


%token <cint> NUM
%token <cflt> FLT
%token <cbool> BL
%token <id> ID

%type <node> vardecl expr constant
%type <ctype> type

%start program

%%

program: vardecl {
    parseresult = ASTprogram($1);
};

// arguments: next, init, dims, type, name
vardecl: vardecl type ID SEMICOLON
    {
        $$ = ASTvardecl($1, NULL, NULL, $2, $3);
    }
    |  vardecl type ID LET expr SEMICOLON
    {
        $$ = ASTvardecl($1, $5, NULL, $2, $3);
    }
    | type ID SEMICOLON {
        $$ = ASTvardecl(NULL, NULL, NULL, $1, $2);
    }
    | type ID LET expr SEMICOLON
    {
        $$ = ASTvardecl(NULL, $4, NULL, $1, $2);
    };

expr: constant
      {
        $$ = $1;
      };

constant: FLT
          {
            $$ = ASTfloat($1);
          }
        | NUM
          {
            $$ = ASTnum($1);
          }
        | BL
          {
            $$ = ASTbool($1);
          };




type: INT { $$ = CT_int; }
    | FLOAT { $$ = CT_float; }
    | BOOL { $$ = CT_bool; }
    | VOID { $$ = CT_void; };

%%

void AddLocToNode(node_st *node, void *begin_loc, void *end_loc)
{
    // Needed because YYLTYPE unpacks later than top-level decl.
    YYLTYPE *loc_b = (YYLTYPE*)begin_loc;
    YYLTYPE *loc_e = (YYLTYPE*)end_loc;
    NODE_BLINE(node) = loc_b->first_line;
    NODE_BCOL(node) = loc_b->first_column;
    NODE_ELINE(node) = loc_e->last_line;
    NODE_ECOL(node) = loc_e->last_column;
}

static int yyerror( char *error)
{
  CTI(CTI_ERROR, true, "line %d, col %d\nError parsing source code: %s\n",
            global.line, global.col, error);
  CTIabortOnError();
  return( 0);
}

node_st *SPdoScanParse(node_st *root)
{
    DBUG_ASSERT(root == NULL, "Started parsing with existing syntax tree.");
    yyin = fopen(global.input_file, "r");
    if (yyin == NULL) {
        CTI(CTI_ERROR, true, "Cannot open file '%s'.", global.input_file);
        CTIabortOnError();
    }
    yyparse();
    return parseresult;
}
