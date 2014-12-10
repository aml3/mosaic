open Types
open Utils
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

(* Constructor function to make tiles from the list of arrays. Mostly just mapping chars to ints *)
let rec make_tiles (shapes : char array array list) (colors : (char, Types.cell) Hashtbl.t) : tile list =
  match shapes with
  | shape :: rest ->
    ( let (new_tile, colors) = make_tile shape colors in
      new_tile :: (make_tiles rest colors))
  | []            -> []
  ;;

(* Utility function to find the list of blank rows in the passed matrix *)
let find_blank (grid : 'a array array) (blank_val : 'a) : int list =
  Array.fold_lefti
    (fun acc idx elem -> if Array.for_all (fun x -> x = blank_val) elem
                            then acc @ [idx]
                            else acc)
    []
    grid
  ;;

let make_bounds (boundary_values : int list) (extremum : int): (int * int) list =
  if List.length boundary_values = 0
  then []
  else (
  let boundary_values_arr = Array.of_list boundary_values in
  let bounds = Array.fold_lefti
    (fun acc idx elem -> if idx + 1 < (Array.length boundary_values_arr) &&
                         boundary_values_arr.(idx + 1) > (elem + 1)
                      then (elem, boundary_values_arr.(idx + 1)) :: acc
                      else acc)
    []
    boundary_values_arr
    in
  bounds @ [(Array.get (Array.right boundary_values_arr 1) 0, extremum)]
  )
  ;;

(* Utility function to subdivide grid into tile chunks *)
let chunk_by_bounds (bounds : (int * int) list) (grid : char array array) : char array array list =
  List.map
    (fun (start, finish) -> Array.sub
      grid
      (if start > 0 then start + 1 else 0)
      (if start > 0 || finish = Array.length grid then
        (if finish - start > 0 then finish - start - 1 else 0)
        else finish))
    bounds
  ;;

(*
 * Function to parse an array of arrays representing the initial input
 * into a list of valid tiles and the desired end board.
 *)
let parse_grid (raw_grid : char array array) : ((tile list) * board) =
  (* Get the grid's transpose *)
  let trans_grid = transpose raw_grid '0' in
  (* Get the rows which contain no shape parts *)
  let blank_cols = find_blank trans_grid ' ' in
  let col_bounds = make_bounds blank_cols (Array.length trans_grid) in
  (* Get the separate shapes *)
  let tile_arrays = chunk_by_bounds col_bounds trans_grid in
  let tile_arrays = List.map (fun x -> transpose x '0') tile_arrays in
  let color_table = Hashtbl.create 20 in
  Hashtbl.add color_table ' ' Empty;
  let tile_set = make_tiles tile_arrays color_table in
  List.iter (fun x -> Printf.printf "%s\n---------\n" (Utils.string_of_tile x)) tile_set;
  let tile_chunks = List.map
    (fun subarr ->
      ( let blank_rows = find_blank subarr ' ' in
        let row_bounds = make_bounds blank_rows (Array.length subarr) in
        let row_bounds = (0, (if blank_rows <> [] then List.min blank_rows else Array.length subarr)) :: row_bounds in
        List.iter (fun (x,y) -> Printf.printf "(%d,%d) " x y) row_bounds;
        Printf.printf "\n";
        if List.length row_bounds > 1
        then chunk_by_bounds row_bounds subarr
        else [subarr]
      )
    )
    tile_arrays
  in
  let tile_chunks = List.concat tile_chunks in
  (* Make tiles *)
  let color_table = Hashtbl.create 20 in
  Hashtbl.add color_table ' ' Empty;
  let tile_set = make_tiles tile_chunks color_table in
  let dimensions = List.map
    (fun (Tile elem) -> Array.fold_left (fun acc r_elem -> acc + (Array.length r_elem)) 0 elem)
    tile_set
    in
  let largest_size = List.max dimensions in
  let (largest_size_idx, _) = List.findi (fun _ x -> x = largest_size) dimensions in
  let (_, Tile largest_tile) = List.findi (fun idx x -> idx = largest_size_idx) tile_set in
  let tile_set = List.remove_at largest_size_idx tile_set in
  let tile_set = List.filter (fun (Tile x) -> Array.length x > 0) tile_set in
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
