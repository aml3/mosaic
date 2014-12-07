(* Type definitions *)

(* We represent a cell by its color *)
type cell = int;;

(*
 * We represent a tile by a grid of cells. If a cell isn't actually part of a tile,
 * we give it color #000000.
 *)
type tile = cell array array;;

(*We represent a board as a nxm matrix of cells *)
type board = cell array array;;

(*
 * We represent a configuration by a partially filled board and a list of available
 * tiles.
 *)
type configuration = (tile list) * board;;
