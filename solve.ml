open Types;;

(*
 * Loop over the tile and check to make sure each of its filled in cells
 * corresponds to an empty on in the board. We raise an exception as soon as a 
 * mismatch occurs.
 *)
exception Invalid_placement;;
let valid_placement (tile : Types.tile)
                    (x : int) (* x-coordinate for the top-left corner. *)
                    (y : int) (* y-coordinate for the top-left corner. *)
                    (board : Types.board) =
  try begin
    let Tile(grid) = tile in
    let Board(board) = board in
    for i = 0 to (Array.length grid) - 1 do
      let tile_row = grid.(i) in
      for j = 0 to (Array.length tile_row) - 1 do
        let Cell(tile_cell) = tile_row.(j) in
        let Cell(board_cell) = (board.(i + y)).(j + x) in
        match (tile_cell, board_cell) with
        | (Some(_), Some(_)) -> raise Invalid_placement
        | _ -> ()
      done
    done; true end
  with Invalid_placement -> false
;;

(* Repeatedly apply a function f n times to an argument x. *)
let rec repeat f x n = if n = 0 then x else repeat f (f x) (n-1);;

(* Rotate a tile by 90 degrees clockwise. *)
let rotate_tile_cw (tile : Types.tile) = 
  let Tile(tile) = tile in
  let orig_y = Array.length tile in
  let orig_x = Array.fold_left (fun acc r -> max (Array.length r) acc) 0 tile in
  let default_cell = Cell(None) in
  let rotated_tile = Array.make_matrix orig_x orig_y default_cell in
  for i = 0 to (Array.length rotated_tile) - 1 do
    let rotated_row = rotated_tile.(i) in
    for j = 0 to (Array.length rotated_row) - 1 do
      let orig_row = tile.(j) in
      rotated_row.(j) <- orig_row.(i);
    done;
  done;
  Tile(rotated_tile)
;;

let brute_force (partial_solution : Types.configuration) = 
  let Configuration(remaining_tiles, Board(board)) = partial_solution in
  match remaining_tiles with
  | [] -> partial_solution 
  | hd :: tl ->
      for n = 0 to 3 do
        let rotated_tile = repeat rotate_tile_cw hd n in
        ()
      done;
      partial_solution
;;
