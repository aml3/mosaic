#include "dlx.h"
#include <iostream>
using namespace std;

pair<header *, vector<header *> > initialize(int num_cols) {
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
  }

  pair<header *, vector<header *> > result(root, instance);
  return result;
}

header * find_least_full(header * root) {
  header * least = (header *)root->right;

  for(header * iter = least; iter != root; iter = (header *)iter->right) {
    cout << "header count = " << iter->count << endl;
    if(iter->count < least->count)
      least = iter;
  }

  return least;
}

void remove_col(header * col_head) {
  col_head->right->left = col_head->left;
  col_head->left->right = col_head->right;

  for(node * r = col_head->down; r != col_head; r = r->down) {
    for(node * c = r->right; c != r; c = c->right) {
      c->down->up = c->up;
      c->up->down = c->down;
      --col_head->count;
    }
  }
}

void replace_col(header * col_head) { 
  for(node * r = col_head->up; r != col_head; r = r->up) {
    for(node * c = r->left; c != r; c = c->left) {
      c->down->up = c;
      c->up->down = c;
      ++col_head->count;
    }
  }

  col_head->right->left = col_head;
  col_head->left->right = col_head;
}

void count_sols(header * root, int & counter) {
  cout << "entering count_sols" << endl;
  header * root_left = (header *) root->left;
  if(root_left == root || root_left->tile == true) {
    ++counter;
    return;
  }

  cout << "checking least full" << endl;
  header * least_full = find_least_full(root);
  if (least_full->count == 0) return;
  remove_col(least_full);
  node * next = least_full->down;
  cout << "entering while loop" << endl;

  while(next != least_full) {
    for(node * iter = next->right; iter != next; iter = iter->right)
      remove_col(iter->col_head);
    count_sols(root, counter);
    for(node * iter = next->left; iter != next; iter = iter->left)
      replace_col(iter->col_head);
    next = next->down;
  }
  replace_col(least_full);
}
