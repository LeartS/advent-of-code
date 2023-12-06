import gleam/erlang
import gleam/int
import gleam/iterator
import gleam/list
import gleam/string

pub fn iter_lines() -> iterator.Iterator(String) {
  iterator.unfold(
    from: Nil,
    with: fn(_) {
      case erlang.get_line("") {
        Ok(line) -> iterator.Next(element: line, accumulator: Nil)
        Error(_err) -> iterator.Done
      }
    },
  )
}

pub fn parse_ints(str: String) -> Result(List(Int), Nil) {
  str
  |> string.trim()
  |> string.split(" ")
  |> list.filter(fn(word) { !string.is_empty(word) })
  |> list.try_map(int.base_parse(_, 10))
}
