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
import utils/ascii_table

pub fn read_input(day: Int) -> String {
  let assert Ok(input) =
    file.read(
      "../inputs/day" <> {
        day
        |> int.to_string()
        |> string.pad_left(2, "0")
      } <> ".in",
    )
  string.trim(input)
}

const solutions = [
  #(day01.part1, day01.part2),
  #(day02.part1, day02.part2),
  #(day03.part1, day03.part2),
  #(day04.part1, day04.part2),
  #(day05.part1, day05.part2),
  #(day06.part1, day06.part2),
  #(day07.part1, day07.part2),
  #(day08.part1, day08.part2),
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
  let outputs =
    list.index_map(solutions, fn(index, fns) { run_solution(index + 1, fns) })
  ascii_table.table([["Day", "Part 1", "Part2"], ..outputs])
  |> io.println()
}
