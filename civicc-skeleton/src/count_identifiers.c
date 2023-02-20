/**
 * @file
 *
 * Traversal: CountIdentifiers
 * UID      : CI
 *
 *
 */

#include <stdio.h>

#include "ccn/ccn.h"
#include "ccngen/ast.h"
#include "palm/hash_table.h"
#include "palm/memory.h"

void CIinit() {
    DATA_CI_GET()->id_table = HTnew_String(8);
}
void CIfini() {
    HTdelete(DATA_CI_GET()->id_table);
}

static
void *print_hashtable(void *key, void *value) {
    printf("%s: %d occurrence(s)\n", (char *) key, *((int *) value));
    return value;
}

static
void *free_hashtable_values(void *key, void *value) {
    key = key;  // Get rid of compiler warning
    MEMfree((int *) value);
    return NULL;
}

/**
 * @fn CImodule
 */
node_st *CImodule(node_st *node)
{
    TRAVchildren(node);

    htable_st *ht = DATA_CI_GET()->id_table;
    HTmapWithKey(ht, &print_hashtable);
    HTmapWithKey(ht, &free_hashtable_values);

    return node;
}

static
void add_to_hashtable(char *varname) {
    htable_st *ht = DATA_CI_GET()->id_table;

    int *current_count = (int *) HTlookup(ht, varname);

    if (current_count) {
        (*current_count)++;
    } else {
        int *new_counter = MEMmalloc(sizeof(int));
        *new_counter = 1;
        HTinsert(ht, varname, new_counter);
    }
}

/**
 * @fn CIvarlet
 */
node_st *CIvarlet(node_st *node)
{
    add_to_hashtable(VARLET_NAME(node));
    return node;
}

/**
 * @fn CIvar
 */
node_st *CIvar(node_st *node)
{
    add_to_hashtable(VAR_NAME(node));
    return node;
}

