open Types;;
open Utils;;

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
    let Tile(tile) = tile in
    let Board(board) = board in
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

(* We return a list of tiles and their locations when we're done. *)
exception Found_solution of Types.solution;;
let rec brute_force (intermediate_state : Types.configuration) 
                    (partial_solution : Types.solution) =
  let Configuration(remaining_tiles, Board(board)) = intermediate_state in
  match remaining_tiles with 
  | [] -> (true, partial_solution)
  | hd :: tl ->
    try for n = 0 to 3 do (* Try each orientation for a tile. *)
      let rotated_tile = repeat rotate_tile_cw hd n in
      (* For now, just check every single spot. *)
      Array.iteri (fun i row ->
        Array.iteri (fun j _ ->
          if valid_placement rotated_tile j i (Board board)
          then begin
            let new_board = place_tile rotated_tile j i (Board board) in
            let Solution(placements) = partial_solution in
            let placements = (rotated_tile, (j,i)) :: placements in
            let partial_solution = Solution(placements) in
            let new_state = Configuration(tl, new_board) in
            let (result, solution) = brute_force new_state partial_solution in
            match result with
            | true -> raise (Found_solution solution)
            | false -> ()
          end
        ) row
      ) board
    done;
    (* If we reach here, then we couldn't place a tile. *)
    (false, partial_solution)
    with Found_solution solution -> (true, solution)
;;

let solve (blank_config : Types.configuration) =
  let empty_solution = Solution [] in
  brute_force blank_config empty_solution
;;
