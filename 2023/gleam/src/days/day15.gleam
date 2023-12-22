import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/io as io_utils
import arrays

// [#(Label, Focal Length)]
type Box =
  List(#(String, Int))

type Line =
  arrays.Array(Box)

fn remove_lens(box: Box, label: String) -> Box {
  list.filter(box, fn(lens) { lens.0 != label })
}

fn replace_lens(box: Box, label: String, focal_length: Int) {
  let #(found, box) =
    list.fold(
      over: box,
      from: #(False, []),
      with: fn(acc, lens) {
        let #(replaced, lenses) = acc
        case lens.0 {
          l if l == label -> #(True, [#(label, focal_length), ..lenses])
          _ -> #(replaced, [lens, ..lenses])
        }
      },
    )
  case found {
    True -> list.reverse(box)
    False -> list.reverse([#(label, focal_length), ..box])
  }
}

fn hash(string: String) -> Int {
  string
  |> string.to_utf_codepoints()
  |> list.fold(
    from: 0,
    with: fn(acc, codepoint: UtfCodepoint) {
      { acc + string.utf_codepoint_to_int(codepoint) } * 17 % 256
    },
  )
}

pub fn apply_initialization_step(line: Line, step: String) -> Line {
  case string.contains(step, "=") {
    True -> {
      let assert Ok(#(label, focal_length)) = string.split_once(step, "=")
      let assert Ok(focal_length) = int.base_parse(focal_length, 10)
      let box_index = hash(label)
      arrays.set(
        line,
        box_index,
        replace_lens(arrays.get(line, box_index), label, focal_length),
      )
    }
    False -> {
      let assert Ok(#(label, _)) = string.split_once(step, "-")
      let box_index = hash(label)
      arrays.set(
        line,
        box_index,
        remove_lens(arrays.get(line, box_index), label),
      )
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim()
  |> string.replace("\n", "")
  |> string.split(",")
  |> list.map(hash)
  |> int.sum()
}

pub fn part2(input: String) -> Int {
  let line: Line =
    arrays.new(256)
    |> arrays.map(fn(_, _) { [] })

  input
  |> string.trim()
  |> string.replace("\n", "")
  |> string.split(",")
  |> list.fold(from: line, with: apply_initialization_step)
  |> arrays.map(fn(box, box_index) {
    list.index_fold(
      box,
      0,
      fn(box_power, lens, slot) {
        box_power + { box_index + 1 } * { slot + 1 } * lens.1
      },
    )
  })
  |> arrays.fold(0, fn(box_power, total) { total + box_power })
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
