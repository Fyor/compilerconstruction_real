/**
 * @file
 *
 * Traversal: Print
 * UID      : PRT
 *
 *
 */
#include "stdio.h"

#include "ccn/ccn.h"
#include "ccngen/ast.h"

/**
 * @fn PRTprogram
 */
node_st *PRTprogram(node_st *node)
{
  TRAVchildren(node);
  return node;
}

/**
 * @fn PRTdecls
 */
node_st *PRTdecls(node_st *node)
{
  return node;
}

/**
 * @fn PRTexprs
 */
node_st *PRTexprs(node_st *node)
{
  return node;
}

/**
 * @fn PRTarrexpr
 */
node_st *PRTarrexpr(node_st *node)
{
  TRAVchildren(node);
  return node;
}

/**
 * @fn PRTids
 */
node_st *PRTids(node_st *node)
{
  return node;
}

/**
 * @fn PRTexprstmt
 */
node_st *PRTexprstmt(node_st *node)
{
  return node;
}

/**
 * @fn PRTreturn
 */
node_st *PRTreturn(node_st *node)
{
  return node;
}

/**
 * @fn PRTfuncall
 */
node_st *PRTfuncall(node_st *node)
{
  return node;
}

/**
 * @fn PRTcast
 */
node_st *PRTcast(node_st *node)
{
  return node;
}

/**
 * @fn PRTfundefs
 */
node_st *PRTfundefs(node_st *node)
{
  return node;
}

/**
 * @fn PRTfundef
 */
node_st *PRTfundef(node_st *node)
{
  return node;
}

/**
 * @fn PRTfunbody
 */
node_st *PRTfunbody(node_st *node)
{
  return node;
}

/**
 * @fn PRTifelse
 */
node_st *PRTifelse(node_st *node)
{
  return node;
}

/**
 * @fn PRTwhile
 */
node_st *PRTwhile(node_st *node)
{
  return node;
}

/**
 * @fn PRTdowhile
 */
node_st *PRTdowhile(node_st *node)
{
  return node;
}

/**
 * @fn PRTfor
 */
node_st *PRTfor(node_st *node)
{
  return node;
}

/**
 * @fn PRTglobdecl
 */
node_st *PRTglobdecl(node_st *node)
{
  return node;
}

/**
 * @fn PRTglobdef
 */
node_st *PRTglobdef(node_st *node)
{
  return node;
}

/**
 * @fn PRTparam
 */
node_st *PRTparam(node_st *node)
{
  return node;
}

/**
 * @fn PRTvardecl
 */
node_st *PRTvardecl(node_st *node)
{
  TRAVchildren(node);
  char *name = VARDECL_NAME(node);
  enum Type type = VARDECL_TYPE(node);

  printf("Name: %s, type: %d\n", name, type);
  return node;
}

/**
 * @fn PRTstmts
 */
node_st *PRTstmts(node_st *node)
{
  return node;
}

/**
 * @fn PRTassign
 */
node_st *PRTassign(node_st *node)
{
  return node;
}

/**
 * @fn PRTbinop
 */
node_st *PRTbinop(node_st *node)
{
  TRAVchildren(node);

  printf("%d: INSIDEBINOP\n", BINOP_OP(node));
  return node;
}

/**
 * @fn PRTmonop
 */
node_st *PRTmonop(node_st *node)
{
  TRAVchildren(node);
  printf("INSIDEnoNOP\n");
  return node;
}

/**
 * @fn PRTvarlet
 */
node_st *PRTvarlet(node_st *node)
{
  return node;
}

/**
 * @fn PRTvar
 */
node_st *PRTvar(node_st *node)
{
  return node;
}

/**
 * @fn PRTnum
 */
node_st *PRTnum(node_st *node)
{
  printf("numval = %d\n", NUM_VAL(node));
  return node;
}

/**
 * @fn PRTfloat
 */
node_st *PRTfloat(node_st *node)
{
  printf("floatval = %f\n", FLOAT_VAL(node));
  return node;
}

/**
 * @fn PRTbool
 */
node_st *PRTbool(node_st *node)
{
  printf("boolval = %d\n", (int)BOOL_VAL(node));
  return node;
}
