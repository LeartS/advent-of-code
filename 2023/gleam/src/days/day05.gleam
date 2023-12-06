import gleam/erlang/file
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/string

const max_n = 100_000_000_000

pub type MapRange {
  MapRange(source: Int, destination: Int, length: Int)
}

pub type Map {
  Map(name: String, ranges: List(MapRange))
}

pub type Almanac {
  Almanac(seeds: List(Int), maps: List(Map))
}

pub fn compare_range(a: MapRange, b: MapRange) -> Order {
  int.compare(a.source, b.source)
}

pub fn parse_map(map: String) -> Map {
  let assert Ok(#(name, ranges)) = string.split_once(map, "\n")
  let ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(range_str) {
      let assert Ok([dst, src, len]) =
        range_str
        |> string.split(" ")
        |> list.try_map(int.base_parse(_, 10))
      MapRange(source: src, destination: dst, length: len)
    })
    |> fill_gaps()
  Map(name: string.drop_right(name, 5), ranges: ranges)
}

pub fn parse_seeds(seeds_line: String) -> List(Int) {
  let assert Ok(seeds) =
    seeds_line
    |> string.drop_left(7)
    |> string.split(" ")
    |> list.try_map(int.base_parse(_, 10))
  seeds
}

pub fn parse_almanac(contents: String) -> Almanac {
  let assert [seeds_text, ..maps] =
    contents
    |> string.split("\n\n")
    |> list.map(string.trim)
  let seeds = parse_seeds(seeds_text)
  let maps = list.map(maps, parse_map)
  Almanac(seeds: seeds, maps: maps)
}

pub fn fill_gaps(ranges: List(MapRange)) -> List(MapRange) {
  let #(next, ranges) =
    ranges
    |> list.sort(by: compare_range)
    |> list.fold(
      from: #(0, []),
      with: fn(acc, range) {
        let #(next_uncovered_source, ranges) = acc
        case range.source - next_uncovered_source {
          0 -> #(range.source + range.length, [range, ..ranges])
          gap_size -> #(
            range.source + range.length,
            [
              range,
              MapRange(
                source: next_uncovered_source,
                destination: next_uncovered_source,
                length: gap_size,
              ),
              ..ranges
            ],
          )
        }
      },
    )
  list.reverse([
    MapRange(source: next, destination: next, length: max_n - next),
    ..ranges
  ])
}

// from (inclusive), length
pub type Interval =
  #(Int, Int)

pub fn map_interval(interval: Interval, map: Map) -> List(Interval) {
  let #(interval_from, interval_length) = interval
  let interval_to = interval_from + interval_length - 1
  map.ranges
  |> list.drop_while(fn(range) {
    range.source + range.length - 1 < interval_from
  })
  |> list.fold_until(
    from: [],
    with: fn(output_ranges, map_range) {
      let from = int.max(interval_from, map_range.source)
      let to = int.min(interval_to, map_range.source + map_range.length - 1)
      let new_output_interval = #(
        map_range.destination + { from - map_range.source },
        to - from + 1,
      )
      case interval_to > to {
        True -> list.Continue([new_output_interval, ..output_ranges])
        False -> list.Stop([new_output_interval, ..output_ranges])
      }
    },
  )
}

pub fn map_number(n: Int, map: Map) -> Int {
  let dest =
    map.ranges
    |> list.find_map(fn(range) {
      // inclusive interval
      let #(start, end) = #(range.source, range.source + range.length - 1)
      case n {
        i if i >= start && i <= end -> Ok(n - start + range.destination)
        _ -> Error(Nil)
      }
    })
    |> result.unwrap(or: n)
  dest
}

pub fn location_for_seed(almanac: Almanac, seed: Int) -> Int {
  list.fold(almanac.maps, seed, map_number)
}

pub fn location_for_intervals(
  almanac: Almanac,
  intervals: List(Interval),
) -> List(Interval) {
  almanac.maps
  |> list.fold(
    from: intervals,
    with: fn(intervals, map) { list.flat_map(intervals, map_interval(_, map)) },
  )
}

pub fn part1(almanac: Almanac) -> Int {
  let assert Ok(res) =
    almanac.seeds
    |> list.map(location_for_seed(almanac, _))
    |> list.reduce(int.min)
  res
}

pub fn part2(almanac: Almanac) -> Int {
  let seeds_intervals =
    almanac.seeds
    |> list.sized_chunk(2)
    |> list.map(fn(interval) {
      let assert [from, to] = interval
      #(from, to)
    })
  let assert Ok(#(minimum_location, _)) =
    almanac
    |> location_for_intervals(seeds_intervals)
    |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
    |> list.first()
  minimum_location
}

pub fn main() {
  let assert Ok(contents) = file.read("/dev/stdin")
  let almanac = parse_almanac(contents)
  let part1_sol = part1(almanac)
  io.println(
    "Part 1: the minimum location for seeds is " <> int.to_string(part1_sol),
  )
  let part2_sol = part2(almanac)
  io.println(
    "Part 2: minimum location for seeds is " <> int.to_string(part2_sol),
  )
}
