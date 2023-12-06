import gleam/erlang
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils

pub fn winning_holding_times(time: Int, distance: Int) -> #(Int, Int) {
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

pub fn n_ways_to_win(race: #(Int, Int)) -> Int {
  let #(time, distance) = race
  let #(min, max) = winning_holding_times(time, distance)
  max - min + 1
}

pub fn merge_ints(ints: List(Int)) -> Int {
  let assert Ok(merged) =
    ints
    |> list.try_map(int.digits(_, 10))
    |> result.map(list.flatten)
    |> result.try(int.undigits(_, 10))
  merged
}

pub fn part1(races: List(#(Int, Int))) -> Int {
  races
  |> list.map(n_ways_to_win)
  |> int.product()
}

pub fn main() {
  let assert Ok(Ok(times)) =
    erlang.get_line("")
    |> result.map(string.drop_left(_, 5))
    |> result.map(utils.parse_ints)
  let assert Ok(Ok(distances)) =
    erlang.get_line("")
    |> result.map(string.drop_left(_, 9))
    |> result.map(utils.parse_ints)
  let races = list.zip(times, distances)
  let part1_sol = part1(races)
  io.println("Part 1: " <> int.to_string(part1_sol))
  let part2_sol = n_ways_to_win(#(merge_ints(times), merge_ints(distances)))
  io.println("Part 2: " <> int.to_string(part2_sol))
}
