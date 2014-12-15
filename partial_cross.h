#ifndef CHECKERBOARD_H
#define CHECKERBOARD_H

#include <vector>
using namespace std;
typedef vector<vector<int > > tile;
typedef vector<int> row;

tile piece1 = {
  row({1, 1, 1}),
  row({0, 1, 0}),
  row({0, 1, 0}) };

vector<row > piece2 = {
  row({1, 0, 1}),
  row({1, 1, 1}) };

vector<row > piece3 = {
  row({1, 0, 0}),
  row({1, 0, 0}),
  row({1, 1, 1}) };

vector<row > piece4 = {
  row({1, 0, 0}),
  row({1, 1, 0}),
  row({0, 1, 1}) };

vector<row > piece5 = {
  row({0, 1, 0}),
  row({1, 1, 1}),
  row({0, 1, 0}) };

vector<row > piece6 = {
  row({1, 0}),
  row({1, 0}),
  row({1, 1}),
  row({1, 0}) };

vector<row > piece7 = {
  row({0, 1, 1}),
  row({1, 1, 0}),
  row({0, 1, 0}) };

vector<row > piece8 = {
  row({1}),
  row({1}),
  row({1}),
  row({1}),
  row({1}) };

vector<row > piece9 = {
  row({1, 0}),
  row({1, 0}),
  row({1, 0}),
  row({1, 1}) };

vector<row > piece10 = {
  row({1, 1}),
  row({1, 1}),
  row({1, 0}) };

vector<row > piece11 = {
  row({0, 1}),
  row({0, 1}),
  row({1, 1}),
  row({1, 0}) };

vector<row > piece12 = {
  row({1, 1, 0}),
  row({0, 1, 0}),
  row({0, 1, 1}) };

int num_pieces = 12;
vector<tile>  pieces = vector<tile>(
  { piece1
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
