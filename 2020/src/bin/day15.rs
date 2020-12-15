use std::collections::HashMap;
use std::io::{self, BufRead};

fn iter_game(initial_numbers: &[usize]) -> impl Iterator<Item = usize> {
    // this assumes no duplicates between the initial numbers
    let mut k: HashMap<usize, usize> = initial_numbers
        .iter()
        .enumerate()
        .map(|(i, n)| (*n, i + 1))
        .collect();
    let mut next_spoken = 0;
    let mut turn = initial_numbers.len() + 1;
    let game_iterator = std::iter::repeat_with(move || {
        next_spoken = match k.insert(next_spoken, turn) {
            None => 0,
            Some(n) => turn - n,
        };
        turn += 1;
        next_spoken
    });
    initial_numbers
        .to_owned()
        .into_iter()
        .chain(std::iter::once(next_spoken))
        .chain(game_iterator)
}

fn part1(initial_numbers: &[usize]) {
    let res = iter_game(initial_numbers).nth(2019).unwrap();
    println!("{} is the 2020th spoken number", res);
}

fn part2(initial_numbers: &[usize]) {
    let res = iter_game(initial_numbers).nth(29_999_999).unwrap();
    println!("{} is the 30,000,000th spoken number", res);
}

pub fn main() {
    let initial_numbers: Vec<usize> = io::stdin()
        .lock()
        .lines()
        .next()
        .unwrap()
        .unwrap()
        .split(',')
        .map(|s| s.parse::<usize>().unwrap())
        .collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&initial_numbers),
        Some(p) if p == "part2" => part2(&initial_numbers),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
