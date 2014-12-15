#ifndef DLX_TYPES_H
#define DLX_TYPES_H

#include <iostream>
#include <vector>
#include <stack>
#include <tuple>
using namespace std;
typedef vector<vector<int > > tile;
typedef vector<int> row;

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
    string name;

    header() {
      name = "";
      count = 0;
      col_head = this;
      tile = false;
    }

    void insert(node * item);
};

class matrix {
  public:
    stack<tuple<int, int, int, int> > placements;
    int orientation;
    int** grid;
    int dim_x;
    int dim_y;
    int space;

    matrix() {
      this->grid = nullptr;
      this->orientation = 0;
      this->dim_x = 0;
      this->dim_y = 0;
      this->space = 0;
    }
    void reflect(int);
    void rotate(int);
    void unreflect(int);
    void unrotate(int);
    void reflect();
    void rotate();
    void unreflect();
    void unrotate();
    void addPiece(int idx, tile &t, int tx, int ty, int x, int y);
    void removePiece(int idx, tile &t, int tx, int ty, int x, int y);
};

#endif
