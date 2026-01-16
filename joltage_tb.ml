open Base
open Stdio
open Hardcaml
open Hardcaml.Bits


let result = ref 0

(* Function that reads input file into list of lists of integers*)
let read_digit_lists (filename : string) : int list list =
  let channel = In_channel.create filename in
  let rec read_lines acc =
    try
      let line = In_channel.input_line_exn channel in
      let digits =
        line
        |> String.to_list
        |> List.map ~f:(fun c -> Char.to_int c - Char.to_int '0')
      in
      read_lines (digits :: acc)
    with End_of_file ->
      In_channel.close channel;
      List.rev acc
  in
  read_lines []

(* Function that iterates over pairs of two integers *)
let rec iter_pairs ~f = function
  | [] | [_] -> ()
  | x :: (y :: _ as rest) ->
      f x y;
      iter_pairs ~f rest

let run_testbench data_input () =
  let module Sim = Cyclesim.With_interface (Joltage.I) (Joltage.O) in
  let sim = Sim.create Joltage.create in

  (* Initialise clear as low *)
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  (* Set din to 0 to trigger reset for result register *)
  inputs.clear := Bits.vdd;
  inputs.din := Bits.zero 8;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  Stdio.printf "Starting Joltage Test...\n";


  List.iter data_input ~f:(fun current_line ->
    iter_pairs current_line ~f:(fun i j ->
      let i_bits = Bits.of_int_trunc ~width:4 i in
      let j_bits = Bits.of_int_trunc ~width:4 j in

      inputs.din := concat_msb [i_bits; j_bits];
      Cyclesim.cycle sim;

      (* Print statement to see state of register at current iteration i, j *)
      (* let firstDigit = Bits.to_int_trunc !(outputs.d1) in *)
      (* let secondDigit = Bits.to_int_trunc !(outputs.d2) in *)
      (* Stdio.printf "Data %d%d -> (d1:%d) (d2:%d)\n" i j firstDigit secondDigit *)
    );

    let digitOne = Bits.to_int_trunc !(outputs.d1) in
    let digitTwo = Bits.to_int_trunc !(outputs.d2) in
    
    (* Print statements to see Joltage for the line we just processed *)
    (* Stdio.printf "Joltage: %d%d\n" digitOne digitTwo; *)

    result := !result + (digitOne * 10) + digitTwo;
 

    (* Clear register at end of every input line *)
    inputs.din := Bits.zero 8;
    inputs.clear := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.clear := Bits.gnd;
  )

let () =
  let argv = Sys.get_argv () in
  let filename =
    if Array.length argv = 2 then argv.(1)
    else (
      Stdio.eprintf "Error: Invalid input, Usage: dune exec ./joltage_tb.exe -- <data>\n";
      Stdlib.exit 1
    )
  in
  let my_input = read_digit_lists filename in
  run_testbench my_input ();
  Stdio.printf "Final total Joltage: %d\n" !result
