(* We represent a cell by its color *)
type cell = int;;

(*
 * We represent a tile by a list of cells with coordinates.
 * The uppermost tile on the leftmost column is (0,0), and
 * all other coordinates are relative to this.
 *)
type tile = (cell * int * int) list;;

(*
 * We represent a configuration by a list of tiles with coordinates.
 * The coordinates represent the assignment of the (0,0) coordinate of each tile
 * to a real coordinate in the nxm board.
 *)
type configuration = (tile * int * int) list;;
