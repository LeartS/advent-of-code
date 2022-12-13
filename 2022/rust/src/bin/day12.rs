use std::collections::{HashSet, VecDeque};

use aoc2022;
use itertools::Itertools;

fn height(c: char) -> usize {
    match c as u8 {
        83 => 1,
        69 => 26,
        n @ 97..=122 => (n - 96) as usize,
        _ => panic!("Invalid char in input"),
    }
}

fn adj(
    map: &Vec<Vec<char>>,
    row: usize,
    col: usize,
    inverted: bool,
) -> impl Iterator<Item = (usize, usize)> + '_ {
    let row_range = (row as isize - 1).max(0) as usize..(row + 2).min(map.len());
    let col_range = (col as isize - 1).max(0) as usize..(col + 2).min(map[0].len());
    row_range
        .cartesian_product(col_range)
        .filter(move |&(r, c)| {
            let h = if inverted {
                height(map[r][c]) >= height(map[row][col]) - 1
            } else {
                height(map[r][c]) <= height(map[row][col]) + 1
            };
            h && (r == row) ^ (c == col)
        })
}

fn shortest_path_length(
    map: &Vec<Vec<char>>,
    start: (usize, usize),
    end_fn: impl Fn(char) -> bool,
    inverted: bool,
) -> usize {
    let mut next = VecDeque::new();
    next.push_back((start, 0));
    let mut visited: HashSet<(usize, usize)> = HashSet::new();
    while let Some(((r, c), steps)) = next.pop_front() {
        if visited.contains(&(r, c)) {
            continue;
        }
        visited.insert((r, c));
        if end_fn(map[r][c]) {
            return steps;
        }
        for (next_r, next_c) in adj(&map, r, c, inverted) {
            next.push_back(((next_r, next_c), steps + 1));
        }
    }
    0
}

fn part1() {
    let map: Vec<Vec<char>> = aoc2022::io::iterate_lines()
        .map(|line| line.chars().collect::<Vec<char>>())
        .collect();
    let start = map
        .iter()
        .enumerate()
        .find_map(|(r, row)| row.iter().position(|&c| c == 'S').map(|c| (r, c)))
        .unwrap();
    let min_steps = shortest_path_length(&map, start, |c| c == 'E', false);
    println!("{}", min_steps);
}

fn part2() {
    let map: Vec<Vec<char>> = aoc2022::io::iterate_lines()
        .map(|line| line.chars().collect::<Vec<char>>())
        .collect();
    let start = map
        .iter()
        .enumerate()
        .find_map(|(r, row)| row.iter().position(|&c| c == 'E').map(|c| (r, c)))
        .unwrap();
    let min_steps = shortest_path_length(&map, start, |c| c == 'a' || c == 'S', true);
    println!("{}", min_steps);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
