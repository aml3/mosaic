#include "dlx_types.h"

void header::insert(node * item) {
  item->col_head = this;
  item->down = this;
  item->up = this->up;
  this->up->down = item;
  this->up = item;
  ++this->count;
}

void matrix::reflect() {
  //cout << "entering reflect" << endl;
  this->orientation.first *= -1;

  int ** temp = new int*[this->dim_y];
  for (int i = 0; i < this->dim_y; i++) {
    int * t = new int[this->dim_x];
    for (int j = 0; j < this->dim_x; j++) {
      t[j] = this->grid[i][j];
    }
    temp[i] = t;
  }
  
  for (int i = 0; i < this->dim_y; i++) {
    for (int j = 0; j < this->dim_x; j++) {
      this->grid[this->dim_y - i - 1][j] = temp[i][j];
    }
  }

  for (int i = 0; i < this->dim_y; i++) {
    delete [] temp[i];
  }
  delete [] temp;
  //cout << "exiting reflect" << endl;
}

void matrix::rotate(int r) {
  for (int i = 0; i < r; i++) {
    this->rotate();
  }
}

void matrix::reflect(int r) {
  for (int i = 0; i < r; i++) {
    this->reflect();
  }
}

void matrix::rotate() {
  //cout << "entering rotate" << endl;
  if (this->orientation.second < 0) {
    this->orientation.second -= 1;
  } else {
    this->orientation.second += 1;
  }
  this->orientation.second %= 4;
  
  int ** temp = new int*[this->dim_y];
  for (int i = 0; i < this->dim_y; i++) {
    int * t = new int[this->dim_x];
    for (int j = 0; j < this->dim_x; j++) {
      t[j] = this->grid[i][j];
    }
    temp[i] = t;
  }
  
  for (int i = 0; i < this->dim_y; ++i) {
    for (int j = 0; j < this->dim_x; ++j) {
      this->grid[j][dim_y - 1 - i] = temp[i][j];
    }
  }
  
  for (int i = 0; i < this->dim_y; i++) {
    delete [] temp[i];
  }
  delete [] temp;
  //cout << "exiting rotate" << endl;
}

void matrix::addPiece(int idx, tile &t, int tx, int ty, int x, int y) {
  cout << "entering add " << idx << endl;
  for (int i = 0; i < ty; ++i) {
    for (int j = 0; j < tx; ++j) {
      int board_i = i + y;
      int board_j = j + x;
      if (t[i][j] != 0) {
        this->space--;
        this->grid[board_i][board_j] = 8;//t[i][j];
      }
    }
  }
  cout << "exiting add" << endl;
}

void matrix::removePiece(int idx, tile &t, int tx, int ty, int x, int y) {
  cout << "entering remove " << idx << endl;
  for (int i = 0; i < ty; ++i) {
    for (int j = 0; j < tx; ++j) {
      int board_i = i + x;
      int board_j = j + y;
      if (t[i][j] != 0) {
        this->grid[board_i][board_j] = 0;
        this->space++;
      }

      if (t[i][j] != 0 && this->grid[board_i][board_j] == 0) {
        cout << "wtf why is this happening" << endl;
      }
    }
  }
  cout << "exiting remove" << endl;
}
