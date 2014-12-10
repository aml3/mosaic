open Types;;
open Utils;;

let num_nonzeros (column : int list) = List.fold_left (fun acc value -> 
  if value <> 0 then acc+1 else acc) 0 column
;;

let all_zeros (rows : (int * (int list)) list) = 
  List.fold_left (fun acc (_,row) ->
    (List.fold_left (fun ac entry ->
        if entry = 0 then ac else false) true row) && acc
  ) true rows
;;

(*
 * Run Knuth's algorithm X. Return a list containing the indices of rows in the
 * exact cover.
 *
 * Since we'll want to eventually use a sparse array for dancing links, we'll
 * pass in lists for the rows and for the columns. Otherwise, taking the
 * transpose of a sparse array will not be fun. The first part of a tuple in a
 * list is the index, the second part is the actual row/column. We may have to
 * modify this for dancing links (e.g. every entry in a row also needs a column
 * int).
 *
 * NOTE: We'll have to keep rows and cols in sync. Is there a better way to 
 * handle dancing links? I think arrays will cause lots of pain later on.
 *)
let rec algorithm_x (rows : (int * (int list)) list)
                    (cols : (int * (int list)) list)
                    (selection : int list) (* Indices of rows in the cover *) =
  (* We're done if the grid is empty. If it's all zeros, then there isn't a
   * solution for this branch. *)
  match rows with 
  | [] -> (true, selection)
  | rows when all_zeros rows -> (false, selection)
  | _ ->
    (* Find the column c with the fewest non-zero entries. *)
    let (c_j, c) = List.fold_left (fun (col_j, min_col) (j, col) ->
      if num_nonzeros col < num_nonzeros min_col 
      then (j, col) else (col_j, min_col)) (List.hd cols) (List.tl cols) in
    (* Randomly select a row r with a nonzero entry t from c. (I don't want to
     * deal with randomness right now, so we'll just take the first one. If it
     * works with a random selection then it should work with a deterministic
     * one.) *)
    let (r_i,r) = List.find (fun (i,row) ->
      if (List.nth row c_j) <> 0 then true else false
    ) rows in
    (* TODO: Keep rows and cols in sync. *)
    (* Remove all rows conflicting with r. *)
    let rows = List.filter (fun (_, row) ->
      if (List.exists2 (fun row_e r_e -> row_e = r_e && row_e <> 0) row r)
      then false else true) rows in
    (* Remove all columns covered by r. *)
    let cols = List.filter (fun (j,col) -> 
      let r_e = (List.nth r j) in
      if (List.exists ((=) r_e) col) then false else true) cols in
    (* Remove r. *)
    let rows = List.filter (fun (i,_) -> i <> r_i) rows in
    (* Add r to the solution and recurse. *)
    let selection = r_i :: selection in
    algorithm_x rows cols selection
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
      let rotated_tile = Utils.repeat Utils.rotate_tile_cw hd n in
      (* For now, just check every single spot. *)
      Array.iteri (fun i row ->
        Array.iteri (fun j _ ->
          if Utils.valid_placement rotated_tile j i (Board board)
          then begin
            let new_board = Utils.place_tile rotated_tile j i (Board board) in
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
