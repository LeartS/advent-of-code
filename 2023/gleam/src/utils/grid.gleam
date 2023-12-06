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

pub type Entry(a) =
  #(a, Coord)

pub opaque type Grid(a) {
  Grid(size: #(Int, Int), cells: arrays.Array(a))
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
  let cells =
    contents
    |> string.replace(each: "\n", with: "")
    |> string.to_graphemes()
    |> list.map(cell_transformer)
    |> arrays.from_list()
  Grid(size: #(n_rows, n_cols), cells: cells)
}

pub fn from_string(contents: String) -> Grid(String) {
  from_string_with(contents, function.identity)
}

pub fn in_bounds(grid: Grid(a), coords: Coord) -> Bool {
  let #(n_rows, n_cols) = grid.size
  let #(r, c) = coords
  r >= 0 && r < n_rows && c >= 0 && c < n_cols
}

pub fn adjacents_without_diagonals(
  grid: Grid(a),
  coords: Coord,
) -> List(Entry(a)) {
  let #(row, col) = coords
  [#(row - 1, col), #(row, col - 1), #(row, col + 1), #(row + 1, col)]
  |> list.filter(in_bounds(grid, _))
  |> list.map(fn(coords) { #(get(grid, coords), coords) })
}

pub fn adjacents_with_diagonals(grid: Grid(a), coords: Coord) -> List(Entry(a)) {
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
  |> list.map(fn(coords) { #(get(grid, coords), coords) })
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
  arrays.get(grid.cells, index)
}

pub fn iterate(grid: Grid(a)) -> iterator.Iterator(Entry(a)) {
  use r <- iterator.flat_map(iterator.range(from: 0, to: grid.size.0 - 1))
  use c <- iterator.map(iterator.range(from: 0, to: grid.size.1 - 1))
  #(get(grid, #(r, c)), #(r, c))
}
