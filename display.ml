open Graphics;;
open Unix;;
open Types;;
open Utils;;

let cell_width = 20;;
let cell_height = 20;;
let empty_color = Graphics.white;;
let missing_color = Graphics.black;;

let undraw_array (arr : cell array array) =
  Array.iteri (fun i row -> 
    Array.iteri (fun j _ ->
      begin match row.(j) with
      | Filled _ -> begin
        let curr_x = Graphics.current_x () in
        let curr_y = Graphics.current_y () in
        Graphics.set_color empty_color;
        Graphics.fill_rect curr_x curr_y cell_width cell_height;
        Graphics.set_color Graphics.black;
        Graphics.draw_rect curr_x curr_y cell_width cell_height; end
      | _ -> () (* Shouldn't clear empty or missing cells. *) end;
      Graphics.rmoveto cell_width 0;
    ) row;
    Graphics.rmoveto 0 (-1*cell_height);
    Graphics.moveto 0 (Graphics.current_y ());
  ) arr
;;

let undraw_tile (tile : Types.tile) = 
  let Tile(tile) = tile in 
  undraw_array tile
;;

let draw_array (arr : cell array array)
               (flag : bool) (* Redraw previous contents. *) =
  Array.iteri (fun i row ->
    Array.iteri (fun j _ ->
      let curr_x = Graphics.current_x () in
      let curr_y = Graphics.current_y () in
      let cell = row.(j) in
      let draw_cell () =
        Graphics.fill_rect curr_x curr_y cell_width cell_height; (* Fill *)
        Graphics.set_color Graphics.black;
        Graphics.draw_rect curr_x curr_y cell_width cell_height; (* Border *)
      in
      begin match cell with
        | Filled(color) -> begin
          Graphics.set_color color;
          draw_cell (); end
        | Empty -> 
            if flag then begin Graphics.set_color empty_color; draw_cell() end
        | Missing -> 
            if flag then begin Graphics.set_color missing_color; draw_cell() end
      end;
      Graphics.rmoveto cell_width 0;
    ) row;
    Graphics.rmoveto 0 (-1*cell_height);
    Graphics.moveto 0 (Graphics.current_y ());
  ) arr
;;

let draw_tile (tile : Types.tile) (flag : bool) =
  let Tile(tile) = tile in
  draw_array tile flag
;;

let draw_board (board : Types.board) (flag : bool) =
  let Board(board) = board in
  draw_array board flag
;;

let draw_configuration (config : Types.configuration) (flag : bool) =
  let Configuration(_,board) = config in
  draw_board board flag
;;

(* 
 * Arrays treat (0,0) as the top left, and graphics treats (0,0) as the bottom
 * left. We want to reflect all coordinates across the y-axis. 
 *)
let remap ((x,y) : (int * int)) (dim_y : int) =
  (x,dim_y - y)
;;
    
let draw_display (solution : Types.solution) (board : Types.board) =
  try
    let display = Unix.getenv "DISPLAY" in
    Graphics.open_graph display;
    (* First draw a blank board. *)
    let Board(board) = board in
    let dim_y = Array.length board - 1 in
    Graphics.moveto 0 (dim_y*cell_height);
    draw_array board true;
    (* Then draw the tiles. *)
    let Solution(placements) = solution in
    (*List.iter (fun (tile, coors) ->
      let _ = Graphics.wait_next_event [Key_pressed] in
      let (x,y) = remap coors dim_y in
      Graphics.moveto (x*cell_width) (y*cell_height);
      draw_tile tile false;) placements;*)
    let opt_hd lst = match lst with [] -> None | hd :: _ -> Some(hd) in
    let scroll left right = (* Appends the first item in left to right. *)
      match left with
      | [] -> (left, right) (* No where to scroll. *)
      | hd :: tl -> (tl, hd :: right) in
    let rec loop left right continue = 
      if not continue then ()
      else
        let status = Graphics.wait_next_event [Key_pressed] in
        match status.key with
        | 'q' -> loop [] [] false
        | 'h' (* previous solution *) -> ()
        | 'l' (* next solution *) -> ()
        | 'k' (* previous tile *) ->
          (* Remove tile, scroll back, and then draw the next tile. *)
          let current = opt_hd left in begin
          match current with 
          | None -> ()
          | Some(tile, coors) ->
              let (x,y) = remap coors dim_y in
              Graphics.moveto (x*cell_width) (y*cell_height);
              undraw_tile tile;

          end;
          let (left, right) = scroll left right in
          loop left right true
        | 'j' (* next tile *) -> 
          (* Scroll and then draw. *)
          let current = opt_hd right in
          begin match current with
          | None -> ()
          | Some(tile, coors) ->
            let (x,y) = remap coors dim_y in
            Graphics.moveto (x*cell_width) (y*cell_height);
            draw_tile tile false; end;
          let (right, left) = scroll right left in
          loop left right true 
        | _ -> loop left right true in
    loop [] placements true
  with Not_found -> prerr_endline "Error: No display"
;;
