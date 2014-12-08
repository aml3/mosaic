open Parse;;
open Solve;;
open Display;;
open Printf;;

Printf.printf "Starting tiling\n";;
let inputfile = Array.get Sys.argv 1;;
let (tiles, desired_board) = Parse.read_input inputfile;;
Printf.printf "Used:%s" inputfile;;
