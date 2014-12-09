(* Type definitions *)

(* We represent a cell by its color. cells with None are empty. *)
type cell = Empty | Missing | Filled of int;;

(*
 * We represent a tile by a grid of cells. If a cell isn't actually part of a tile,
 * we give it color #FFFFFF.
 *)
type tile = Tile of cell array array;;

(*We represent a board as a nxm matrix of cells *)
type board = Board of cell array array;;

(*
 * We represent a configuration by a partially filled board and a list of available
 * tiles.
 *)
type configuration = Configuration of (tile list) * board;;

type solution = Solution of (tile * (int * int)) list;;
