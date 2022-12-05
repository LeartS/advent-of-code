use aoc2022;

fn part1_score((p1, p2): (char, char)) -> usize {
    match (p1, p2) {
        ('A', 'X') => 3 + 1,
        ('A', 'Y') => 6 + 2,
        ('A', 'Z') => 0 + 3,
        ('B', 'X') => 0 + 1,
        ('B', 'Y') => 3 + 2,
        ('B', 'Z') => 6 + 3,
        ('C', 'X') => 6 + 1,
        ('C', 'Y') => 0 + 2,
        ('C', 'Z') => 3 + 3,
        _ => panic!("unexpected!"),
    }
}

fn part2_score((p1, p2): (char, char)) -> usize {
    match (p1, p2) {
        ('A', 'X') => 0 + 3,
        ('A', 'Y') => 3 + 1,
        ('A', 'Z') => 6 + 2,
        ('B', 'X') => 0 + 1,
        ('B', 'Y') => 3 + 2,
        ('B', 'Z') => 6 + 3,
        ('C', 'X') => 0 + 2,
        ('C', 'Y') => 3 + 3,
        ('C', 'Z') => 6 + 1,
        _ => panic!("unexpected!"),
    }
}

fn parse_line(line: String) -> (char, char) {
    let mut chars = line.chars();
    let p1 = chars.next().expect("Line is missing first char");
    chars.next().expect("Line is missing second char");
    let p2 = chars.next().expect("Lines is missing third char");
    (p1, p2)
}

fn part1() {
    let res: usize = aoc2022::io::iterate_lines()
        .map(parse_line)
        .map(part1_score)
        .sum();
    println!("Total score is {}", res);
}

fn part2() {
    let res: usize = aoc2022::io::iterate_lines()
        .map(parse_line)
        .map(part2_score)
        .sum();
    println!("Total score is {}", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
