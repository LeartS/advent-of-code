import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string
import utils/io as io_utils

fn down(sequence: List(Int)) -> List(Int) {
  sequence
  |> list.window_by_2()
  |> list.map(fn(e) { e.1 - e.0 })
}

pub fn expand_right(sequence: List(Int)) -> List(Int) {
  let next =
    iterator.unfold(
      from: sequence,
      with: fn(sequence) {
        let assert Ok(last) = list.last(sequence)
        case list.any(sequence, fn(n) { n != 0 }) {
          False -> iterator.Done
          True -> iterator.Next(last, down(sequence))
        }
      },
    )
    |> iterator.to_list()
    |> int.sum()
  list.append(sequence, [next])
}

pub fn expand_left(sequence: List(Int)) -> List(Int) {
  let assert Ok(next) =
    iterator.unfold(
      from: sequence,
      with: fn(sequence) {
        let assert [first, ..] = sequence
        case list.any(sequence, fn(n) { n != 0 }) {
          False -> iterator.Done
          True -> iterator.Next(first, down(sequence))
        }
      },
    )
    |> iterator.to_list()
    |> list.reverse()
    |> list.reduce(fn(a, b) { b - a })
  list.prepend(sequence, next)
}

pub fn part1(input: String) -> Int {
  let assert Ok(report) =
    input
    |> string.split("\n")
    |> list.try_map(io_utils.parse_ints)

  let assert Ok(n) =
    report
    |> list.try_map(function.compose(expand_right, list.last))
    |> result.map(int.sum)
  n
}

pub fn part2(input: String) -> Int {
  let assert Ok(report) =
    input
    |> string.split("\n")
    |> list.try_map(io_utils.parse_ints)

  let assert Ok(n) =
    report
    |> list.try_map(function.compose(expand_left, list.first))
    |> result.map(int.sum)
  n
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
