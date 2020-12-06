use std::collections::HashSet;
use std::io::{self, Read};

const ALL_QUESTIONS: &str = "abcdefghijklmnopqrstuvwxyz";

fn everyone_yes_count(group_answers: &str) -> usize {
    group_answers
        .split_whitespace()
        .fold(
            ALL_QUESTIONS.chars().collect(),
            |all_yes: HashSet<char>, person_answers: &str| {
                person_answers
                    .chars()
                    .collect::<HashSet<char>>()
                    .intersection(&all_yes)
                    .cloned()
                    .collect()
            },
        )
        .len()
}

fn anyone_yes_count(group_answers: &str) -> usize {
    group_answers
        .split_whitespace()
        .flat_map(|p| p.chars())
        .collect::<HashSet<_>>()
        .len()
}

fn sum_groups_questions_count<F>(group_count: F) -> usize
where
    F: Fn(&str) -> usize,
{
    let mut input = String::new();
    io::stdin()
        .read_to_string(&mut input)
        .expect("Could not read input");

    input.split("\n\n").into_iter().map(group_count).sum()
}

fn part1() {
    let res = sum_groups_questions_count(anyone_yes_count);
    println!("{}", res);
}

fn part2() {
    let res = sum_groups_questions_count(everyone_yes_count);
    println!("{}", res);
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
