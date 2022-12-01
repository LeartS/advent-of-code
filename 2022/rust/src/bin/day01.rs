use std::cmp::max;

use aoc2022;

fn part1() {
    let (best, current) = aoc2022::io::iterate_lines().fold((0, 0), |(best, current), line| {
        match line.expect("Could not read line").as_ref() {
            "" => (max(best, current), 0),
            l => (best, current + l.parse::<i32>().expect("fdsfs")),
        }
    });
    println!(
        "Elf with most calories is carrying {} calories",
        max(best, current)
    );
}

fn part2() {
    let numbers: Vec<i32> = aoc2022::io::read_space_separated_values();
    println!("{:?}", numbers);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
