import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/set
import utils/io as io_utils

type Card =
  #(set.Set(Int), set.Set(Int))

fn parse_card(card_line: String) -> Card {
  let assert Ok(#(_, numbers_str)) = string.split_once(card_line, ":")
  let assert Ok(#(winning, own)) = string.split_once(numbers_str, " | ")
  let assert Ok(winning) =
    winning
    |> io_utils.parse_ints()
    |> result.map(set.from_list)
  let assert Ok(own) =
    own
    |> io_utils.parse_ints()
    |> result.map(set.from_list)
  #(winning, own)
}

fn count_winners(card: Card) -> Int {
  card.0
  |> set.intersection(card.1)
  |> set.size()
}

fn points(n_winners: Int) -> Int {
  let assert Ok(points) =
    iterator.single(0)
    |> iterator.append(iterator.iterate(1, fn(n) { n * 2 }))
    |> iterator.at(n_winners)
  points
}

fn add_winning_copies(
  cards_counts: dict.Dict(Int, Int),
  card: Card,
  card_index: Int,
) -> dict.Dict(Int, Int) {
  let n_winners = count_winners(card)
  let assert Ok(copies) = dict.get(cards_counts, card_index)
  list.index_fold(
    over: list.repeat(Nil, n_winners),
    from: cards_counts,
    with: fn(cards_counts, _, offset) {
      dict.update(
        cards_counts,
        card_index + offset + 1,
        fn(count) {
          case count {
            option.Some(c) -> c + copies
            option.None -> panic as "unknown card to copy (out of bounds?)"
          }
        },
      )
    },
  )
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_card)
  |> list.map(function.compose(count_winners, points))
  |> int.sum()
}

pub fn part2(input: String) -> Int {
  let cards =
    input
    |> string.split("\n")
    |> list.map(parse_card)
  let cards_count =
    list.range(from: 0, to: list.length(cards) - 1)
    |> list.map(fn(i) { #(i, 1) })
    |> dict.from_list()

  cards
  |> list.index_fold(from: cards_count, with: add_winning_copies)
  |> dict.values()
  |> int.sum()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
