//// I did not bother optimizing this one...

import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import utils/io as io_utils

type Map =
  List(List(String))

type Axis {
  Vertical
  Horizontal
}

fn symmetric_at(map: List(List(String)), i: Int) -> Bool {
  let #(a, b) = list.split(map, i)
  case list.length(a), list.length(b) {
    an, bn if an < bn ->
      a == b
      |> list.take(an)
      |> list.reverse()
    an, bn if an == bn -> a == list.reverse(b)
    an, bn if an > bn ->
      b == a
      |> list.drop(an - bn)
      |> list.reverse()
  }
}

fn find_reflection_lines(map: Map) -> List(#(Axis, Int)) {
  let horizontal =
    list.range(from: 1, to: list.length(map) - 1)
    |> list.filter(symmetric_at(map, _))
    |> list.map(fn(row) { #(Horizontal, row) })

  let map = list.transpose(map)
  let vertical =
    list.range(from: 1, to: list.length(map) - 1)
    |> list.filter(symmetric_at(map, _))
    |> list.map(fn(col) { #(Vertical, col) })

  list.concat([horizontal, vertical])
}

pub fn parse_map(map: String) -> List(List(String)) {
  map
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn smudge_at(map: Map, coords: #(Int, Int)) -> Map {
  map
  |> list.index_map(fn(r, row) {
    case r == coords.0 {
      False -> row
      True ->
        list.index_map(
          row,
          fn(c, cell) {
            case c == coords.1, cell {
              False, _ -> cell
              True, "#" -> "."
              True, "." -> "#"
            }
          },
        )
    }
  })
}

fn find_line_with_smudge(map: Map) -> Result(#(Axis, Int), Nil) {
  let original_lines = find_reflection_lines(map)

  {
    use r, row <- list.index_map(map)
    use c, _ <- list.index_map(row)
    #(r, c)
  }
  |> list.flatten()
  |> list.find_map(fn(coords) {
    let new_lines =
      map
      |> smudge_at(coords)
      |> find_reflection_lines()
      |> set.from_list()
      |> set.drop(original_lines)
      |> set.to_list()

    case new_lines {
      [] -> Error(Nil)
      [new_line] -> Ok(new_line)
      _ -> panic as "multiple new reflection lines by smuding at x,y"
    }
  })
}

fn reflection_line_id(line: #(Axis, Int)) -> Int {
  case line.0, line.1 {
    Vertical, n -> n
    Horizontal, n -> n * 100
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n\n")
  |> list.map(parse_map)
  |> list.map(find_reflection_lines)
  |> list.map(function.compose(list.map(_, reflection_line_id), int.sum))
  |> int.sum()
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\n\n")
  |> list.map(parse_map)
  |> list.try_map(find_line_with_smudge)
  |> result.map(list.map(_, reflection_line_id))
  |> result.map(int.sum)
  |> result.unwrap(-1)
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
