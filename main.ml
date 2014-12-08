open Types;;
open Parse;;
open Solve;;
open Display;;
open Printf;;

let filename = Sys.argv.(1);; 
let (tiles, board) = Parse.read_input filename;;

print_endline "(* Printing tiles *)";;
List.iter (fun tile -> print_endline (Utils.string_of_tile tile)) tiles;;

let Board(largest_tile) = board;;
let blank_board = Array.map (fun board_row -> Array.map (fun board_cell ->
    match board_cell with Missing -> Missing | _ -> Empty) board_row )
    largest_tile;;
let largest_tile = Tile(largest_tile);;

print_endline "(* Printing board *)";;
print_endline (Utils.string_of_tile largest_tile);;

print_endline "(* Printing blank board *)";;
print_endline (Utils.string_of_tile (Tile blank_board));;

print_endline "(* Solving *)";;
let config = Configuration(tiles, Board(blank_board));;
match Solve.solve config with
| (true, _) -> print_endline "Found solution";
| (false, _) -> print_endline "No solutions found";
;;

Display.draw_display config;;
