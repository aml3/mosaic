open Graphics;;
open Unix;;
open Types;;

let cell_width = 20;;
let cell_height = 20;;
let background = Graphics.white;;

let draw_configuration (config : Types.configuration) =
  let Configuration(_,Board(board)) = config in
  (* Loop over each cell in the board. Maybe there's a more OCaml-esq way to do
   * this. *)
  for i = 0 to (Array.length board) - 1 do
    let row = board.(i) in
    for j = 0 to (Array.length row) - 1 do
      (* Move the cursor to the appropriate place. We're going to assume that
       * the board begins at (0,0). If this changes in the future, then we can
       * use Graphics.rmoveto instead. *)
      Graphics.moveto (j*cell_width) (i*cell_height);
      let curr_x = Graphics.current_x () in
      let curr_y = Graphics.current_y () in
      let Cell(color) = row.(j) in 
      begin match color with
        | Some(color) -> Graphics.set_color color;
        | None -> Graphics.set_color background;
      end;
      Graphics.fill_rect curr_x curr_y cell_width cell_height; (* Fill *)
      Graphics.set_color Graphics.black;
      Graphics.draw_rect curr_x curr_y cell_width cell_height; (* Border *)
    done;
  done
;;

let draw () =
  try 
    let display = Unix.getenv "DISPLAY" in
    Graphics.open_graph display;
    let default_cell = Cell(None) in
    let empty_board = Array.make_matrix 10 20 default_cell in
    let config = Configuration([], Board(empty_board)) in
    draw_configuration config;
    let continue = ref true in
    while !continue do
      let status = Graphics.wait_next_event [Key_pressed] in
      match status.key with
      | 'q' -> continue := false
      | 'j' -> ()
      | 'k' -> ()
      | _ -> ()
    done;
  with Not_found -> prerr_endline "Error: No display"
;;

draw ();;
