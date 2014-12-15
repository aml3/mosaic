#ifndef CHECKERBOARD_H
#define CHECKERBOARD_H

#include <vector>
using namespace std;
typdef vector<vector<int > > tile;
typedef vector<int> row;

tile piece1 = {
  row({1, 1, 1}),
  vector<int>({0, 1, 0}),
  vector<int>({0, 1, 0}) };

vector<vector<int> > piece2 = {
  vector<int>({1, 0, 1}),
  vector<int>({1, 1, 1}) };

vector<vector<int> > piece3 = {
  vector<int>({1, 0, 0}),
  vector<int>({1, 0, 0}),
  vector<int>({1, 1, 1}) };

vector<vector<int> > piece4 = {
  vector<int>({1, 0, 0}),
  vector<int>({1, 1, 0}),
  vector<int>({0, 1, 1}) };

vector<vector<int> > piece5 = {
  vector<int>({0, 1, 0}),
  vector<int>({1, 1, 1}),
  vector<int>({0, 1, 0}) };

vector<vector<int> > piece6 = {
  vector<int>({1, 0}),
  vector<int>({1, 0}),
  vector<int>({1, 1}),
  vector<int>({1, 0}) };

vector<vector<int> > piece7 = {
  vector<int>({0, 1, 1}),
  vector<int>({1, 1, 0}),
  vector<int>({0, 1, 0}) };

vector<vector<int> > piece8 = {
  vector<int>({1}),
  vector<int>({1}),
  vector<int>({1}),
  vector<int>({1}),
  vector<int>({1}) };

vector<vector<int> > piece9 = {
  vector<int>({1, 0}),
  vector<int>({1, 0}),
  vector<int>({1, 0}),
  vector<int>({1, 1}) };

vector<vector<int> > piece10 = {
  vector<int>({1, 1}),
  vector<int>({1, 1}),
  vector<int>({1, 0}) };

vector<vector<int> > piece11 = {
  vector<int>({0, 1}),
  vector<int>({0, 1}),
  vector<int>({1, 1}),
  vector<int>({1, 0}) };

vector<vector<int> > piece12 = {
  vector<int>({1, 1, 0}),
  vector<int>({0, 1, 0}),
  vector<int>({0, 1, 1}) };

int num_pieces = 12;
vector<vector<vector<int > > >  pieces = 
  vector<vector<vector< int> > >({ piece1
  , piece2
  , piece3
  , piece4
  , piece5
  , piece6
  , piece7
  , piece8
  , piece9
  , piece10
  , piece11
  , piece12 });

int piecedims_x[12] = { 3, 3, 3, 3, 3, 2, 3, 1, 2, 2, 2, 3 };
int piecedims_y[12] = { 3, 2, 3, 3, 3, 4, 3, 5, 4, 3, 4, 3 };

int board_x = 9;
int board_y = 9;
int board[9][9] = {
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1},
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 0, 0, 0} };


#endif
