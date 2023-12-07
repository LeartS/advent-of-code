import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/io as io_utils

pub type HandType {
  FiveOFAKind
  FourOfAKind
  FullHouse
  ThreeOfAKind
  TwoPair
  OnePair
  HighCard
}

fn groups_to_hand_type(groups: List(#(String, Int))) -> HandType {
  case groups {
    [#(_, 5)] -> FiveOFAKind
    [#(_, 4), #(_, 1)] -> FourOfAKind
    [#(_, 3), #(_, 2)] -> FullHouse
    [#(_, 3), #(_, 1), #(_, 1)] -> ThreeOfAKind
    [#(_, 2), #(_, 2), #(_, 1)] -> TwoPair
    [#(_, 2), #(_, 1), #(_, 1), #(_, 1)] -> OnePair
    [#(_, 1), #(_, 1), #(_, 1), #(_, 1), #(_, 1)] -> HighCard
  }
}

fn infer_hand_type_normal(hand: String) -> HandType {
  hand
  |> string.to_graphemes()
  |> list.group(by: function.identity)
  |> dict.map_values(with: fn(_key, value) { list.length(value) })
  |> dict.to_list()
  |> list.sort(by: fn(a, b) { int.compare(b.1, a.1) })
  |> groups_to_hand_type()
}

fn infer_hand_type_wildcards(hand: String) -> HandType {
  let #(wildcards, tamecards) =
    hand
    |> string.to_graphemes
    |> list.partition(fn(card) { card == "J" })

  let tamecards_groups =
    tamecards
    |> list.group(by: function.identity)
    |> dict.map_values(with: fn(_key, value) { list.length(value) })
    |> dict.to_list()
    |> list.sort(by: fn(a, b) { int.compare(b.1, a.1) })

  let groups = case tamecards_groups {
    // if all wildcards, consider it best possible hand
    [] -> [#("A", 5)]
    [#(card, count), ..rest] -> [
      #(card, count + list.length(wildcards)),
      ..rest
    ]
  }

  groups_to_hand_type(groups)
}

fn card_number(card: String) -> Int {
  case card {
    "T" -> 10
    "J" -> 11
    "Q" -> 12
    "K" -> 13
    "A" -> 14
    "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
      case int.base_parse(card, 10) {
        Ok(n) -> n
        Error(_) -> panic as "invalid card"
      }
  }
}

pub fn hand_type_strength(hand_type: HandType) -> Int {
  case hand_type {
    FiveOFAKind -> 7
    FourOfAKind -> 6
    FullHouse -> 5
    ThreeOfAKind -> 4
    TwoPair -> 3
    OnePair -> 2
    HighCard -> 1
  }
}

pub fn hand_strength_normal(hand: String) -> Int {
  let cards_strength =
    list.fold(
      over: string.to_graphemes(hand),
      from: 0,
      with: fn(s, card) { s * 14 + card_number(card) - 2 },
    )
  let type_strength =
    hand
    |> infer_hand_type_normal()
    |> hand_type_strength()
  type_strength * 1_000_000 + cards_strength
}

pub fn hand_strength_wildcards(hand: String) -> Int {
  let card_strength = fn(card: String) {
    case card_number(card) {
      11 -> 0
      n if n > 11 -> n - 2
      n if n < 11 -> n - 1
    }
  }
  let cards_strength =
    list.fold(
      over: string.to_graphemes(hand),
      from: 0,
      with: fn(s, card) { s * 14 + card_strength(card) },
    )
  let type_strength =
    hand
    |> infer_hand_type_wildcards()
    |> hand_type_strength()
  type_strength * 1_000_000 + cards_strength
}

pub fn parse_input(input: String) -> List(#(String, Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [hand, bid] = string.split(line, " ")
    let assert Ok(bid) = int.base_parse(bid, 10)
    #(hand, bid)
  })
}

pub fn total_winnings(sorted_hand_bids: List(#(String, Int))) -> Int {
  list.index_fold(
    over: sorted_hand_bids,
    from: 0,
    with: fn(winnings, hand_bid, index) {
      winnings + hand_bid.1 * { index + 1 }
    },
  )
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> list.sort(by: fn(a, b) {
    int.compare(hand_strength_normal(a.0), hand_strength_normal(b.0))
  })
  |> total_winnings()
}

pub fn part2(input: String) -> Int {
  input
  |> parse_input()
  |> list.sort(by: fn(a, b) {
    int.compare(hand_strength_wildcards(a.0), hand_strength_wildcards(b.0))
  })
  |> total_winnings()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
