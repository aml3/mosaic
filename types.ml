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

(* A solution is represented as an assignment of tiles to positions *)
type solution = Solution of (tile * (int * int)) list;;

(* The node type for the Dancing Links algorithm *)
type dlx_node = {
    matrix : dlx_matrix; (* Reference to the matrix holding this node. *)
    mutable left : dlx_node;
    mutable right : dlx_node;
    mutable up :dlx_node;
    mutable down : dlx_node;
    mutable col_h : dlx_node;

    content : int;
    row : int;
    mutable count : int;
}

(* The sparse matrix type for the Dancing Links algorithm *)
and dlx_matrix = {
    head : dlx_node;
    mutable mcount : int
};;
