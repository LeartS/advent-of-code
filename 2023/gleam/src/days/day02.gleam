import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/io as io_utils

type Round {
  Round(red: Int, green: Int, blue: Int)
}

fn add_cubes(round: Round, cubes_str: String) -> Round {
  let assert [quantity_str, color] = string.split(cubes_str, on: " ")
  let assert Ok(quantity) = int.base_parse(quantity_str, 10)
  case color {
    "red" -> Round(..round, red: quantity)
    "green" -> Round(..round, green: quantity)
    "blue" -> Round(..round, blue: quantity)
  }
}

type Game {
  Game(id: Int, rounds: List(Round))
}

fn parse_round(round_str: String) -> Round {
  round_str
  |> string.split(on: ", ")
  |> list.fold(from: Round(0, 0, 0), with: add_cubes)
}

fn parse_game(game_str: String) -> Game {
  let assert Ok(#(game_id, rounds_str)) = string.split_once(game_str, on: ": ")
  let assert Ok(id) =
    game_id
    |> string.drop_left(5)
    |> int.base_parse(10)
  let rounds =
    rounds_str
    |> string.trim()
    |> string.split("; ")
    |> list.map(parse_round)
  Game(id: id, rounds: rounds)
}

fn is_valid(game: Game) -> Bool {
  list.all(
    game.rounds,
    fn(round) { round.red <= 12 && round.green <= 13 && round.blue <= 14 },
  )
}

fn minimum_required_cubes_power(game: Game) -> Int {
  let #(r, g, b) =
    list.fold(
      game.rounds,
      from: #(0, 0, 0),
      with: fn(mins, round) {
        #(
          int.max(mins.0, round.red),
          int.max(mins.1, round.green),
          int.max(mins.2, round.blue),
        )
      },
    )
  r * g * b
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_game)
  |> list.filter(is_valid)
  |> list.fold(from: 0, with: fn(acc, game) { acc + game.id })
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_game)
  |> list.map(minimum_required_cubes_power)
  |> int.sum()
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}
