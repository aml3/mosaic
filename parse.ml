open Types
open Batteries
open Array
open Hashtbl
open Random

(* Utility function to read the entire input file into a grid *)
let make_grid (input_file : in_channel) : char array array =
  let raw_lines = input_list input_file in
  Array.of_list (List.map (fun line -> Array.of_list (String.to_list line)) raw_lines)
  ;;

(* Utility function to extract a column of the grid *)
let get_column (grid : 'a array array) (col_idx : int) : 'a array =
  let res_list = Array.fold_left
    (fun acc elem -> acc @ [elem.(col_idx)])
    [] grid
    in
    Array.of_list res_list
  ;;

(* Utility function to transpose the grid, without caring about it being ragged *)
let transpose (grid : 'a array array) (default_val : 'a): 'a array array =
  let col_lengths = Array.map (fun subarr -> Array.length subarr) grid in
  let longest_col = Array.max col_lengths in
  let result = Array.make longest_col (Array.make 0 default_val) in
  Array.iter
    (fun row -> Array.iteri
          (fun c_idx col -> result.(c_idx) <- (Array.append (result.(c_idx)) (Array.singleton col)))
          row)
    grid;
  result
  ;;

(* Utility function to ensure unique coloring *)
let update_colors (colors : (char, Types.cell) Hashtbl.t) (new_elem : char) =
  let (r, g, b) = (Random.int 256, Random.int 256, Random.int 256) in
  let color = (r lsl 16) + (g lsl 8) + b in
  Hashtbl.add colors new_elem (Filled(color));
  ;;

(* Utility function to make an individual tile *)
let make_tile (shape : char array array) (colors : (char, Types.cell) Hashtbl.t) : (tile * ((char, Types.cell) Hashtbl.t)) =
  let result = Array.make (Array.length shape) (Array.make 0 (Filled 0)) in
  Array.iteri
    ( fun idx elem ->
          ( let row = Array.make (Array.length elem) (Filled 0) in
            Array.iteri
              ( fun r_idx r_elem -> row.(r_idx) <-
                    (( if not (Hashtbl.mem colors r_elem)
                       then update_colors colors r_elem);
                     (Hashtbl.find colors r_elem)))
              elem;
            result.(idx) <- row;))
  shape;
    (Tile result, colors)
  ;;

(* Utility function to make tiles from the list of arrays. Mostly just mapping chars to ints *)
let rec make_tiles (shapes : char array array list) (colors : (char, Types.cell) Hashtbl.t) : tile list =
  match shapes with
  | shape :: rest ->
    ( let (new_tile, colors) = make_tile shape colors in
      new_tile :: (make_tiles rest colors))
  | []            -> []
  ;;

(*
 * Utility function to parse an array of arrays representing the initial input
 * into a list of valid tiles and the desired end board.
 *)
let parse_grid (raw_grid : char array array) : ((tile list) * board) =
  (* Get the grid's transpose *)
  let trans_grid = transpose raw_grid '0' in
  (* Get the rows which contain no shape parts *)
  let blank_cols = Array.fold_lefti
    (fun acc idx elem -> if Array.for_all (fun x -> x = ' ') elem
                            then acc @ [idx]
                            else acc)
    []
    trans_grid
    in
  let blank_cols_arr = Array.of_list blank_cols in
  let bounds = Array.fold_lefti
    (fun acc idx elem -> if idx + 1 < (Array.length blank_cols_arr) &&
                         blank_cols_arr.(idx + 1) > (elem + 1)
                      then (elem, blank_cols_arr.(idx + 1)) :: acc
                      else acc)
    []
    blank_cols_arr
    in
  let bounds = bounds @ [(Array.get (Array.right blank_cols_arr 1) 0, (Array.length trans_grid))] in
  (* Get the separate shapes *)
  let tile_arrays = List.map
    (fun (start, finish) -> Array.sub trans_grid (start + 1) (finish - start - 1))
    bounds
    in
  (* Make tiles *)
  let color_table = Hashtbl.create 20 in
  Hashtbl.add color_table ' ' Empty;
  let tile_set = make_tiles tile_arrays color_table in
  let dimensions = List.map
    (fun (Tile elem) -> Array.fold_left (fun acc r_elem -> acc + (Array.length r_elem)) 0 elem)
    tile_set
    in
  let largest_size = List.max dimensions in
  let (largest_size_idx, _) = List.findi (fun _ x -> x = largest_size) dimensions in
  let (_, Tile largest_tile) = List.findi (fun idx x -> idx = largest_size_idx) tile_set in
  let tile_set = List.remove_at largest_size_idx tile_set in
  (tile_set, Board largest_tile)
  ;;

(*
 * Interface function to read in input from a provided file, parse into
 * the defined data structures, and return the set of possible tiles and the
 * desired final configuration.
 *)
let read_input (file_name : string) : ((tile list) * (board)) =
  Random.self_init ();
  let input_vals = Pervasives.open_in file_name in
  let input_grid = make_grid input_vals in
  Pervasives.close_in input_vals;
  parse_grid input_grid
  ;;
