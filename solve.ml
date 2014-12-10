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
(* Commented b/c dancing links exists
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
*)

(* DANCING LINKS START *)

let find_least_filled_col (grid : Types.dlx_matrix) =
    let rec rec_find_least_filled (min : int) (curr_best : Types.dlx_node) (curr : Types.dlx_node) =
        if curr == grid.head then curr_best
        else 
            if curr.count < min then rec_find_least_filled curr.count curr curr.right
            else rec_find_least_filled min curr_best curr.right
        in
    rec_find_least_filled grid.head.count grid.head grid.head.right
    ;;

let find_covered_rows (col_hdr : Types.dlx_node) =
    let rec rec_find_covered_rows (curr : Types.dlx_node) = 
        if curr == col_hdr then []
        else match curr.content with 
                | Filled _ -> curr :: (rec_find_covered_rows curr.down)
                | _        -> rec_find_covered_rows curr.down
        in
    rec_find_covered_rows col_hdr.down
    ;;

let node_iter (shaker : Types.dlx_node -> 'a) (mover : Types.dlx_node -> Types.dlx_node) (start : Types.dlx_node) =
    let rec node_iter_rec (curr : Types.dlx_node) =
        if curr != start
        then (shaker curr; node_iter_rec (mover curr))
    in
    node_iter_rec (mover start)
    ;;

let cover_reassign (node : Types.dlx_node) =
    node.right.left <- node.left;
    node.left.right <- node.right;
    node_iter
        (fun x -> node_iter 
            (fun y -> (y.down.up <- y.up; y.up.down <- y.down; y.col_h.count <- y.col_h.count - 1))
            (fun y -> y.right)
            x)
        (fun x -> x.down)
        node
    ;;

let uncover_reassign (node : Types.dlx_node) =
    node_iter
        (fun x -> node_iter
            (fun y -> (y.down.up <- y; y.up.down <- y; y.col_h.count <- y.col_h.count + 1))
            (fun y -> y.left)
            x)
        (fun x -> x.up)
        node;
    node.left.right <- node;
    node.right.left <- node;
    ;;

let rec one_level_flatten (nested : 'a list list list) =
    match nested with
        | elems :: rest -> (one_level_flatten rest) @ elems
        | []            -> []
    ;;

let rec dlx_x (sol : int list) (grid : Types.dlx_matrix) =
    if grid.count = 0 then [sol]
    else 
        begin
            let col = find_least_filled_col grid in
            let rows = find_covered_rows col in
            cover_reassign col;
            let sols = List.map
                (
                    fun row -> 
                    (node_iter
                        (fun x -> cover_reassign x.col_h)
                        (fun x -> x.right)
                        row;
                     let new_sol = dlx_x (row.row :: sol) grid in
                     node_iter
                        (fun x -> uncover_reassign x.col_h)
                        (fun x -> x.left)
                        row;
                     new_sol)
                )
                rows
                in
            uncover_reassign col;
            one_level_flatten sols
        end
    ;;
(* DANCING LINKS END *)

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
  (* brute_force blank_config empty_solution *)
  let knuthgrid = Utils.make_dlx_grid blank_config in
  let dlx_sol = dlx_x [] knuthgrid in
  Utils.map_x_to_pieces dlx_sol blank_config
;;
