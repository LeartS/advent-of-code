import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils/io as io_utils

fn winning_holding_times(time: Int, distance: Int) -> #(Int, Int) {
  let assert Ok(b24ac) = int.square_root(time * time - 4 * distance)
  let x1 = { int.to_float(time) *. -1.0 +. b24ac } /. -2.0
  let x2 = { int.to_float(time) *. -1.0 -. b24ac } /. -2.0
  #(
    x1
    |> float.ceiling()
    |> float.round(),
    x2
    |> float.floor()
    |> float.round(),
  )
}

fn n_ways_to_win(race: #(Int, Int)) -> Int {
  let #(time, distance) = race
  let #(min, max) = winning_holding_times(time, distance)
  max - min + 1
}

fn merge_ints(ints: List(Int)) -> Int {
  let assert Ok(merged) =
    ints
    |> list.try_map(int.digits(_, 10))
    |> result.map(list.flatten)
    |> result.try(int.undigits(_, 10))
  merged
}

fn parse_times_and_distances(input: String) -> #(List(Int), List(Int)) {
  let assert [times_line, distances_line] = string.split(input, "\n")
  let assert Ok(times) =
    times_line
    |> string.drop_left(5)
    |> io_utils.parse_ints()
  let assert Ok(distances) =
    distances_line
    |> string.drop_left(9)
    |> io_utils.parse_ints()
  #(times, distances)
}

pub fn part1(input: String) -> Int {
  let #(times, distances) = parse_times_and_distances(input)
  list.zip(times, distances)
  |> list.map(n_ways_to_win)
  |> int.product()
}

pub fn part2(input: String) -> Int {
  let #(times, distances) = parse_times_and_distances(input)
  n_ways_to_win(#(merge_ints(times), merge_ints(distances)))
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
