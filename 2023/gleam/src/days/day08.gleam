import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/regex
import gleam/string
import gleam_community/maths/arithmetics
import utils/io as io_utils
import utils/iterator as iterator_utils

pub type Map =
  dict.Dict(String, #(String, String))

pub fn parse_node(node: String) -> #(String, #(String, String)) {
  let assert Ok(reg) = regex.from_string("^(\\w+) = \\((\\w+), (\\w+)\\)$")
  let assert [
    regex.Match(submatches: [Some(source), Some(left), Some(right)], ..),
  ] = regex.scan(reg, node)
  #(source, #(left, right))
}

pub fn parse_map(content: String) -> Map {
  content
  |> string.split("\n")
  |> list.map(parse_node)
  |> dict.from_list()
}

pub fn follow(
  map: Map,
  instructions: String,
  start: String,
) -> iterator.Iterator(String) {
  instructions
  |> string.to_graphemes()
  |> iterator.from_list()
  |> iterator.cycle()
  |> iterator.transform(
    from: start,
    with: fn(location, direction) {
      let assert Ok(#(left, right)) = dict.get(map, location)
      case direction {
        "L" -> iterator.Next(location, left)
        "R" -> iterator.Next(location, right)
      }
    },
  )
}

// Data type that represents all the Z steps for a particular (looping)
// Note that all path loops sooner or later,
// though the loop may not start at the beginning of the path
// 
// The first element of the pair are the non-repeating Z indexes
// (the ones that we encounter before the cycle start)
// and the second element are the repeating ones, with the cycle length
//
// For example, a Zs of 
//
//    #([0, 3, 5], #([10, 14], 25))
//
// Would mean that ghost will be at a *Z node at steps:
//
//   [0, 3, 5, 10, 14, 35, 39, 60, 64, ...]
type ZSeed =
  #(List(Int), #(List(Int), Int))

fn iterate_zs(seed: ZSeed) -> iterator.Iterator(Int) {
  let #(non_repeating, #(repeating, cycle_length)) = seed

  let repeating_zs_iterator =
    0
    |> iterator.iterate(fn(n) { n + cycle_length })
    |> iterator.flat_map(fn(offset) {
      repeating
      |> list.map(fn(n) { n + offset })
      |> iterator.from_list()
    })

  non_repeating
  |> iterator.from_list()
  |> iterator.append(repeating_zs_iterator)
}

pub fn z_seed(path_to_loop: List(#(String, Int))) -> ZSeed {
  let enumerated_path = list.index_map(path_to_loop, fn(i, v) { #(v, i) })
  let assert Ok(cycle_start_step) =
    list.at(path_to_loop, list.length(path_to_loop) - 1)
  let #(pre_cycle, cycle) =
    list.split_while(enumerated_path, fn(step) { step.0 != cycle_start_step })
  let cycle_length = list.length(cycle) - 1
  let non_repeating_zs =
    pre_cycle
    |> list.filter(fn(el) { string.ends_with({ el.0 }.0, "Z") })
    |> list.map(pair.second)
  let repeating_zs =
    cycle
    |> list.filter(fn(el) { string.ends_with({ el.0 }.0, "Z") })
    |> list.map(pair.second)
  #(non_repeating_zs, #(repeating_zs, cycle_length))
}

fn is_simple_cycle(seed: ZSeed) -> Bool {
  case seed {
    #([], #([first_z_step], cycle_length)) -> first_z_step == cycle_length
    _ -> False
  }
}

pub fn first_common_end_step(seeds: List(ZSeed)) -> Int {
  case list.all(seeds, is_simple_cycle) {
    True ->
      list.fold(
        seeds,
        from: 1,
        with: fn(lcm, seed) {
          let assert #([], #([n], _)) = seed
          arithmetics.lcm(lcm, n)
        },
      )
    False ->
      panic as "The solution only works if all the paths are simple cycles"
  }
}

pub fn part1(input: String) -> Int {
  let assert Ok(#(instructions, "\n" <> map)) =
    string.split_once(input, on: "\n")
  let steps =
    map
    |> parse_map()
    |> follow(instructions, "AAA")
    |> iterator.take_while(fn(location) { location != "ZZZ" })
    |> iterator.to_list()
    |> list.length()
  steps + 1
}

pub fn part2(input: String) -> Int {
  let assert Ok(#(instructions, "\n" <> map)) =
    string.split_once(input, on: "\n")

  let map = parse_map(map)

  let starting_points =
    map
    |> dict.to_list()
    |> list.filter_map(fn(entry) {
      case string.ends_with(entry.0, "A") {
        True -> Ok(entry.0)
        False -> Error(Nil)
      }
    })

  let instructions_cycle =
    iterator.cycle(iterator.range(from: 0, to: string.length(instructions) - 1))

  starting_points
  |> list.map(fn(starting_point) {
    starting_point
    |> follow(map, instructions, _)
    |> iterator.zip(instructions_cycle)
    |> iterator_utils.take_until_repeating()
    |> iterator.to_list()
  })
  |> list.map(z_seed)
  |> first_common_end_step()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
