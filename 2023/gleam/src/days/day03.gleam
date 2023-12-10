import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import utils/io as io_utils
import utils/grid

type Schematic =
  grid.Grid(String)

type ContiguousCells =
  List(grid.Cell(String))

fn is_digit(char: String) -> Bool {
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn is_symbol(char: String) -> Bool {
  case char {
    "." -> False
    c -> !is_digit(c)
  }
}

fn number_is_adjacent_to(
  schematic: Schematic,
  number_cells: ContiguousCells,
  predicate: fn(grid.Cell(String)) -> Bool,
) -> Bool {
  number_cells
  |> list.flat_map(fn(cell) {
    grid.adjacents_with_diagonals(schematic, cell.coords)
  })
  |> list.any(fn(adj) { predicate(adj.cell) })
}

fn is_part_number(schematic: Schematic, number_cells: ContiguousCells) -> Bool {
  number_is_adjacent_to(
    schematic,
    number_cells,
    fn(adj_cell) { is_symbol(adj_cell.value) },
  )
}

fn cells_to_number(number_cells: ContiguousCells) -> Result(Int, Nil) {
  number_cells
  |> list.map(fn(cell) { cell.value })
  |> string.concat()
  |> int.base_parse(10)
}

fn is_number_cells(piece: ContiguousCells) -> Bool {
  let assert Ok(grid.Cell(value: value, ..)) = list.first(piece)
  is_digit(value)
}

fn find_numbers(schematic: Schematic) -> List(ContiguousCells) {
  schematic
  |> grid.iterate()
  // split into contiguous pieces
  |> iterator.chunk(fn(cell) {
    case is_digit(cell.value) {
      // To make sure number pieces don't span multiple lines
      True -> cell.coords.0
      False -> -1
    }
  })
  // exclude non-number contiguous pieces
  |> iterator.filter(is_number_cells)
  |> iterator.to_list()
}

pub fn part1(input: String) -> Int {
  let schematic = grid.from_string(input)

  schematic
  |> find_numbers()
  // check if they are part numbers
  |> list.filter(is_part_number(schematic, _))
  // Calculate output
  |> list.try_map(cells_to_number)
  |> result.map(int.sum)
  |> result.unwrap(-1)
}

pub fn part2(input: String) -> Int {
  let schematic = grid.from_string(input)
  let part_numbers =
    schematic
    |> find_numbers()
    |> list.filter(is_part_number(schematic, _))

  schematic
  |> grid.iterate()
  |> iterator.filter(fn(cell) { cell.value == "*" })
  |> iterator.map(fn(gear_cell) {
    let predicate = fn(adj_cell) { adj_cell == gear_cell }
    let adjacent_part_numbers =
      part_numbers
      |> list.filter(fn(number_cells) {
        // performance optimization: immediately exclude numbers that are not in an adjacent row
        let assert [grid.Cell(coords: #(number_row, _), ..), ..] = number_cells
        number_row >= { gear_cell.coords }.0 - 1 && number_row <= {
          gear_cell.coords
        }.0 + 1 && number_is_adjacent_to(schematic, number_cells, predicate)
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
  |> result.unwrap(-1)
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
