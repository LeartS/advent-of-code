use itertools::Itertools;
use std::ops::RangeInclusive;

use aoc2022;

fn includes<T: Ord>(a: &RangeInclusive<T>, b: &RangeInclusive<T>) -> bool {
    a.start() <= b.start() && a.end() >= b.end()
}

fn overlaps<T: Ord>(a: &RangeInclusive<T>, b: &RangeInclusive<T>) -> bool {
    a.end() >= b.start() && a.start() <= b.end()
}

fn parse_assignment(assignment: &str) -> RangeInclusive<usize> {
    let (min_section, max_section) = assignment
        .split('-')
        .map(|n| n.parse::<usize>().unwrap())
        .collect_tuple::<(usize, usize)>()
        .expect("Invalid assignment format");
    min_section..=max_section
}

fn parse_line(line: String) -> (RangeInclusive<usize>, RangeInclusive<usize>) {
    line.split(',')
        .map(parse_assignment)
        .collect_tuple()
        .expect("Invalid line format")
}

fn part1() {
    let res = aoc2022::io::iterate_lines()
        .map(parse_line)
        .filter(|(a, b)| includes(a, b) || includes(b, a))
        .count();
    println!("There are {} pairs where one fully contains the other", res);
}

fn part2() {
    let res = aoc2022::io::iterate_lines()
        .map(parse_line)
        .filter(|(a, b)| overlaps(a, b))
        .count();
    println!("There are {} overlapping pairs", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
