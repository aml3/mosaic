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

(*
 * Return a copy of the passed in board that has the tile added at spot (x,y).
 *)
let place_tile (tile : Types.tile)
               (x : int) (* x-coordinate for the top-left corner. *)
               (y : int) (* y-coordinate for the top-left corner. *)
               (board : Types.board) =
  let Tile(tile) = tile in
  let Board(board) = board in
  (* This may not be a deep copy. So, if things fail, check here. *)
  let board = Array.copy board in (* Copy. Arrays are modified in place. *)
  for i = 0 to (Array.length tile) - 1 do
    let tile_row = tile.(i) in
    let board_row = board.(i) in
    for j = 0 to (Array.length tile_row) - 1 do
      board_row.(j) <- tile_row.(j)
    done
  done;
  Board(board)
;;

exception Found_solution of Types.configuration;;
let rec brute_force (partial_solution : Types.configuration) = 
  let Configuration(remaining_tiles, Board(board)) = partial_solution in
  match remaining_tiles with
  | [] -> (true, partial_solution)
  | hd :: tl ->
    try for n = 0 to 3 do
      let rotated_tile = repeat rotate_tile_cw hd n in
      (* For now, just check every single spot. *)
      for i = 0 to (Array.length board) - 1 do
        let row = board.(i) in
        for j = 0 to (Array.length row) - 1 do
          if valid_placement rotated_tile j i (Board board)
          then begin
            let new_board = place_tile rotated_tile j i (Board board) in
            let new_config = Configuration(tl, new_board) in
            let (result, returned_solution) = brute_force new_config in
            match result with
            | true -> raise (Found_solution returned_solution)
            | false -> ()
          end
        done;
      done;
    done;
    (* If we reach here, then we couldn't place a tile. *)
    (false, partial_solution)
    with Found_solution solution -> (true, solution)
;;
