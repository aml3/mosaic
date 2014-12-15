#include "dlx_types.h"

void header::add(node * item) {
  item->col_head = this;
  item->down = this;
  item->up = this->up;
  this->up->down = item;
  ++count;
}
