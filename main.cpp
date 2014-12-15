#include "dlx.h"
#include "partial_cross.h"
#include <iostream>
#include <vector>
#include <utility>

using namespace std;

int main(void) {
  // Building the grid
  header * root = nullptr;

  // Get count 
  int count = 0;
  count_sols(root, count);

  // Output count
  cout << "Found " << count << " solutions!\n";
  return 0;
}
