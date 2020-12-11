use regex::Regex;
use std::io::{self, BufRead};

type Rule = (char, (usize, usize));

fn check_valid_password(rule: Rule, password: &str) -> bool {
    let (required_char, (min, max)) = rule;
    match password.matches(required_char).count() {
        c if c >= min && c <= max => true,
        _ => false,
    }
}

fn check_valid_password_positions(rule: Rule, password: &str) -> bool {
    let (required_char, (min, max)) = rule;
    let bytestring = password.as_bytes();
    match (
        required_char,
        bytestring[min - 1] as char,
        bytestring[max - 1] as char,
    ) {
        (wanted, c1, c2) if (c1 == wanted) ^ (c2 == wanted) => true,
        _ => false,
    }
}

fn parse_line<'a>(password_line: &'a str) -> Result<(Rule, &'a str), &'static str> {
    let re = Regex::new(r"^(\d+)-(\d+) (\w): (\w+)$").unwrap();
    match re.captures(password_line) {
        Some(captures) => {
            let start = captures
                .get(1)
                .map(|s| s.as_str().parse::<usize>().unwrap())
                .unwrap();
            let end = captures
                .get(2)
                .map(|s| s.as_str().parse::<usize>().unwrap())
                .unwrap();
            Ok((
                (
                    captures.get(3).unwrap().as_str().chars().next().unwrap(),
                    (start, end),
                ),
                captures.get(4).unwrap().as_str(),
            ))
        }
        None => Err("Invalid line"),
    }
}

fn count_valid_passwords<P>(password_checker: P) -> usize
where
    P: Fn(Rule, &str) -> bool,
{
    io::stdin()
        .lock()
        .lines()
        .filter(|l| {
            let line = l.as_ref().expect("Could not read line").as_str();
            let (rule, password) = parse_line(&line).expect("invalid line");
            password_checker(rule, password)
        })
        .count()
}

fn part1() {
    let valid_count = count_valid_passwords(check_valid_password);
    println!("{} valid passwords", valid_count);
}

fn part2() {
    let valid_count = count_valid_passwords(check_valid_password_positions);
    println!("{} valid passwords", valid_count);
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
