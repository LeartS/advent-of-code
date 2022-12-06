use aoc2022;
use itertools::Itertools;

fn generic_solution(window_size: usize) {
    let (index, _letters) = aoc2022::io::iterate_lines()
        .next()
        .expect("Missing input")
        .chars()
        .collect_vec()
        .windows(window_size)
        .enumerate()
        .find(|(_i, chars)| chars.iter().unique().count() == window_size)
        .expect("Invalid input");
    println!("Marker is at {}", index + window_size);
}

fn part1() {
    generic_solution(4);
}

fn part2() {
    generic_solution(14);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
