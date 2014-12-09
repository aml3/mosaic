open Types;;
open Utils;;

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
  brute_force blank_config empty_solution
;;
