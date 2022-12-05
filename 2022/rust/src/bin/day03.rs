use itertools::Itertools;
use std::{collections::HashSet, iter::FromIterator};

use aoc2022;

fn contents<'a>(line: &'a String) -> (&'a str, &'a str) {
    (&line[..line.len() / 2], &line[line.len() / 2..])
}

fn priority(item: char) -> usize {
    if item.is_ascii_lowercase() {
        return (item as u8 - 96).into();
    }
    if item.is_ascii_uppercase() {
        return (item as u8 - 64 + 26).into();
    }
    panic!("Invalid item '{}'", item);
}

fn part1() {
    let res: usize = aoc2022::io::iterate_lines()
        .map(|line| {
            let (c1, c2) = contents(&line);
            let fc1: HashSet<char> = HashSet::from_iter(c1.chars());
            let fc2 = HashSet::from_iter(c2.chars());
            let f = fc1
                .intersection(&fc2)
                .next()
                .expect("There's no item that appears in both compartments!");
            priority(*f)
        })
        .sum();
    println!("Sum of priorities is {}", res);
}

fn part2() {
    let res: usize = aoc2022::io::iterate_lines()
        .chunks(3)
        .into_iter()
        .map(|c| {
            let item = c
                .flat_map(|l| l.chars().unique().collect::<Vec<char>>())
                .counts()
                .into_iter()
                .find(|&(_item, count)| count == 3)
                .expect("No common item!")
                .0;
            priority(item)
        })
        .sum();
    println!("Sum of priorities is {}", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
