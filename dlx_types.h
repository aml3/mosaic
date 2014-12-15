#ifndef DLX_TYPES_H
#define DLX_TYPES_H

// We need to predefine this, since it depends on node but node depends on it.
class header;

class node {
  public:
    node * left;
    node * right;
    node * up;
    node * down;
    header * col_head;
    bool removed;

    node() {
      left = this;
      right = this;
      up = this;
      down = this;
      col_head = nullptr;
      removed = false;
    }

};

class header : public node {
  public:
    int count;
    bool tile;

    header() {
      count = 0;
      col_head = this;
      removed = false;
      tile = false;
    }

    void insert(node * item);
};

#endif
