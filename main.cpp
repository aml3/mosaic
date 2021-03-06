#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>
#include <tuple>
#include <algorithm>

using namespace std;

vector<int> try_placement(int idx, int x, int y, int r, int rr);
typedef vector<vector<int > > tile;

int main(void) {
  // Get initial grid
  int num_cols = num_pieces + board_x * board_y;
  auto grid_pair = initialize(num_cols);
  header * root = grid_pair.first;
  vector<header *> grid = grid_pair.second;

  vector<int> empty_indices;
  for (int i = 0; i < board_y; i++) {
    for (int j = 0; j < board_x; j++) {
      if (board[i][j] == 0) {
        empty_indices.push_back(num_pieces + j + i * board_x);
      }
    }
  }
  cout << empty_indices.size() << " empty indices" << endl;

  // Build the grid
  // First, properly set tile flags
  for(int i = 0; i < num_pieces; ++i){ 
    grid[i]->tile = true;
  }

  // Next, add rows for placements
  int loop = 0;
  for(int i = 0; i < num_pieces; ++i) {
    for(int x = 0; x < board_x; ++x) {
      for(int y = 0; y < board_y; ++y) {
        for (int rotate = 0; rotate < 4; ++rotate) {
          for (int reflect = 0; reflect < 2; ++reflect) {
            loop++;
            vector<int> covered = try_placement(i, x, y, rotate, reflect);

            node * tile_node = new node();
            tile_node->removed = false;
            grid[i]->insert(tile_node);

            if (covered.size() == 0) continue;

            node * prev = tile_node;
            for(int j = 0; j < covered.size(); ++j) {
              node * row_node = new node();
              row_node->removed = false;
              row_node->left = prev;
              row_node->right = prev->right;
              prev->right->left = row_node;
              prev->right = row_node;

              grid[covered[j]]->insert(row_node);
              prev = row_node;
            }

            for (int z = 0; z < empty_indices.size(); z++) {
              node * row_node = new node();
              row_node->removed = false;
              row_node->left = prev;
              row_node->right = prev->right;
              prev->right->left = row_node;
              prev->right = row_node;
              grid[empty_indices[z]]->insert(row_node);
              prev = row_node;
            }
          }
        }
      }
    }
  }

  cout << "passed for loops " << loop << endl;

  // Get count 
  int count = 0;
  count_sols(root, count);

  // Output count
  cout << "Found " << count << " solutions :D\n";
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
      indices.push_back(num_pieces + board_i + board_j * board_x);
    }
  }

  cleanup(tile, dim_x, dim_y);
  sort(indices.begin(), indices.end());
  return indices;
}
