open Types;;
open Parse;;
open Solve;;
open Display;;
open Printf;;

let filename = Sys.argv.(1);; 
let (tiles, board) = Parse.read_input filename;;
let reflect_str = if Array.length Sys.argv > 2 then Sys.argv.(2) else "no reflect";;

print_string "(* Printing ";;
print_int (List.length tiles);;
print_endline " tiles *)";;
List.iter (fun tile -> print_endline (Utils.string_of_tile tile)) tiles;;

let Board(largest_tile) = board;;
let blank_board = Array.map (fun board_row -> Array.map (fun board_cell ->
    match board_cell with Missing -> Missing | _ -> Empty) board_row )
    largest_tile;;
let largest_tile = Tile(largest_tile);;

print_endline "(* Printing board *)";;
print_endline (Utils.string_of_tile largest_tile);;

let reflect = if reflect_str = "--reflect" then true else false;;
print_endline (if reflect then "(* Reflections enabled *)" else "(* Reflections
disallowed *)");;
print_endline "(* Solving *)";;
let config = Configuration(tiles, Board(blank_board));;
match Solve.solve config reflect with
| (false, _) -> print_endline "No solutions found";
| (true, solution) -> 
    print_endline "Found solution";
    Display.draw_display solution (Board(blank_board))
;;
