#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>
#include <tuple>
#include <algorithm>
#include <sstream>
#include <cassert>

using namespace std;

void brute_force(int&,int,matrix&);
bool valid_placement(matrix&,int,int,int);
typedef vector<vector<int > > tile;

void print_matrix(matrix &b) {
  for (int i = 0; i < b.dim_y; i++) {
    for (int j = 0; j < b.dim_x; j++) {
      cout << b.grid[i][j] << " ";
    }
    cout << endl;
  }
  cout << endl;
}

int main(void) {
  matrix b;

  b.grid = new int*[board.size()];
  b.dim_x = board_x;
  b.dim_y = board_y;

  for (int i = 0; i < board.size(); i++) {
    b.grid[i] = new int[board[i].size()];
    for (int j = 0; j < board[i].size(); j++) {
      if (board[i][j] != 0) {
        b.grid[i][j] = 0;
        b.space++;
      } else {
        b.grid[i][j] = 1;
      }
    }
  }

  b.temp = new int*[b.dim_y];
  for (int i = 0; i < b.dim_y; i++) {
    b.temp[i] = new int[b.dim_x];
  }
  
  int counter = 0;
  cout << "space=" << b.space << endl;
  brute_force(counter, 0, b);

  cout << "counter=" << counter << endl;

  return 0;
}

int progress = 0;
void brute_force(int &counter, int idx, matrix &b) {
  int aa = b.orientation.first;
  int bb = b.orientation.second;
  cout << idx << endl;
  //print_matrix(b);
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
            progress++;
            if (progress %50000 == 0) cout << progress << ": " << b.space << endl;
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
  assert(aa = b.orientation.first);
  assert(bb = b.orientation.second);
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

      /* Mismatches. */
      if (b.grid[board_i][board_j] != 0
          && orig_tile[i][j] != 0) {
        return false;
      }
    }
  }

  return true;
}
