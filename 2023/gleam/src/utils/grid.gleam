//// Module to work with grids
////
//// This module uses a 0-based, (row, column) coordinate system.
//// For example, the following 3x4 grid (3 rows, 4 cols)
////
//// ```
//// A B C D
//// E F G H
//// I J K L
//// ```
////
//// would have size (3, 4) and the letter G would be at coordinates (1, 2)
////
////
//// Internally the grid cells are stored in an array, row-by-row, for fast indexed access.

import gleam/function
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string
import arrays
import gleam/io

// (Row, Col)
pub type Coord =
  #(Int, Int)

pub type Cell(a) {
  Cell(value: a, coords: Coord)
}

pub opaque type Grid(a) {
  Grid(size: #(Int, Int), values: arrays.Array(a))
}

pub type Direction {
  Up
  UpRight
  Right
  DownRight
  Down
  DownLeft
  Left
  UpLeft
  Zero
}

pub type Adjacent(a) {
  Adjacent(cell: Cell(a), direction: Direction)
}

pub fn from_string_with(
  contents: String,
  cell_transformer: fn(String) -> a,
) -> Grid(a) {
  let lines =
    contents
    |> string.trim()
    |> string.split("\n")
  let n_rows = list.length(lines)
  let assert Ok(n_cols) =
    lines
    |> list.first()
    |> result.map(string.length)
  let values =
    contents
    |> string.replace(each: "\n", with: "")
    |> string.to_graphemes()
    |> list.map(cell_transformer)
    |> arrays.from_list()
  Grid(size: #(n_rows, n_cols), values: values)
}

pub fn from_string(contents: String) -> Grid(String) {
  from_string_with(contents, function.identity)
}

pub fn size(grid: Grid(a)) -> #(Int, Int) {
  grid.size
}

pub fn in_bounds(grid: Grid(a), coords: Coord) -> Bool {
  let #(n_rows, n_cols) = grid.size
  let #(r, c) = coords
  r >= 0 && r < n_rows && c >= 0 && c < n_cols
}

pub fn direction(from: Coord, to: Coord) -> Direction {
  case from, to {
    #(r1, c1), #(r2, c2) if r1 < r2 && c1 < c2 -> DownRight
    #(r1, c1), #(r2, c2) if r1 < r2 && c1 == c2 -> Down
    #(r1, c1), #(r2, c2) if r1 < r2 && c1 > c2 -> DownLeft
    #(r1, c1), #(r2, c2) if r1 == r2 && c1 < c2 -> Right
    #(r1, c1), #(r2, c2) if r1 == r2 && c1 == c2 -> Zero
    #(r1, c1), #(r2, c2) if r1 == r2 && c1 > c2 -> Left
    #(r1, c1), #(r2, c2) if r1 > r2 && c1 < c2 -> UpRight
    #(r1, c1), #(r2, c2) if r1 > r2 && c1 == c2 -> Up
    #(r1, c1), #(r2, c2) if r1 > r2 && c1 > c2 -> UpLeft
  }
}

pub fn opposite_direction(direction: Direction) -> Direction {
  case direction {
    Up -> Down
    UpRight -> DownLeft
    Right -> Left
    DownRight -> UpLeft
    Down -> Up
    DownLeft -> UpRight
    Left -> Right
    UpLeft -> DownRight
    Zero -> Zero
  }
}

pub fn move(
  on grid: Grid(a),
  from from: Coord,
  towards direction: Direction,
) -> Result(Coord, Nil) {
  let #(r, c) = from
  let new = case direction {
    Up -> #(r - 1, c)
    UpRight -> #(r - 1, c + 1)
    Right -> #(r, c + 1)
    DownRight -> #(r + 1, c + 1)
    Down -> #(r + 1, c)
    DownLeft -> #(r + 1, c - 1)
    Left -> #(r, c - 1)
    UpLeft -> #(r - 1, c - 1)
    Zero -> #(r, c)
  }
  case in_bounds(grid, new) {
    True -> Ok(new)
    False -> Error(Nil)
  }
}

pub fn adjacents_without_diagonals(
  grid: Grid(a),
  coords: Coord,
) -> List(Adjacent(a)) {
  let #(row, col) = coords
  [#(row - 1, col), #(row, col - 1), #(row, col + 1), #(row + 1, col)]
  |> list.filter(in_bounds(grid, _))
  |> list.map(fn(adj_coords) {
    Adjacent(
      cell: Cell(get(grid, adj_coords), adj_coords),
      direction: direction(coords, adj_coords),
    )
  })
}

pub fn adjacents_with_diagonals(
  grid: Grid(a),
  coords: Coord,
) -> List(Adjacent(a)) {
  let #(row, col) = coords
  [
    #(row - 1, col - 1),
    #(row - 1, col),
    #(row - 1, col + 1),
    #(row, col - 1),
    #(row, col + 1),
    #(row + 1, col - 1),
    #(row + 1, col),
    #(row + 1, col + 1),
  ]
  |> list.filter(in_bounds(grid, _))
  |> list.map(fn(adj_coords) {
    Adjacent(
      cell: Cell(get(grid, adj_coords), adj_coords),
      direction: direction(coords, adj_coords),
    )
  })
}

/// Transform coordinates (row, col) into linear index
/// 
/// ## Example
/// 
/// ```gleam
/// > to_index(#(2, 5), #(0, 3))
/// 3
/// 
/// > to_index(#(2, 5), #(1, 0))
/// 5
/// 
/// > to_index(#(2, 5), #(2, 0))
/// // panic as the row is out-of-bounds
/// ```
pub fn to_index(grid: Grid(a), coords: Coord) -> Int {
  let #(_n_rows, n_cols) = grid.size
  let #(row, col) = coords
  case in_bounds(grid, coords) {
    False -> {
      io.debug(coords)
      panic as "invalid coordinates out-of-bounds"
    }
    True -> row * n_cols + col
  }
}

pub fn to_coords(grid: Grid(a), index: Int) -> Coord {
  let #(n_rows, n_cols) = grid.size
  case index >= n_rows * n_cols || index < 0 {
    True -> panic as "Invalid index out-of-bounds"
    False -> #(index / n_cols, index % 5)
  }
}

pub fn get(grid: Grid(a), coords: Coord) -> a {
  let index = to_index(grid, coords)
  arrays.get(grid.values, index)
}

pub fn cell_at(grid: Grid(a), coords: Coord) -> Cell(a) {
  Cell(value: get(grid, coords), coords: coords)
}

pub fn iterate(grid: Grid(a)) -> iterator.Iterator(Cell(a)) {
  use r <- iterator.flat_map(iterator.range(from: 0, to: grid.size.0 - 1))
  use c <- iterator.map(iterator.range(from: 0, to: grid.size.1 - 1))
  Cell(get(grid, #(r, c)), #(r, c))
}

pub fn iterate_by_columns(grid: Grid(a)) -> iterator.Iterator(Cell(a)) {
  use col <- iterator.flat_map(iterator.range(from: 0, to: grid.size.1 - 1))
  use row <- iterator.map(iterator.range(from: 0, to: grid.size.0 - 1))
  Cell(get(grid, #(row, col)), #(row, col))
}

pub fn iter_column(grid: Grid(a), col: Int) -> iterator.Iterator(Cell(a)) {
  use row <- iterator.map(iterator.range(from: 0, to: grid.size.0 - 1))
  Cell(get(grid, #(row, col)), #(row, col))
}

pub fn iter_row(grid: Grid(a), row: Int) -> iterator.Iterator(Cell(a)) {
  use col <- iterator.map(iterator.range(from: 0, to: grid.size.1 - 1))
  Cell(get(grid, #(row, col)), #(row, col))
}

pub fn column(grid: Grid(a), col: Int) -> List(Cell(a)) {
  iterator.to_list(iter_column(grid, col))
}

pub fn row(grid: Grid(a), row: Int) -> List(Cell(a)) {
  iterator.to_list(iter_row(grid, row))
}
