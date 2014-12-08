(* Type definitions *)

(* We represent a cell by its color *)
type cell = int;;

(*
 * We represent a tile by a grid of cells. If a cell isn't actually part of a tile,
 * we give it color #000000.
 *)
type tile = cell array array;;

(* A board is the largest tile *)
type board = tile;;

(*
 * We represent a configuration by a partially filled board and a list of available
 * tiles.
 *)
type configuration = (tile list) * board;;
