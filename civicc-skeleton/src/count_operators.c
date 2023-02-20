/**
 * @file
 *
 * Traversal: CountOperators
 * UID      : CO
 *
 *
 */

#include <stdio.h>

#include "ccn/ccn.h"
#include "ccngen/ast.h"

void COinit() { return; }
void COfini() { return; }

/**
 * @fn COroot
 */
node_st *COmodule(node_st *node)
{
    TRAVchildren(node);
    struct data_co *data = DATA_CO_GET();
    MODULE_SUMADD(node) = data->sumAdd;
    MODULE_SUMSUB(node) = data->sumSub;
    MODULE_SUMMUL(node) = data->sumMul;
    MODULE_SUMDIV(node) = data->sumDiv;
    MODULE_SUMMOD(node) = data->sumMod;
    return node;
}

/**
 * @fn CObinop
 */
node_st *CObinop(node_st *node)
{
    TRAVchildren(node);
    struct data_co *data = DATA_CO_GET();
    switch (BINOP_TYPE(node)) {
    case BO_add:
        data->sumAdd++;
        break;

    case BO_sub:
        data->sumSub++;
        break;

    case BO_mul:
        data->sumMul++;
        break;

    case BO_div:
        data->sumDiv++;
        break;

    case BO_mod:
        data->sumMod++;
        break;

    default:
        break;
    }
    return node;
}

