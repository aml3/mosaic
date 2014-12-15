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
    bool used;

    node() {
      left = this;
      right = this;
      up = this;
      down = this;
      col_head = nullptr;
      used = false;
    }

};

class header : public node {
  public:
    int count;

    header() {
      count = 0;
      col_head = this;
      used = false;
    }

    void insert(node * item);
};

#endif
