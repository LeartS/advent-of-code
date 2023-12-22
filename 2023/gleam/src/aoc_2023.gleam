import gleam/erlang/file
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import days/day01
import days/day02
import days/day03
import days/day04
import days/day05
import days/day06
import days/day07
import days/day08
import days/day09
import days/day10
import days/day11
import days/day12
import days/day13
import days/day15
import utils/ascii_table

pub fn read_input(day: Int) -> String {
  let padded_day =
    day
    |> int.to_string()
    |> string.pad_left(2, "0")
  let assert Ok(input) = file.read("../inputs/day" <> padded_day <> ".in")
  string.trim(input)
}

const solutions = [
  #(1, #(day01.part1, day01.part2)),
  #(2, #(day02.part1, day02.part2)),
  #(3, #(day03.part1, day03.part2)),
  #(4, #(day04.part1, day04.part2)),
  #(5, #(day05.part1, day05.part2)),
  #(6, #(day06.part1, day06.part2)),
  #(7, #(day07.part1, day07.part2)),
  #(8, #(day08.part1, day08.part2)),
  #(9, #(day09.part1, day09.part2)),
  #(10, #(day10.part1, day10.part2)),
  #(11, #(day11.part1, day11.part2)),
  #(12, #(day12.part1, day12.part2)),
  #(13, #(day13.part1, day13.part2)),
  #(15, #(day15.part1, day15.part2)),
]

fn run_solution(
  day: Int,
  fns: #(fn(String) -> Int, fn(String) -> Int),
) -> List(String) {
  let day_name =
    "Dec " <> {
      int.to_string(day)
      |> string.pad_left(2, "0")
    }
  let input = read_input(day)
  let part1 =
    fns.0
    |> function.apply1(input)
    |> int.to_string()
  let part2 =
    fns.1
    |> function.apply1(input)
    |> int.to_string()
  [day_name, part1, part2]
}

pub fn main() {
  solutions
  |> list.map(fn(el) { run_solution(el.0, el.1) })
  |> list.prepend(["Day", "Part 1", "Part2"])
  |> ascii_table.table()
  |> io.println()
}
