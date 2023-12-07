import gleam/io
import gleam/int
import gleam/list
import gleam/regex
import gleam/string
import utils/io as io_utils

fn despell(spelling: String) -> String {
  case spelling {
    "one" -> "1"
    "two" -> "2"
    "three" -> "3"
    "four" -> "4"
    "five" -> "5"
    "six" -> "6"
    "seven" -> "7"
    "eight" -> "8"
    "nine" -> "9"
    "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> spelling
  }
}

fn calibration_value_lax(line: String) -> Int {
  let assert Ok(forward_re) =
    regex.from_string(
      "(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|[1-9]",
    )
  let assert Ok(backward_re) =
    regex.from_string(
      "(eno)|(owt)|(eerht)|(ruof)|(evif)|(xis)|(neves)|(thgie)|(enin)|[1-9]",
    )
  let assert [first_match, ..] = regex.scan(forward_re, line)
  let assert [last_match, ..] =
    regex.scan(
      backward_re,
      line
      |> string.reverse(),
    )
  let first_digit = despell(first_match.content)
  let second_digit =
    last_match.content
    |> string.reverse()
    |> despell()
  let assert Ok(n) = int.base_parse(first_digit <> second_digit, 10)
  n
}

fn is_digit(char: String) -> Bool {
  case char {
    "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn calibration_value_strict(line: String) -> Int {
  let chars = string.to_graphemes(line)
  let assert Ok(first_digit) = list.find(chars, is_digit)
  let assert Ok(last_digit) =
    chars
    |> list.reverse()
    |> list.find(is_digit)
  let assert Ok(number) = int.base_parse({ first_digit <> last_digit }, 10)
  number
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(calibration_value_strict)
  |> int.sum()
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(calibration_value_lax)
  |> int.sum()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
