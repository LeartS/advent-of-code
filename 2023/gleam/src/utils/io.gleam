import gleam/iterator
import gleam/erlang

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
