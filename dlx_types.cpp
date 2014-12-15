#include "dlx_types.h"

void header::insert(node * item) {
  item->col_head = this;
  item->down = this;
  item->up = this->up;
  this->up->down = item;
  this->up = item;
  ++this->count;
}
