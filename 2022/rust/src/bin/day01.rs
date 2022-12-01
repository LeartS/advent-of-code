use aoc2022;

fn part1() {
    let numbers: Vec<i32> = aoc2022::io::read_line_separated_values();
    println!("{:?}", numbers);
}

fn part2() {
    let numbers: Vec<i32> = aoc2022::io::read_space_separated_values();
    println!("{:?}", numbers);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
