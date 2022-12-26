use std::{io, str::FromStr};

use aoc2022;
use itertools::Itertools;

#[derive(Clone, Copy, Debug)]
enum Operand {
    Number(usize),
    Old,
}

#[derive(Clone, Copy, Debug)]
enum Operator {
    Add,
    Sub,
    Mul,
}

type Operation = (Operator, Operand);

#[derive(Debug)]
struct Monkey {
    items: Vec<usize>,
    operation: Operation,
    test: usize,
    if_true: usize,
    if_false: usize,
}

impl FromStr for Monkey {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        println!("{}", s);
        let (_, items_line, operation_line, test_line, if_true_line, if_false_line) = s
            .lines()
            .collect_tuple()
            .expect("Invalid monkey definition");
        let items = items_line
            .rsplit(": ")
            .next()
            .unwrap()
            .split(", ")
            .map(|n_s| n_s.parse::<usize>().expect("invalid item"))
            .collect_vec();
        let (operand_s, operator_s, _) = operation_line
            .rsplitn(3, " ")
            .collect_tuple()
            .expect("Invalid operation");
        let operator = match operator_s {
            "*" => Operator::Mul,
            "+" => Operator::Add,
            "-" => Operator::Sub,
            _ => panic!("Invalid operator"),
        };
        let operand = match operand_s {
            "old" => Operand::Old,
            n_s => Operand::Number(n_s.parse().expect("Invalid operand")),
        };
        let operation = (operator, operand);
        let test = test_line
            .rsplit_once(" ")
            .expect("Invalid test")
            .1
            .parse::<usize>()
            .expect("Invalid test");
        let if_true = if_true_line
            .rsplit_once(" ")
            .expect("Invalid if_true")
            .1
            .parse::<usize>()
            .expect("Invalid if_true");
        let if_false = if_false_line
            .rsplit_once(" ")
            .expect("Invalid if_false")
            .1
            .parse::<usize>()
            .expect("Invalid if_false");
        Ok(Self {
            items,
            operation,
            test,
            if_true,
            if_false,
        })
    }
}

fn part1() {
    let mut monkeys: Vec<Monkey> = io::read_to_string(io::stdin())
        .unwrap()
        .split("\n\n")
        .map(|s| s.parse().expect("Invalid monkey definition"))
        .collect_vec();
    let mut inspections = vec![0; monkeys.len()];
    for _round in 1..=20 {
        for monkey_index in 0..monkeys.len() {
            let Monkey {
                test,
                if_true,
                if_false,
                operation,
                ..
            } = monkeys[monkey_index];
            let items = monkeys[monkey_index].items.clone();
            inspections[monkey_index] += items.len();
            for item in items {
                let worry = match operation {
                    (Operator::Mul, Operand::Old) => (item * item) / 3,
                    (Operator::Add, Operand::Old) => (item + item) / 3,
                    (Operator::Sub, Operand::Old) => (item - item) / 3,
                    (Operator::Mul, Operand::Number(n)) => (item * n) / 3,
                    (Operator::Add, Operand::Number(n)) => (item + n) / 3,
                    (Operator::Sub, Operand::Number(n)) => (item - n) / 3,
                };
                monkeys[monkey_index].items.pop();
                match worry % test {
                    0 => &monkeys[if_true].items.push(worry),
                    _n => &monkeys[if_false].items.push(worry),
                };
            }
        }
    }
    let res: usize = inspections.iter().sorted().rev().take(2).product();
    println!("Monkey business {}", res);
}

fn part2() {
    let mut monkeys: Vec<Monkey> = io::read_to_string(io::stdin())
        .unwrap()
        .split("\n\n")
        .map(|s| s.parse().expect("Invalid monkey definition"))
        .collect_vec();
    let mut inspections = vec![0; monkeys.len()];
    let lcm: usize = monkeys.iter().map(|monkey| monkey.test).product();
    for _round in 1..=10000 {
        for monkey_index in 0..monkeys.len() {
            let Monkey {
                test,
                if_true,
                if_false,
                operation,
                ..
            } = monkeys[monkey_index];
            let items = monkeys[monkey_index].items.clone();
            inspections[monkey_index] += items.len();
            for item in items {
                let worry = match operation {
                    (Operator::Mul, Operand::Old) => (item * item) % lcm,
                    (Operator::Add, Operand::Old) => (item + item) % lcm,
                    (Operator::Sub, Operand::Old) => (item - item) % lcm,
                    (Operator::Mul, Operand::Number(n)) => (item * n) % lcm,
                    (Operator::Add, Operand::Number(n)) => (item + n) % lcm,
                    (Operator::Sub, Operand::Number(n)) => (item - n) % lcm,
                };
                monkeys[monkey_index].items.pop();
                match worry % test {
                    0 => &monkeys[if_true].items.push(worry),
                    _n => &monkeys[if_false].items.push(worry),
                };
            }
        }
    }
    let res: usize = inspections.iter().sorted().rev().take(2).product();
    println!("Monkey business {}", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
