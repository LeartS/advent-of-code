use itertools::Itertools;
use regex::Regex;
use std::collections::HashMap;

use aoc2022;

type Stacks = Vec<Vec<char>>;
type Move = (usize, usize, usize);

fn parse_starting_stacks(drawing: &str) -> Stacks {
    let d: HashMap<usize, Vec<char>> = drawing
        .lines()
        .rev()
        .skip(1)
        .flat_map(|line| {
            line.chars()
                .enumerate()
                .filter(|(_i, c)| c.is_ascii_alphabetic())
                .collect::<Vec<(usize, char)>>()
        })
        .into_group_map();

    d.into_iter()
        .sorted_by_key(|entry| entry.0)
        .map(|entry| entry.1)
        .collect()
}

fn parse_instruction(line: String) -> Move {
    let re = Regex::new(r"^move (\d+) from (\d+) to (\d+)$").unwrap();
    re.captures(&line)
        .expect("invalid line")
        .iter()
        .skip(1)
        .filter_map(|x| x.and_then(|m| Some(m.as_str())))
        .map(|n| n.parse::<usize>().unwrap())
        .collect_tuple()
        .expect("Invalid line")
}

fn read_input() -> (Stacks, Vec<Move>) {
    let line_iterator = &mut aoc2022::io::iterate_lines();
    let drawing: String = line_iterator.take_while(|line| line.len() > 0).join("\n");
    let stacks = parse_starting_stacks(&drawing);
    let moves = line_iterator.map(parse_instruction).collect_vec();
    (stacks, moves)
}

fn do_move_9000(stacks: &mut Stacks, (n, from, to): Move) {
    let from_size = stacks[from - 1].len();
    let crates = stacks[from - 1].drain(from_size - n..).rev().collect_vec();
    stacks[to - 1].extend(crates);
}

fn do_move_9001(stacks: &mut Stacks, (n, from, to): Move) {
    let from_size = stacks[from - 1].len();
    let crates = stacks[from - 1].drain(from_size - n..).collect_vec();
    stacks[to - 1].extend(crates);
}

fn part1() {
    let (mut stacks, moves) = read_input();
    for m in moves {
        do_move_9000(&mut stacks, m);
    }
    let message = stacks
        .iter()
        .map(|s| *s.last().expect("Empty stack"))
        .join("");
    println!("Top crates message: {}", message);
}

fn part2() {
    let (mut stacks, moves) = read_input();
    for m in moves {
        do_move_9001(&mut stacks, m);
    }
    let message = stacks
        .iter()
        .map(|s| *s.last().expect("Empty stack"))
        .join("");
    println!("Top crates message: {}", message);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
