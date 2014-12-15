#ifndef DLX_H
#define DLX_H

#include "dlx_types.h"
#include <vector>
#include <utility>

using namespace std;

pair<header *, vector<header *>> initialize(int num_cols);
header * find_least_full(header * root);
void remove_col(header * col_head);
void replace_col(header * col_head);
void count_sols(header * root, int * counter);

#endif
