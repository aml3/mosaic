open Types;;

let string_of_cell cell =
  match cell with
  | Empty -> "."
  | Missing -> "#"
  | Filled(i) -> "x"
;;

let string_of_tile (tile : Types.tile) =
  let Tile(tile) = tile in
  let chars = Array.map (fun row ->
    Array.map (fun cell -> string_of_cell cell) row) tile in
  Array.fold_left (fun acc row ->
    let row_str = Array.fold_left (fun acc str_cell ->
      acc ^ str_cell
    ) "" row in
    acc ^ row_str ^ "\n"
  ) "" chars
;;

let print_coordinates i j =
  print_endline ("(i,j)="^"("^(string_of_int i)^","^(string_of_int j)^")")
;;

(* Repeatedly apply a function f n times to an argument x. *)
let rec repeat f x n = if n = 0 then x else repeat f (f x) (n-1);;

let make_array dim_x dim_y =
  let empty_row = Array.make dim_x Empty in
  let matrix = Array.make dim_y empty_row in
  Array.iteri (fun i _ ->
    let new_row = Array.make dim_x Empty in (* We want a fresh row every time. *)
    matrix.(i) <- new_row;
  ) matrix;
  matrix
;;

(* Rotate a tile by 90 degrees clockwise. Gives back a fresh tile. *)
let rotate_tile_cw (tile : Types.tile) =
  let Tile(tile) = tile in
  let orig_y = Array.length tile in
  (* This is here in case the array is ragged. *)
  let orig_x = Array.fold_left (fun acc r -> max (Array.length r) acc) 0 tile in
  let rotated_tile = make_array orig_y orig_x in
  Array.iteri (fun y row ->
    Array.iteri (fun x _ ->
      rotated_tile.(x).(orig_y - y - 1) <- tile.(y).(x);
      ) row;
    ) tile;
  Tile(rotated_tile)
;;

let reflect_tile (tile : Types.tile) = 
  let Tile(tile) = tile in
  let orig_y = Array.length tile in
  (* This is here in case the array is ragged. *)
  let orig_x = Array.fold_left (fun acc r -> max (Array.length r) acc) 0 tile in
  let reflected_tile = make_array orig_x orig_y in
  Array.iteri (fun y row ->
    Array.iteri (fun x e ->
      (* Reflect across the x-axis. *)
      reflected_tile.(y).(orig_x - x - 1) <- e;
    ) row;
  ) tile;
  Tile(reflected_tile)
;;

(*
 * Return a copy of the passed in board that has the tile added at spot (x,y).
 *)
let place_tile (tile : Types.tile)
               (x : int) (* x-coordinate for the top-left corner. *)
               (y : int) (* y-coordinate for the top-left corner. *)
               (board : Types.board) =
  let Tile(tile) = tile in
  let Board(board) = board in
  let deep_copy = Array.map (fun row -> Array.copy row) in
  let new_board = deep_copy board in (* Copy. Arrays are modified in place. *)
  Array.iteri (fun i tile_row ->
    let new_board_row = new_board.(i+y) in
    Array.iteri (fun j _ ->
      match (new_board_row.(j+x)) with
      | Filled _
      | Missing -> ()
      | Empty -> new_board_row.(j+x) <- tile_row.(j)
      ) tile_row
    ) tile;
  Board(new_board)
;;

(*
 * Loop over the tile and check to make sure each of its filled in cells
 * corresponds to an empty on in the board. We raise an exception as soon as a
 * mismatch occurs.
 *)
exception Invalid_placement;;
let valid_placement_arr (tile : cell array array)
                        (x : int)
                        (y : int)
                        (board : cell array array) =
  try begin
    Array.iteri (fun i tile_row ->
      Array.iteri (fun j tile_cell ->
        let board_cell = (board.(i + y)).(j + x) in
        match (tile_cell, board_cell) with
        | (Filled _, Filled _)
        | (Filled _, Missing) -> raise Invalid_placement
        | _ -> ()
        ) tile_row
      ) tile;
    true end
  with Invalid_placement
       | Invalid_argument(_) (* Fell off the board. *) -> false
;;

let valid_placement (tile : Types.tile)
                    (x : int) (* x-coordinate for the top-left corner. *)
                    (y : int) (* y-coordinate for the top-left corner. *)
                    (board : Types.board) =
  let Tile(tile) = tile in
  let Board(board) = board in
  valid_placement_arr tile x y board
;;
