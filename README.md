# Advent of FPGA - Day 3 Part 1

My submission to the [Advent of FPGA](https://adventofcode.com/) challenge using **HardCaml**.

## Problem Overview

Day 3 involves processing an input stream of digits to find the **highest joltage** for each row. The challenge is to extract two digits and concatenate them to form the largest possible two-digit number, with the constraint that the relative order of digits in the original sequence must be preserved. The final answer is the sum of all joltages across every row.

## Project Structure

```
├── joltage.ml       # HardCaml circuit: max digit tracker
├── joltage_tb.ml    # Testbench: reads input, runs simulation
├── data.txt         # Input data file
├── dune             # Build configuration
└── dune-project     # Dune project metadata
```

## Environment

- **OCaml**: `5.2.0+ox`
- **Dune**: `3.20.2`
- **Dependencies**: `base`, `hardcaml`, `stdio`, `ppx_hardcaml`, `ppx_jane`

## Building & Running

```bash
# Build the project
dune build

# Run the testbench with your input file
dune exec ./joltage_tb.exe -- data.txt
```

## ⚠️ Warning: Carriage Returns

If your input file was created or edited on Windows, it may contain carriage return characters (`\r`) that can cause parsing issues. To remove them, run the following command:

```bash
sed -i 's/\r$//' data.txt
```

## License

This project is open source under the [MIT License](LICENSE).
