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

let eqclass_of_tile (tile : Types.tile) =
  let eqclass = ref [] in
  for i = 0 to 3 do (* number of rotations *)
    let rotated_tile = repeat rotate_tile_cw tile i in
    for j = 0 to 1 do (* number of reflections *)
      let reflected_tile = repeat reflect_tile tile j in
      eqclass := reflected_tile :: !eqclass;
    done;
  done;
  !eqclass
;;

let empty_node () = 
  let rec node = {
   right = node; 
   up = node; 
   down = node; 
   col_h = node; 
   row = 0; 
   count = 0 } in node
;;

let indices_of_tile (tile : Types.tile) =
  let indices = ref [] in
  Array.iteri (fun i row ->
    Array.iteri (fun j e -> 
      match e with 
      | Filled _ -> indices := (j,i) :: !indices;
      | _ -> ();) row) tiles in
  !indices
;;

let rows_of_eqclass (dim_x : int)
                    (nclasses : int)
                    (eq_count : int)
                    (board : cell array array)
                    (eqclass : Types.tile list) = 
  (* For each spot on the board, filter the eqclass by tiles that can fit at
   * that spot. Note that we have to do this for every tile, since rotations may
   * not by symmetric. *)
  let rows = ref [] in
  let empty_row = Array.make dim_x None in
  Array.iteri (fun i board_row ->
    Array.iteri (fun j board_e ->
      let valid_tiles = List.filter (fun Tile(tile) ->
        valid_placement_arr tile j i board) eqclass in
      (* For each of these valid tiles, we make a new row. *)
      List.iter (fun valid_tile ->
        let eqclass_row = Array.copy empty_row in
        let indices = List.map (fun (x,y) -> (* translate the indices *)
          (x+j, y+i)) (indices_of_tile valid_tile) in
        let flat_indices = List.map (fun (x,y) -> x + y*dim_x) indices in
        (* Set each spot in the row corresponding to an index to 1 in the
         * equivalence class's row. *)
        List.iteri(fun index -> 
          eqclass_row.(nclasses+index) <- Some (empty_node ())) flat_indices;
        eqclass_row.(eq_count) <- Some(empty_node ());
        rows := eqclass_row :: !rows;
      ) tiles;
    ) board_row;
  ) board;
  !rows
;;

let make_dlx_grid (config : Types.configuration) =
  let Configuration(tiles, board) = config in
  (* Make an equivalence class for each tile. *)
  let eqclasses = List.map (eqclass_of_tile) tiles in
  (* These equivalence classes will become the rows in our dlx table. For each
   * equivalence class, we need to try placing it in every position on the grid.
   * Each new placement gives another row.
   *
   * Start by making a large matrix for the dlx algorthim. We'll convert it to a
   * sparse matrix later. *)
  let num_tiles = List.length tiles in
  let Board(grid) = board in
  let first_row = grid.(0) in
  let grid_size = (Array.length grid) * (Array.length first_row) in
  let dim_x = (num_tiles + grid_size) in
  let eq_count = ref -1 in
  let rows_list = List.map (fun eqclass ->
    let eq_count = !eq_count + 1 in
    rows_of_eqclass dim_x nclasses eq_count board eqclass) eqclasses in
  let matrix = Array.of_list rows_list in
  (* Set the row for each node. *)
  Array.iteri (fun i row ->
    Array.iteri (fun _ e ->
      match e with
      | None -> ()
      | Some(node) -> node.row = i;
    ) row
  ) matrix;
  (* Now, we have a large array and want to compress it to a sparse one. *)
  Array.iteri (fun i row -> (* Link across each row. *)
    let nonempty_entries = Array.filter ((<>) None) row in
    let num_nonempties = ref (Array.len nonempty_entries) in
    (* Start with the previous node being the last node in the row. *)
    let prev = ref (nonempty_entries.(!num_nonempties - 1)) in
    Array.iteri (fun _ r_e ->
      r_e.left = !prev;
      !prev.right = r_e;
      prev := r_e;
    ) nonempty_entries;
  ) matrix;
  (* Link columns. *)
  for j = 0 to (dim_x-1) do
    let col = Array.fold_right (fun (_, row) acc -> row.(j) :: acc) matrix [] in
    let nonempty_entries = List.filter ((<>) None) col in
    (* TODO: insert check for empty column. *)
    let prev = ref (nonempty_entries.((Array.length nonempty_entries) - 1)) in
    List.iter (fun _ c_e ->
      c_e.up = !prev;
      !prev.down = c_e;
      prev := c_e;
    ) nonempty_entries;
  done;
  (* Now filter out all the fluff. *)
  let sparse_matrix = Array.map (Array.filter ((<>) None)) matrix;
  let num_nodes = Array.fold_left (fun acc row -> 
    acc + Array.len row) 0 sparse_matrix;
  let root = sparse_matrix.(0).(0) in
  let matrix = { head = root; 
                 mcount = num_nodes; } in

  let curr = root in
  for i = 1 to (num_tiles + grid_size) do
    let temp = { matrix = matrix;
                 left = root; 
                 right = root; 
                 up = root; 
                 down = root; 
                 col_h = root; 
                 content = 0; 
                 row = 0; 
                 count = 0 } in
    ()
    (* TODO: Link temp up as the next in line, update pointers to maintain
    circularity *)
  done;
  (* TODO: Another loop to go over the tiles and add the appropriate "filled"
  nodes after the headers *)
  matrix
;;
