import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import utils/grid
import utils/io as io_utils

pub type Field =
  grid.Grid(String)

pub type Loop =
  List(grid.Cell(String))

fn corner_out_direction(
  in_direction: grid.Direction,
  tile: String,
) -> Result(grid.Direction, Nil) {
  case in_direction, tile {
    grid.Down, "F" -> Ok(grid.Right)
    grid.Down, "7" -> Ok(grid.Left)
    grid.Down, "|" -> Ok(grid.Up)
    grid.Left, "J" -> Ok(grid.Up)
    grid.Left, "7" -> Ok(grid.Down)
    grid.Left, "-" -> Ok(grid.Right)
    grid.Up, "L" -> Ok(grid.Right)
    grid.Up, "J" -> Ok(grid.Left)
    grid.Up, "|" -> Ok(grid.Down)
    grid.Right, "L" -> Ok(grid.Up)
    grid.Right, "F" -> Ok(grid.Down)
    grid.Right, "-" -> Ok(grid.Left)
    _, _ -> Error(Nil)
  }
}

pub fn flow(
  field: grid.Grid(String),
  coords: grid.Coord,
  in_direction: grid.Direction,
) -> iterator.Iterator(grid.Cell(String)) {
  iterator.unfold(
    from: #(coords, in_direction),
    with: fn(acc) {
      let #(c, d) = acc
      let assert Ok(corner_out_direction) =
        corner_out_direction(d, grid.get(field, c))
      let assert Ok(new_cell_coords) = grid.move(field, c, corner_out_direction)
      iterator.Next(
        grid.Cell(
          coords: new_cell_coords,
          value: grid.get(field, new_cell_coords),
        ),
        #(new_cell_coords, grid.opposite_direction(corner_out_direction)),
      )
    },
  )
}

pub fn find_loop(field: Field) -> Loop {
  let assert Ok(starting_cell) =
    field
    |> grid.iterate()
    |> iterator.find(fn(cell) { cell.value == "S" })

  let assert loop_adj =
    field
    |> grid.adjacents_without_diagonals(starting_cell.coords)
    |> list.find(fn(adj) {
      let in_direction = grid.direction(adj.cell.coords, starting_cell.coords)
      case
        corner_out_direction(in_direction, grid.get(field, adj.cell.coords))
      {
        Error(Nil) -> False
        _direction -> True
      }
    })
  let assert Ok(grid.Adjacent(direction: direction, cell: cell)) = loop_adj

  field
  |> flow(cell.coords, grid.opposite_direction(direction))
  |> iterator.take_while(fn(cell) { cell.value != "S" })
  |> iterator.to_list()
  |> list.prepend(cell)
  |> list.prepend(starting_cell)
  |> fix_loop()
}

fn fix_loop(loop: Loop) -> Loop {
  let assert [s, after_s, ..rest] = loop
  let assert Ok(before_s) = list.last(loop)
  [
    grid.Cell(..s, value: infer_corner(before_s.coords, after_s.coords)),
    after_s,
    ..rest
  ]
}

fn infer_corner(before_coords, after_coords) -> String {
  case grid.direction(before_coords, after_coords) {
    grid.Up | grid.Down -> "|"
    grid.Left | grid.Right -> "-"
    grid.UpLeft -> "7"
    grid.UpRight -> "F"
    grid.DownLeft -> "J"
    grid.DownRight -> "L"
    grid.Zero -> panic as "S prev/next loop cells have invalid coordinates"
  }
}

fn row_tiles_enclosed_in_loop(
  field: Field,
  loop: Loop,
  row: Int,
) -> List(grid.Cell(String)) {
  let loop_dict =
    loop
    |> list.map(fn(cell) { #(cell.coords, cell.value) })
    |> dict.from_list()

  let #(_, _, enclosed_cells) =
    list.fold(
      over: list.range(from: 0, to: grid.size(field).1 - 1),
      from: #("F", True, []),
      with: fn(acc, col) {
        let #(last_corner, outside, enclosed_cells) = acc
        case dict.get(loop_dict, #(row, col)), last_corner, outside {
          Error(_), _, True -> #(last_corner, outside, enclosed_cells)
          Error(_), _, False -> #(
            last_corner,
            outside,
            [grid.cell_at(field, #(row, col)), ..enclosed_cells],
          )
          Ok("F"), _, _ -> #("F", !outside, enclosed_cells)
          Ok("L"), _, _ -> #("L", !outside, enclosed_cells)
          Ok("7"), "F", _ -> #("F", !outside, enclosed_cells)
          Ok("7"), "L", _ -> #("F", outside, enclosed_cells)
          Ok("J"), "F", _ -> #("F", outside, enclosed_cells)
          Ok("J"), "L", _ -> #("F", !outside, enclosed_cells)
          Ok("-"), _, _ -> acc
          Ok("|"), _, _ -> #("F", !outside, enclosed_cells)
        }
      },
    )
  list.reverse(enclosed_cells)
}

fn tiles_enclosed_in_loop(field: Field, loop: Loop) -> List(grid.Cell(String)) {
  list.flat_map(
    over: list.range(from: 0, to: grid.size(field).0 - 1),
    with: row_tiles_enclosed_in_loop(field, loop, _),
  )
}

pub fn part1(input: String) -> Int {
  let field = grid.from_string(input)
  let loop = find_loop(field)

  list.length(loop) / 2 + 1
}

pub fn part2(input: String) -> Int {
  let field = grid.from_string(input)
  let loop = find_loop(field)

  field
  |> tiles_enclosed_in_loop(loop)
  |> list.length()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
