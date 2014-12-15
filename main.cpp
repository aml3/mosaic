#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>

using namespace std;

vector<int> try_placement(int idx, int x, int y);

int main(void) {
  // Get initial grid
  int num_cols = num_pieces + board_x * board_y;
  auto grid_pair = initialize(num_pieces + board_x * board_y);
  header * root = grid_pair.first;
  vector<header *> grid = grid_pair.second;

  // Build the grid
  // First, properly set tile flags
  for(int i = 0; i < num_pieces; ++i) grid[i]->tile = true;

  // Next, add rows for placements
  for(int i = 0; i < num_pieces; ++i) {
    for(int x = 0; x < board_x; ++x) {
      for(int y = 0; y < board_y; ++y) {
        vector<int> covered = try_placement(i, x, y);
        if(covered.size() == 0)
          continue;
        auto covered_iter = covered.cbegin();
        for(int j = 0; j < num_cols; ++j) {
          node * row_node = new node();
          row_node->used = (j == i || j == *covered_iter);
          if(j == *covered_iter) ++covered_iter;
          grid[j]->insert(row_node);
        }
      }
    }
  }

  // Get count 
  int count = 0;
  count_sols(root, count);

  // Output count
  cout << "Found " << count << " solutions!\n";
  return 0;
}

vector<int> try_placement(int idx, int x, int y) {
  // Try placing tile idx at (x, y)
  // If it's valid, return a vector of the parts of the board covered
  // If it isn't valid, return an empty vector
}
