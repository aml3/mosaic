open Graphics;;
open Unix;;
open Types;;

let cell_width = 20;;
let cell_height = 20;;

(*
 * Draw a cell as a rectangle at the current coordinates plus the (x,y) offset.
 *)
let draw_cell (c : Types.cell * int * int) =
  let (color, x_offset, y_offset) = c in
  let curr_x = (x_offset*cell_width) + Graphics.current_x () in
  let curr_y = (y_offset*cell_height) + Graphics.current_y () in
  Graphics.set_color color;
  Graphics.fill_rect curr_x curr_y cell_width cell_height;
  Graphics.set_color Graphics.black;
  Graphics.draw_rect curr_x curr_y cell_width cell_height;
;;

let draw_tile (t : Types.tile) (x : int) (y : int) =
  Graphics.moveto (x*cell_width) (y*cell_height);
  List.map draw_cell t
;;

let draw_configuration (config : Types.configuration) =
  List.map (fun (a,b,c) -> draw_tile a b c) config
;;

Graphics.open_graph ":0.0";; (* change this later *)
let config =
  [([(0xFF0000, 0, 0)], 0, 0);
   ([(0x00FF00, 0, 0)], 1, 0)
  ];;
draw_configuration config;;
Unix.sleep 3;;
