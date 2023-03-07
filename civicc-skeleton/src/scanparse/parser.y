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
 enum MonOpEnum      cmonop;
 node_st             *node;
}

%locations

%token BRACKET_L BRACKET_R SBRACKET_L SBRACKET_R CBRACKET_L CBRACKET_R COMMA SEMICOLON
%token NOT
%token TRUEVAL FALSEVAL
%token INT FLOAT VOID BOOL EXTERN EXPORT DO WHILE IF FOR RETURN


%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left MINUS PLUS
%left STAR SLASH PERCENT

%right LET

%right NOT UMINUS CAST

%precedence THEN
%precedence ELSE


%token <cint> NUM
%token <cflt> FLT
%token <cbool> BL
%token <id> ID

%type <node> vardecl expr exprs constant funbody stmts stmt varlet block fundef fundefs param decls decl
%type <ctype> type

%start program

%%

program: decls {
    parseresult = ASTprogram($1);
};

decls: decls decl
  {
    $$ = ASTdecls($2, $1);
  }
  | decl
  {
    $$ = ASTdecls($1, NULL);
  };


decl: fundef
  {
    $$ = $1;
  };

// arguments: vardecls, local_fundefs, stmts
funbody: vardecl fundefs stmts
  {
    $$ = ASTfunbody($1, $2, $3);
  }
  | vardecl fundefs
  {
    $$ = ASTfunbody($1, $2, NULL);
  }
  | vardecl stmts
  {
    $$ = ASTfunbody($1, NULL, $2);
  }
  | fundefs stmts
  {
    $$ = ASTfunbody(NULL, $1, $2);
  }
  | vardecl
  {
    $$ = ASTfunbody($1, NULL, NULL);
  }
  | fundefs
  {
    $$ = ASTfunbody(NULL, $1, NULL);
  }
  | stmts
  {
    $$ = ASTfunbody(NULL, NULL, $1);
  }
  | %empty
  {
    $$ = ASTfunbody(NULL, NULL, NULL);
  };

fundefs: fundefs fundef
  {
    $$ = ASTfundefs($2, $1);
  }
  | fundef
  {
    $$ = ASTfundefs($1, NULL);
  };

//args: body, params, type, name, export
fundef: EXPORT type[ret_type] ID[name] BRACKET_L param[par] BRACKET_R CBRACKET_L funbody[body] CBRACKET_R
  {
    $$ = ASTfundef($body, $par, $ret_type, $name, true);
  }
  | type[ret_type] ID[name] BRACKET_L param[par] BRACKET_R CBRACKET_L funbody[body] CBRACKET_R
  {
    $$ = ASTfundef($body, $par, $ret_type, $name, false);
  }
  |
  EXPORT type[ret_type] ID[name] BRACKET_L BRACKET_R CBRACKET_L funbody[body] CBRACKET_R
  {
    $$ = ASTfundef($body, NULL, $ret_type, $name, true);
  }
  | type[ret_type] ID[name] BRACKET_L BRACKET_R CBRACKET_L funbody[body] CBRACKET_R
  {
    $$ = ASTfundef($body, NULL, $ret_type, $name, false);
  }
  ;

//args: dims, next, name, type
param: type ID
  {
    $$ = ASTparam(NULL, NULL, $2, $1 );
  }
  | type ID COMMA param
  {
    $$ = ASTparam(NULL, $4, $2, $1);
  }


// arguments: stmt, next
stmts: stmts stmt
    {
      $$ = ASTstmts($2, $1);
    }
    | stmt
    {
      $$ = ASTstmts($1, NULL);
    };

stmt: varlet LET expr SEMICOLON
    {
      $$ = ASTassign($1, $3);
    }
    | WHILE BRACKET_L expr BRACKET_R block {
      $$ = ASTwhile($3, $5);
    }
    | DO block WHILE BRACKET_L expr BRACKET_R SEMICOLON {
      $$ = ASTdowhile($5, $2);
    }
    | IF BRACKET_L expr BRACKET_R block %prec THEN {
      $$ = ASTifelse($3, $5, NULL);
    } 
    | IF BRACKET_L expr BRACKET_R block ELSE block {
      $$ = ASTifelse($3, $5, $7);
    }
    | RETURN SEMICOLON {
      $$ = ASTreturn(NULL);
    }
    | RETURN expr SEMICOLON {
      $$ = ASTreturn($2);
    }
    | ID BRACKET_L exprs BRACKET_R SEMICOLON {
      $$ = ASTfuncall($3, $1);
    }
    | ID BRACKET_L BRACKET_R SEMICOLON {
      $$ = ASTfuncall(NULL, $1);
    }
    | FOR BRACKET_L INT ID LET expr[start] COMMA expr[stop] BRACKET_R block[stmtblock]
    {
      $$ = ASTfor($start, $stop, NULL, $stmtblock);
    }
    | FOR BRACKET_L INT ID LET expr[start] COMMA expr[stop] COMMA expr[step] BRACKET_R block[stmtblock]
    {
      $$ = ASTfor($start, $stop, NULL, $stmtblock);
    }
    ;

// arguments: indices, name
varlet: ID
    {
      $$ = ASTvarlet(NULL, $1);
    };


block: CBRACKET_L CBRACKET_R
    {
      $$ = NULL;
    }
    | CBRACKET_L stmts CBRACKET_R
    {
      $$ = $2;
    }
    | stmt
    {
      $$ = $1;
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
    | type ID SEMICOLON
    {
        $$ = ASTvardecl(NULL, NULL, NULL, $1, $2);
    }
    | type ID LET expr SEMICOLON
    {
        $$ = ASTvardecl(NULL, $4, NULL, $1, $2);
    };

// arguments: expr, next
exprs: exprs COMMA expr {
        $$ = ASTexprs($3, $1);
    }
    | expr {
        $$ = ASTexprs($1, NULL);
    }

expr: BRACKET_L expr BRACKET_R
      {
        $$ = $2;
      }
    | expr[left] PLUS expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_add);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] MINUS expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_sub);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] STAR expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_mul);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] SLASH expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_div);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] PERCENT expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_mod);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] LE expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_le);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] LT expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_lt);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] GE expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_ge);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] GT expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_gt);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] EQ expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_eq);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] NE expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_eq);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] OR expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_or);
        AddLocToNode($$, &@left, &@right);
      }
    | expr[left] AND expr[right]
      {
        $$ = ASTbinop( $left, $right, BO_and);
        AddLocToNode($$, &@left, &@right);
      }

    | MINUS expr %prec UMINUS
      {
        $$ = ASTmonop($2, MO_neg);
        // Moet hier AddLocToNode?
      }
    | NOT expr
      {
        $$ = ASTmonop($2, MO_not);
        // Moet hier AddLocToNode?
      }
    | constant
      {
        $$ = $1;
      }
    | BRACKET_L type BRACKET_R expr %prec CAST {
        $$ = ASTcast($4, $2);
    }
    | ID {
      $$ = ASTvar($1);
    }
    ;

constant: FLT
          {
            $$ = ASTfloat($1);
          }
        | NUM
          {
            $$ = ASTnum($1);
          }
        | TRUEVAL
          {
            $$ = ASTbool(true);
          }
        | FALSEVAL
          {
            $$ = ASTbool(false);
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
