open Types;;
open Utils;;

(*
 * Run Knuth's algorithm X. Return a list containing the indices of rows in the
 * exact cover.
 *)

(* DANCING LINKS START *)

let find_least_filled_col (grid : Types.dlx_matrix) =
  let rec least (min : int) (best : Types.dlx_node) (curr : Types.dlx_node) =
    if curr == grid.head then (best, min)
    else if curr.count < min then least curr.count curr curr.right
      else least min best curr.right in
  least grid.head.count grid.head grid.head.right
;;

let find_covered_rows (col_hdr : Types.dlx_node) =
  let rec find_covered (curr : Types.dlx_node) (acc : Types.dlx_node list) = 
    if curr == col_hdr then acc
    else match curr.content with 
      | 0 -> find_covered curr.down acc
      | _ -> find_covered curr.down (curr :: acc) in
  find_covered col_hdr.down []
;;

let node_iter (shaker : Types.dlx_node -> 'a) (* Function to apply to nodes. *)
              (mover : Types.dlx_node -> Types.dlx_node) (* Node movement. *)
              (start : Types.dlx_node) =
  let rec node_iter_rec (curr : Types.dlx_node) =
      if curr != start
      then (shaker curr; node_iter_rec (mover curr)) in
  node_iter_rec (mover start)
;;

let update_count (node : Types.dlx_node) (delta : int) =
  node.col_h.count <- node.col_h.count + delta;
  node.matrix.mcount <- node.matrix.mcount + delta;
;;

let cover_reassign (node : Types.dlx_node) =
  (* Remove the node from it's row. *)
  node.right.left <- node.left;
  node.left.right <- node.right;
  (* For each row in its column, remove that row. *)
  node_iter
    (fun x -> (* shaker *)
      (* Remove other rows with the same content in that column. *)
      node_iter
        (fun y ->
          y.down.up <- y.up;
          y.up.down <- y.down; 
          update_count y (-1);)
        (fun y -> y.right)
        x)
    (fun x -> x.down) (* mover *)
    node
;;

let uncover_reassign (node : Types.dlx_node) =
  (* Go across each row in the column, adding it back. *)
  node_iter
    (fun x -> (* shaker *)
      node_iter
        (fun y -> (* shaker *)
          y.down.up <- y; 
          y.up.down <- y; 
          update_count y 1;)
        (fun y -> y.left) (* mover *)
        x)
    (fun x -> x.up) (* mover *)
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
  if grid.mcount = 0 then [sol]
  else begin
    let (col,count) = find_least_filled_col grid in
    if count = 0 then [sol] (* Unsuccessful. *)
    else begin
      let rows = find_covered_rows col in
      cover_reassign col;
      let sols = List.map (fun row -> 
        node_iter
          (fun x -> cover_reassign x.col_h)
          (fun x -> x.right)
          row;
        let new_sol = dlx_x (row.row :: sol) grid in
          node_iter
            (fun x -> uncover_reassign x.col_h)
            (fun x -> x.left)
            row;
         new_sol
      ) rows in
      uncover_reassign col;
      one_level_flatten sols end
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
  let knuthgrid = Utils.make_dlx_grid blank_config in
  let dlx_sol = dlx_x [] knuthgrid in
  (* TODO: Utils.map_x_to_pieces dlx_sol blank_config *)
  (false, empty_solution)
;;
