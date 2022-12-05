use std::cmp::max;

use aoc2022;

fn part1() {
    let (best, current) =
        aoc2022::io::iterate_lines().fold((0, 0), |(best, current), line| match line.as_ref() {
            "" => (max(best, current), 0),
            l => (best, current + l.parse::<i32>().expect("fdsfs")),
        });
    println!(
        "Elf with most calories is carrying {} calories",
        max(best, current)
    );
}

fn part2() {
    let mut elfs: Vec<i32> = Vec::new();
    let mut total: i32 = 0;
    for line in aoc2022::io::iterate_lines() {
        match line.as_str() {
            "" => {
                elfs.push(total);
                total = 0;
            }
            l => {
                total += l.parse::<i32>().expect("Invalid number");
            }
        }
    }
    elfs.push(total);
    elfs.sort();
    let res: i32 = elfs.iter().rev().take(3).sum();
    println!("3 richest elfs have a total of {} calories", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
