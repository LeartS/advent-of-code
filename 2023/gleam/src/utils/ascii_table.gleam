/// single-line box
/// ┌─────┬─────┐
/// │  A  │  B  │
/// ├─────┼─────┤
/// │  1  │  2  │
/// └─────┴─────┘
/// 
/// double-line box
/// ╔═════╦═════╗
/// ║  A  ║  B  ║
/// ╠═════╬═════╣
/// ║  1  ║  2  ║
/// ╚═════╩═════╝
/// 
/// bold double-line box
/// ┏━━━━━┳━━━━━┓
/// ┃  A  ┃  B  ┃
/// ┣━━━━━╋━━━━━┫
/// ┃  1  ┃  2  ┃
/// ┗━━━━━┻━━━━━┛
/// 
/// rounded-corner box
/// ╭─────╮
/// │  A  │
/// ├─────┤
/// │  1  │
/// ╰─────╯
import gleam/int
// import gleam/io
import gleam/list
import gleam/string
import gleam/string_builder

pub type Data =
  List(List(String))

pub fn calculate_column_sizes(data: Data) -> List(Int) {
  data
  |> list.transpose()
  |> list.map(fn(series) {
    series
    |> list.map(string.length)
    |> list.fold(from: 0, with: int.max)
    |> int.add(2)
  })
}

pub fn roof(column_sizes: List(Int)) -> string_builder.StringBuilder {
  column_sizes
  |> list.map(string.repeat("─", _))
  |> list.map(string_builder.from_string)
  |> string_builder.join("┬")
  |> string_builder.prepend("┌")
  |> string_builder.append("┐")
}

pub fn row(
  column_sizes: List(Int),
  row: List(String),
) -> string_builder.StringBuilder {
  row
  |> list.zip(column_sizes)
  |> list.map(fn(el) {
    string.repeat(" ", el.1 - string.length(el.0) - 1) <> el.0 <> " "
  })
  |> list.intersperse("│")
  |> string_builder.from_strings()
  |> string_builder.prepend("│")
  |> string_builder.append("│")
}

pub fn ceiling(column_sizes: List(Int)) -> string_builder.StringBuilder {
  column_sizes
  |> list.map(string.repeat("─", _))
  |> list.map(string_builder.from_string)
  |> string_builder.join("┼")
  |> string_builder.prepend("├")
  |> string_builder.append("┤")
}

pub fn foundation(column_sizes: List(Int)) -> string_builder.StringBuilder {
  column_sizes
  |> list.map(string.repeat("─", _))
  |> list.map(string_builder.from_string)
  |> string_builder.join("┴")
  |> string_builder.prepend("└")
  |> string_builder.append("┘")
}

pub fn table(data: Data) -> String {
  let column_sizes = calculate_column_sizes(data)
  data
  |> list.map(row(column_sizes, _))
  |> list.intersperse(ceiling(column_sizes))
  |> string_builder.join("\n")
  |> string_builder.prepend("\n")
  |> string_builder.prepend_builder(roof(column_sizes))
  |> string_builder.append("\n")
  |> string_builder.append_builder(foundation(column_sizes))
  |> string_builder.to_string()
}
