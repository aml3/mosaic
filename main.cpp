#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>
#include <tuple>

using namespace std;

vector<int> try_placement(int idx, int x, int y, int r, int rr);
typedef vector<vector<int > > tile;

int main(void) {
  // Get initial grid
  int num_cols = num_pieces + board_x * board_y;
  auto grid_pair = initialize(num_cols);
  header * root = grid_pair.first;
  vector<header *> grid = grid_pair.second;

  // Build the grid
  // First, properly set tile flags
  for(int i = 0; i < num_pieces; ++i){ 
    grid[num_cols - num_pieces + i - 1]->tile = true;
  }

  // Next, add rows for placements
  for(int i = 0; i < num_pieces; ++i) {
    for(int x = 0; x < board_x; ++x) {
      for(int y = 0; y < board_y; ++y) {
        for (int rotate = 0; rotate < 4; ++rotate) {
          for (int reflect = 0; reflect < 2; ++reflect) {
            vector<int> covered = try_placement(i, x, y, rotate, reflect);
            if (covered.size() == 0) continue;

            bool first = true;
            node * prev = nullptr;
            for(int j = 0; j < covered.size(); ++j) {
              node * row_node = new node();
              row_node->used = true;
              if(first) {
                first = false;
              }
              else {
                row_node->left = prev;
                row_node->right = prev->right;
                prev->right->left = row_node;
                prev->right = row_node;
              }

              grid[covered[j]]->insert(row_node);
              grid[i]->insert(row_node);
              prev = row_node;
            }
          }
        }
      }
    }
  }
  cout << "passed for loops" << endl;

  // Get count 
  int count = 0;
  count_sols(root, count);

  // Output count
  cout << "Found " << count << " solutions!\n";
  return 0;
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
      indices.push_back(board_i + board_j * board_x);
    }
  }

  cleanup(tile, dim_x, dim_y);

  return indices;
}
