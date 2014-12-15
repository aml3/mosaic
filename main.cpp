#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>
#include <tuple>
#include <algorithm>
#include <sstream>

using namespace std;

vector<int> try_placement(int idx, int x, int y, int r, int rr);
void brute_force(int&,int,matrix&);
bool valid_placement(matrix&,int,int,int);
typedef vector<vector<int > > tile;

int main(void) {
  matrix b;

  b.grid = new int*[board.size()];
  b.dim_x = board_x;
  b.dim_y = board_y;
  for (int i = 0; i < board.size(); i++) {
    b.grid[i] = new int[board[i].size()];
    for (int j = 0; j < board[i].size(); j++) {
      b.grid[i][j] = board[i][j];
      if (board[i][j] == 1) {
        b.space++;
      }
    }
  }
  
  int counter = 0;
  cout << "space=" << b.space << endl;
  brute_force(counter, 0, b);

  cout << "counter=" << counter << endl;

  return 0;
}

void brute_force(int &counter, int idx, matrix &b) {
  if (b.space == 0) {
    counter++;
    return;
  }
  for(int i = idx; i < num_pieces; ++i) {
    for(int y = 0; y < board_y; ++y) {
      for(int x = 0; x < board_x; ++x) {
        for (int rotate = 0; rotate < 4; ++rotate) {
          b.rotate(rotate);
          for (int reflect = 0; reflect < 2; ++reflect) {
            b.reflect(reflect);
            if (valid_placement(b, i, x, y)) {
              b.addPiece(i, pieces[i], piecedims_x[i], piecedims_y[i], x, y);
              brute_force(counter, i+1, b);
              b.removePiece(i, pieces[i], piecedims_x[i], piecedims_y[i], x, y);
            }
            b.reflect(reflect);
          }
          b.rotate(4-rotate);
        }
      }
    }
  }
}

bool valid_placement(matrix &b, int idx,int x,int y) {
  tile orig_tile = pieces[idx];
  int dim_x = piecedims_x[idx];
  int dim_y = piecedims_y[idx];

  for (int i = 0; i < dim_y; ++i) {
    for (int j = 0; j < dim_x; ++j) {
      int board_i = i + y;
      int board_j = j + x;
      /* Fell off board. */
      if (board_i >= b.dim_y || board_j >= b.dim_x) {
        return false;
      }

      /* Mismatch. */
      if (b.grid[board_i][board_j] == 1
          && orig_tile[i][j] == 1) {
        return false;
      }
    }
  }

  return true;
}

int ** make_matrix(int dim_x, int dim_y) {
  int** matrix = new int*[dim_y];
  for (int i = 0; i < dim_y; ++i) {
    matrix[i] = new int[dim_x];
    for (int j = 0; j < dim_x; ++j) {
      matrix[i][j] = 0;
    }
  }
  return matrix;
}

int ** get_tile(int idx) {
  tile orig_tile = pieces[idx];
  int dim_x = piecedims_x[idx];
  int dim_y = piecedims_y[idx];

  int ** tile = make_matrix(dim_x, dim_y);
  for (int i = 0; i < dim_y; ++i) {
    for (int j = 0; j < dim_x; ++j) {
      tile[i][j] = orig_tile[i][j];
    }
  }
  return tile;
}

void cleanup(int ** tile, int dim_x, int dim_y) {
  for (int i = 0; i < dim_y; ++i) {
      delete [] tile[i];
  }
  delete [] tile;
}

/* Reflect across the x-axis. */
int ** reflect(int ** tile, int dim_x, int dim_y) {
  int ** reflected = make_matrix(dim_x, dim_y);
  for (int i = 0; i < dim_y; ++i) {
    for (int j = 0; j < dim_x; ++j) {
      reflected[dim_y - 1 - i][j] = tile[i][j];
    }
  }
  cleanup(tile, dim_x, dim_y);
  return reflected;
}

int ** rotate(int ** tile, int dim_x, int dim_y) {
  int ** rotated = make_matrix(dim_y, dim_x);
  for (int i = 0; i < dim_y; ++i) {
    for (int j = 0; j < dim_x; ++j) {
      rotated[j][dim_y - 1 - i] = tile[i][j];
    }
  }
  cleanup(tile, dim_x, dim_y);
  return rotated;
}

tuple<int **,tuple<int, int> > transform_tile(int idx, int _rotate, int _reflect) {
  int ** tile = get_tile(idx);
  int dim_x = piecedims_x[idx];
  int dim_y = piecedims_y[idx];
  if (_reflect == 1) {
    tile = reflect(tile, dim_x, dim_y);
  }

  for (int r = 0; r < _rotate; r++) {
    tile = rotate(tile, dim_x, dim_y);
    int temp = dim_x;
    dim_x = dim_y;
    dim_y = temp;
  }

  tuple<int, int> dims = make_tuple(dim_x, dim_y);

  return make_tuple(tile, dims);
}

vector<int> try_placement(int idx, int x, int y, int rotate, int reflect) {
  // Try placing tile idx at (x, y)
  // If it's valid, return a vector of the parts of the board covered
  // If it isn't valid, return an empty vector
  auto tuple = transform_tile(idx, rotate, reflect);
  int ** tile = get<0>(tuple);
  auto dims = get<1>(tuple);
  int dim_x = get<0>(dims);
  int dim_y = get<1>(dims);

  vector<int> indices;
  for (int i = 0; i < dim_y; ++i) {
    for (int j = 0; j < dim_x; ++j) {
      int board_i = i + y;
      int board_j = j + x;
      /* Fell off board. */
      if (board_i >= board_y || board_j >= board_x) {
        return vector<int>();
      }

      /* Mismatch. */
      if (board[board_i][board_j] != tile[i][j]) {
        return vector<int>();
      }

      /* Otherwise, we add the index. */
      indices.push_back(num_pieces + board_i + board_j * board_x);
    }
  }

  cleanup(tile, dim_x, dim_y);
  sort(indices.begin(), indices.end());
  return indices;
}
