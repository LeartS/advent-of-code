import gleam/bool
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import utils/io as io_utils

type Status {
  Damaged
  Undamaged
  Unknown
}

fn can_start_with_damaged_block(cells: List(Status), block_size: Int) -> Bool {
  let #(block_cells, next_cells) = list.split(cells, block_size)
  let n_possibly_damaged =
    block_cells
    |> list.filter(fn(c) { c == Damaged || c == Unknown })
    |> list.length()
  case n_possibly_damaged, next_cells {
    // Invalid: not all the cells in the block are damaged
    npd, _ if npd < block_size -> False
    // Invalid: there can't be a damaged cell immediately after a damaaged block
    _, [Damaged, ..] -> False
    _, _ -> True
  }
}

fn n_arrangements_internal(
  cells: List(Status),
  blocks: List(Int),
  cache: dict.Dict(#(List(Status), List(Int)), Int),
) -> Int {
  case cells, blocks {
    [], [] -> 1
    [], _blocks -> 0
    cells, [] ->
      cells
      |> list.all(fn(cell) { cell != Damaged })
      |> bool.to_int()
    [first_cell, ..next_cells], [block_size, ..remaining_blocks] -> {
      let assert Ok(res) = case
        can_start_with_damaged_block(cells, block_size),
        first_cell
      {
        False, Damaged -> Ok(0)
        False, _ -> dict.get(cache, #(next_cells, blocks))
        True, Undamaged -> dict.get(cache, #(next_cells, blocks))
        True, Damaged ->
          dict.get(cache, #(list.drop(cells, block_size + 1), remaining_blocks))
        True, Unknown -> {
          let assert Ok(as_damaged) =
            dict.get(
              cache,
              #(list.drop(cells, block_size + 1), remaining_blocks),
            )
          let assert Ok(as_undamaged) = dict.get(cache, #(next_cells, blocks))
          Ok(as_damaged + as_undamaged)
        }
      }
      res
    }
  }
}

fn n_arrangements(cells: List(Status), blocks: List(Int)) -> Result(Int, Nil) {
  iterator.range(from: list.length(blocks), to: 0)
  |> iterator.flat_map(fn(block_index) {
    iterator.range(from: list.length(cells), to: 0)
    |> iterator.map(fn(cell_index) { #(block_index, cell_index) })
  })
  |> iterator.fold(
    from: dict.new(),
    with: fn(cache, e) {
      let #(block_index, cell_index) = e
      let blocks = list.drop(blocks, block_index)
      let cells = list.drop(cells, cell_index)
      let res = n_arrangements_internal(cells, blocks, cache)
      dict.insert(cache, #(cells, blocks), res)
    },
  )
  |> dict.get(#(cells, blocks))
}

type Record =
  #(List(Status), List(Int))

fn parse_record(line: String) -> Record {
  let assert Ok(#(cells_str, blocks_str)) = string.split_once(line, " ")
  let cells =
    cells_str
    |> string.to_graphemes
    |> list.map(fn(c) {
      case c {
        "." -> Undamaged
        "?" -> Unknown
        "#" -> Damaged
      }
    })
  let assert Ok(blocks) =
    blocks_str
    |> string.split(",")
    |> list.try_map(int.base_parse(_, 10))
  #(cells, blocks)
}

fn unfold(record: Record) -> Record {
  #(
    record.0
    |> list.repeat(5)
    |> list.intersperse([Unknown])
    |> list.flatten(),
    record.1
    |> list.repeat(5)
    |> list.flatten(),
  )
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_record)
  |> list.map(fn(r) {
    let assert Ok(n) = n_arrangements(r.0, r.1)
    n
  })
  |> int.sum()
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(function.compose(parse_record, unfold))
  |> list.map(fn(r) {
    let assert Ok(n) = n_arrangements(r.0, r.1)
    n
  })
  |> int.sum()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
