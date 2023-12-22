import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import utils/io as io_utils
import arrays

type XYZ {
  XYZ(x: Int, y: Int, z: Int)
}

type Brick {
  // start_x <= end_x && start_y <= end_y && start_z <= end_z
  Brick(id: Int, start: XYZ, end: XYZ)
}

fn parse_coordinates(str: String) -> XYZ {
  let assert Ok([x, y, z]) =
    str
    |> string.split(",")
    |> list.try_map(int.base_parse(_, 10))
  XYZ(x, y, z)
}

fn parse_brick(index: Int, str: String) -> Brick {
  let assert Ok(#(start, end)) = string.split_once(str, "~")
  Brick(id: index, start: parse_coordinates(start), end: parse_coordinates(end))
}

fn overlap_in_horizontal_plane(a: Brick, b: Brick) -> Bool {
  !{
    { a.end.x < b.start.x || a.start.x > b.end.x } || {
      a.end.y < b.start.y || a.start.y > b.end.y
    }
  }
}

fn fall(brick: Brick, fallen_bricks: List(Brick)) -> Brick {
  let new_z =
    fallen_bricks
    |> list.filter(fn(b) { overlap_in_horizontal_plane(brick, b) })
    |> list.fold(
      1,
      fn(lowest_z, b) {
        case b.end.z + 1 > lowest_z {
          True -> b.end.z + 1
          False -> lowest_z
        }
      },
    )
  Brick(
    id: brick.id,
    start: XYZ(..brick.start, z: new_z),
    end: XYZ(..brick.end, z: new_z + brick.end.z - brick.start.z),
  )
}

fn precipitate(bricks: List(Brick)) -> List(Brick) {
  bricks
  |> list.sort(by: fn(a, b) { int.compare(a.start.z, b.start.z) })
  |> list.fold([], fn(fallen, brick) { [fall(brick, fallen), ..fallen] })
  |> list.reverse()
}

fn calculate_support_network(
  fallen_blocks: List(Brick),
) -> dict.Dict(Int, List(Int)) {
  fallen_blocks
  |> list.sort(fn(a, b) { int.compare(a.start.z, b.start.z) })
  |> list.map(fn(me) {
    let supporting =
      fallen_blocks
      |> list.filter(fn(other) {
        other.end.z == me.start.z - 1 && overlap_in_horizontal_plane(me, other)
      })
      |> list.map(fn(brick) { brick.id })
    #(me.id, supporting)
  })
  |> dict.from_list()
}

fn format_matrix(matrix: arrays.Array(Bool), n: Int) -> String {
  let a = {
    use r <- list.map(list.range(0, n - 1))
    use c <- list.map(list.range(0, n - 1))
    case arrays.get(matrix, r * n + c) {
      True -> "X"
      False -> "."
    }
  }
  a
  |> list.map(string.join(_, ""))
  |> string.join("\n")
}

pub fn part1(input: String) -> Int {
  let bricks =
    input
    |> string.split("\n")
    |> list.index_map(parse_brick)
    |> precipitate()

  let n_pillars =
    bricks
    |> calculate_support_network()
    |> dict.values()
    |> list.filter(fn(brick_supporters) { list.length(brick_supporters) == 1 })
    |> list.flatten()
    |> set.from_list()
    |> set.size()

  list.length(bricks) - n_pillars
}

pub fn part2(input: String) -> Int {
  let blocks =
    input
    |> string.split("\n")
    |> list.index_map(parse_brick)
    |> precipitate()
    |> list.sort(by: fn(a, b) { int.compare(a.start.z, b.start.z) })

  let n = list.length(blocks)
  let support_network = calculate_support_network(blocks)

  // Does block r fall if we disintegrate block c?
  // index = r * N + c
  // Recurrence: fall_matrix(r, c) = all(fall_matrix(s, c) for s in supports(r))
  let initial_fall_matrix =
    list.range(0, n * n)
    |> list.map(fn(i) { i % n == i / n })
    |> arrays.from_list()

  let fall_matrix =
    blocks
    |> list.flat_map(fn(b1) { list.map(blocks, fn(b2) { #(b1, b2) }) })
    |> list.filter(fn(pair) { { pair.0 }.start.z > { pair.1 }.start.z })
    |> list.fold(
      from: initial_fall_matrix,
      with: fn(fall_matrix, combination) {
        let #(b1, b2) = combination
        let assert Ok(supports) = dict.get(support_network, b1.id)
        let res =
          list.all(
            supports,
            fn(support) { arrays.get(fall_matrix, support * n + b2.id) },
          )
        arrays.set(fall_matrix, b1.id * n + b2.id, res)
      },
    )

  let bricks_that_would_fall =
    fall_matrix
    |> arrays.to_list()
    |> list.filter(function.identity)
    |> list.length()
  // Only count _other_ bricks that would fall
  bricks_that_would_fall - n
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
