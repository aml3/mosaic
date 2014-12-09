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
