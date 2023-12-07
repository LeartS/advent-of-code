import gleam/erlang/file
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn read_stdin() -> Result(String, file.Reason) {
  "/dev/stdin"
  |> file.read()
  |> result.map(string.trim)
}

pub fn parse_ints(str: String) -> Result(List(Int), Nil) {
  str
  |> string.trim()
  |> string.split(" ")
  |> list.filter(fn(word) { !string.is_empty(word) })
  |> list.try_map(int.base_parse(_, 10))
}
