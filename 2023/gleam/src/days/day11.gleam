import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import utils/io as io_utils

pub fn read_galaxies(input: String) -> List(#(Int, Int)) {
  input
  |> string.split("\n")
  |> iterator.from_list()
  |> iterator.index()
  |> iterator.flat_map(fn(line_with_index) {
    let #(row, line) = line_with_index
    line
    |> string.to_graphemes()
    |> iterator.from_list()
    |> iterator.index()
    |> iterator.filter(fn(e) { e.1 == "#" })
    |> iterator.map(fn(e) { #(row, e.0) })
  })
  |> iterator.to_list()
}

pub fn expand(
  universe: List(#(Int, Int)),
  expansion_factor: Int,
) -> List(#(Int, Int)) {
  universe
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> iterator.from_list()
  |> iterator.transform(
    #(-1, 0),
    fn(acc, galaxy) {
      let #(last_seen_galaxy_row, empty_rows) = acc
      let #(row, col) = galaxy
      case row - last_seen_galaxy_row {
        2 ->
          iterator.Next(
            #(row + { empty_rows + 1 } * { expansion_factor - 1 }, col),
            #(row, empty_rows + 1),
          )
        0 | 1 ->
          iterator.Next(
            #(row + empty_rows * { expansion_factor - 1 }, col),
            #(row, empty_rows),
          )
      }
    },
  )
  |> iterator.to_list()
}

pub fn distance(a, b) -> Int {
  let #(ar, ac) = a
  let #(br, bc) = b
  int.absolute_value(ar - br) + int.absolute_value(ac - bc)
}

pub fn solution(input: String, expansion_factor: Int) -> Int {
  input
  |> read_galaxies()
  |> expand(expansion_factor)
  |> list.map(pair.swap)
  |> expand(expansion_factor)
  |> list.map(pair.swap)
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> list.combination_pairs()
  |> list.fold(from: 0, with: fn(sum, ab) { sum + distance(ab.0, ab.1) })
}

pub fn part1(input: String) -> Int {
  solution(input, 2)
}

pub fn part2(input: String) -> Int {
  solution(input, 1_000_000)
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
