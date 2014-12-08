(* Type definitions *)

(* We represent a cell by its color *)
type cell = Cell of int;;

(*
 * We represent a tile by a grid of cells. If a cell isn't actually part of a tile,
 * we give it color #000000.
 *)
type tile = Tile of cell array array;;

(*We represent a board as a nxm matrix of cells *)
type board = Board of tile;;

(*
 * We represent a configuration by a partially filled board and a list of available
 * tiles.
 *)
type configuration = Configuration of (tile list) * board;;
