import gleam/erlang/file
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import utils/grid

pub type Schematic =
  grid.Grid(String)

pub type NumberCells =
  List(grid.Entry(String))

pub fn is_digit(char: String) -> Bool {
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

pub fn is_symbol(char: String) -> Bool {
  case char {
    "." -> False
    c -> !is_digit(c)
  }
}

pub fn number_is_adjacent_to(
  schematic: Schematic,
  number_cells: NumberCells,
  predicate: fn(grid.Entry(String)) -> Bool,
) -> Bool {
  number_cells
  |> list.flat_map(fn(cell) { grid.adjacents_with_diagonals(schematic, cell.1) })
  |> list.any(predicate)
}

pub fn is_part_number(schematic: Schematic, number_cells: NumberCells) -> Bool {
  number_is_adjacent_to(
    schematic,
    number_cells,
    fn(adj_cell) { is_symbol(adj_cell.0) },
  )
}

pub fn cells_to_number(number_cells: NumberCells) -> Result(Int, Nil) {
  number_cells
  |> list.map(pair.first)
  |> string.concat()
  |> int.base_parse(10)
}

pub fn find_numbers(schematic: Schematic) -> List(NumberCells) {
  schematic
  |> grid.iterate()
  // split into contiguous pieces
  |> iterator.chunk(fn(it) {
    case is_digit(it.0) {
      // To make sure number pieces don't span multiple lines
      True -> { it.1 }.0
      False -> -1
    }
  })
  // exclude non-number contiguous pieces
  |> iterator.filter(fn(piece) {
    piece
    |> list.first()
    |> result.unwrap(#(".", #(0, 0)))
    |> pair.first()
    |> is_digit()
  })
  |> iterator.to_list()
}

pub fn part1(schematic: Schematic) -> Result(Int, Nil) {
  schematic
  |> find_numbers()
  // check if they are part numbers
  |> list.filter(is_part_number(schematic, _))
  // Calculate output
  |> list.try_map(cells_to_number)
  |> result.map(int.sum)
}

pub fn part2(schematic: Schematic) -> Result(Int, Nil) {
  let part_numbers =
    schematic
    |> find_numbers()
    |> list.filter(is_part_number(schematic, _))

  schematic
  |> grid.iterate()
  |> iterator.filter(fn(cell) { cell.0 == "*" })
  |> iterator.map(fn(gear_cell) {
    let predicate = fn(adj_cell) { adj_cell == gear_cell }
    let adjacent_part_numbers =
      part_numbers
      |> list.filter(fn(number_cells) {
        // performance optimization: immediately exclude numbers that are not in an adjacent row
        let assert [#(_, #(number_row, _)), ..] = number_cells
        number_row >= { gear_cell.1 }.0 - 1 && number_row <= { gear_cell.1 }.0 + 1 && number_is_adjacent_to(
          schematic,
          number_cells,
          predicate,
        )
      })
    #(gear_cell, adjacent_part_numbers)
  })
  |> iterator.filter(fn(candidate) { list.length(candidate.1) == 2 })
  |> iterator.to_list()
  |> list.try_map(fn(candidate) {
    candidate.1
    |> list.try_map(cells_to_number)
    |> result.map(int.product)
  })
  |> result.map(int.sum)
}

pub fn main() {
  let assert Ok(contents) = file.read("/dev/stdin")
  let schematic = grid.from_string(contents)
  let assert Ok(part1_sol) = part1(schematic)
  io.println("Part 1: " <> int.to_string(part1_sol))
  let assert Ok(part2_sol) = part2(schematic)
  io.println("Part 2: " <> int.to_string(part2_sol))
}
