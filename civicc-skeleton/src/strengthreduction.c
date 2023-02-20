/**
 * @file
 *
 * Traversal: StrengthReduction
 * UID      : SR
 *
 * Changes multiplications of the form k * 3 to k + k + k.
 * This happens up to a certain factor, which can be set with the --sr_maxfactor parameter.
 */

#include <stdio.h>

#include "ccn/ccn.h"
#include "ccngen/ast.h"
#include "palm/str.h"
#include "global/globals.h"

/**
 * Function to recursively create an AST tree of Binops of form k + k + ... + k of length additionCount.
 */
static
node_st *createAdditionBinop(node_st *var_node, int additionCount) {
    if (additionCount == 1)
        return ASTvar(STRcpy(VAR_NAME(var_node)));
    else if (additionCount > 1) {
        node_st *new_var = ASTvar(STRcpy(VAR_NAME(var_node)));
        return ASTbinop(new_var, createAdditionBinop(var_node, additionCount - 1), BO_add);
    }
    return NULL;
}


/**
 * @fn SRbinop
 */
node_st *SRbinop(node_st *node) {
    TRAVchildren(node);
    if (BINOP_TYPE(node) == BO_mul) {
        node_st *var_node;
        node_st *new_node = NULL;
        int num;
        int max_additions = global.strength_reduction_max_factor;

        if (NODE_TYPE(BINOP_RIGHT(node)) == NT_VAR && NODE_TYPE(BINOP_LEFT(node)) == NT_NUM) {
            var_node = BINOP_RIGHT(node);
            num = NUM_VAL(BINOP_LEFT(node));
        } else if (NODE_TYPE(BINOP_LEFT(node)) == NT_VAR && NODE_TYPE(BINOP_RIGHT(node)) == NT_NUM) {
            var_node = BINOP_LEFT(node);
            num = NUM_VAL(BINOP_RIGHT(node));
        } else return node;

        if (num >= 1 && num <= max_additions) {
            new_node = createAdditionBinop(var_node, num);
            CCNfree(node);
            return new_node;
        }
    }
    return node;
}

