use std::io::{self, BufRead};

use aoc2020::utils;

const WINDOW_SIZE: usize = 25;

fn find_target(numbers: &Vec<u64>) -> Option<u64> {
    numbers
        .windows(WINDOW_SIZE + 1)
        .find_map(|window| {
            let (previous25, n) = (&window[..WINDOW_SIZE], window[WINDOW_SIZE]);
            match utils::find_couple_with_sum(previous25, n) {
                None => Some(n),
                Some(_) => None
            }
        })
}

fn part1(numbers: &Vec<u64>) {
    match find_target(numbers) {
        Some(n) => println!("{} is the target", n),
        None => panic!("All number are a sum of two of the previous ones!")
    }
}

fn part2(numbers: &Vec<u64>) {
    let target = find_target(numbers).unwrap();
    let mut from = 1;
    let mut to = 2;
    let mut sum = numbers[from] + numbers[to];
    while sum != target {
        if sum < target || from + 1 == to {
            to += 1;
            sum += numbers[to];
        } else {
            sum -= numbers[from];
            from += 1;
        }
    }
    let slice = &numbers[from..=to];
    let min = slice.iter().min().unwrap();
    let max = slice.iter().max().unwrap();
    println!("{} is the encryption weakness ({}, {})", min + max, min, max);
}

pub fn main() {
    let numbers: Vec<u64> = io::stdin().lock().lines().map(|l| l.unwrap().parse::<u64>().unwrap()).collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&numbers),
        Some(p) if p == "part2" => part2(&numbers),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
