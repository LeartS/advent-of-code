import gleam/int
import gleam/io
import gleam/iterator
import utils/io as io_utils
import utils/grid as grid

pub fn part1(input: String) -> Int {
  let grid = grid.from_string(input)

  let assert #(_, _, load) =
    grid
    |> grid.iterate_by_columns()
    |> iterator.fold(
      // #(last stable rock in column, total)
      from: #(-1, 0, 0),
      with: fn(acc, cell) {
        let #(terminal_row, column, load) = acc
        let grid.Cell(value: value, coords: #(row, col)) = cell
        let terminal_row = case col > column {
          True -> -1
          False -> terminal_row
        }
        case value {
          "O" -> #(
            terminal_row + 1,
            col,
            load + grid.size(grid).0 - { terminal_row + 1 },
          )
          "." -> #(terminal_row, col, load)
          "#" -> #(row, col, load)
        }
      },
    )

  load
}

pub fn part2(input: String) -> Int {
  todo
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
