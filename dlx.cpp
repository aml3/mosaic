#include "dlx.h"
#include <iostream>
#include <sstream>
#include <vector>
using namespace std;

string string_of_row(node * n) {
  stringstream ss;
  
  for (node * c = n->right; c != n; c = c->right) {
    ss << c->col_head->name << ", ";
  }

  return ss.str();
}

pair<header *, vector<header *> > initialize(int num_cols, int num_pieces) {
  vector<header *> instance; 
  instance.reserve(num_cols);
  header * root = new header();
  for (int i = 0; i < num_cols; ++i) {
    header * h = new header();
    instance.push_back(h);
    h->left = root->left;
    h->right = root;
    root->left->right = h;
    root->left = h;

    stringstream ss;
    if (i < num_pieces) {
      ss << "tile " << i;
    } else {
      int temp = i - num_pieces;
      int x = temp % 9;
      int y = temp / 9;
      ss << "(" << x << ", " << y << ")";
    }
    h->name = ss.str();
  }

  pair<header *, vector<header *> > result(root, instance);
  return result;
}

header * find_least_full(header * root) {
  header * least = (header *)root->right;

  for(header * iter = least; iter != root; iter = (header *)iter->right) {
    cout << iter->name << " count = " << iter->count << endl;
    if(iter->count < least->count)
      least = iter;
  }

  return least;
}

void remove_col(header * col_head, vector<node*> &removals) {
  col_head->right->left = col_head->left;
  col_head->left->right = col_head->right;

  for(node * r = col_head->down; r != col_head; r = r->down) {
    for (node * c = r->right; c != r; c = c->right) {
      if (!c->removed) {
        removals.push_back(c);
        c->down->up = c->up;
        c->up->down = c->down;
        --c->col_head->count;

        c->removed = true;
      }
    }
  }
}

void replace_col(header * col_head, vector<node *> &removed_rows) { 
  for (int i = 0; i < removed_rows.size(); i++) {
    node * r = removed_rows[i];
    for (node * c = r->left; c != r; c = c->left) {
      if (c->removed) {
        c->down->up = c->up;
        c->up->down = c->down;
        ++c->col_head->count;

        c->removed = false;
      }
    }
  }

  col_head->right->left = col_head;
  col_head->left->right = col_head;
}

void count_sols(header * root, int & counter) {
  cout << "entering count_sols" << endl;
  header * root_left = (header *) root->left;
  if(root_left->tile == true) {
    ++counter;
    cout << "**** found a solution" << endl;
    return;
  }

  cout << "checking least full" << endl;
  header * least_full = find_least_full(root);
  if (least_full->count == 0) return;
  cout << "choosing " << least_full->name << endl;

  vector<node *> least_rows;
  remove_col(least_full, least_rows);

  node * next = least_full->down;
  while(next != least_full) {
    vector<vector<node *> > cols;
    for(node * iter = next->right; iter != next; iter = iter->right) {
      vector<node*> column_removals;
      remove_col(iter->col_head, column_removals);
      cols.push_back(column_removals);
    }

    count_sols(root, counter);

    for(node * iter = next->left; iter != next; iter = iter->left) {
      replace_col(iter->col_head, cols.front());
      cols.erase(cols.begin());
    }

    next = next->down;
  }
  replace_col(least_full, least_rows);
  cout << "exiting count_sols" << endl;
}
