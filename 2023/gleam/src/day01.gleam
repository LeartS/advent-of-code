import gleam/io
import gleam/int
import gleam/regex
import gleam/iterator
import gleam/string
import utils

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

pub fn main() {
  utils.iter_lines()
  |> iterator.map(calibration_value_lax)
  |> iterator.to_list()
  |> int.sum()
  |> int.to_string()
  |> io.println()
}
