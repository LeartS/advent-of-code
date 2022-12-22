use nom::branch::alt;
use nom::bytes::complete::{tag, take_while1};
use nom::character::complete::char;
use nom::combinator::{eof, map, map_res, opt};
use nom::sequence::{pair, terminated};
use nom::IResult;

use aoc2022;

enum Instruction {
    Addx(isize),
    Noop,
}

fn natural(input: &str) -> IResult<&str, isize> {
    map_res(take_while1(|c: char| c.is_digit(10)), |l: &str| {
        l.parse::<isize>()
    })(input)
}

fn integer(i: &str) -> IResult<&str, isize> {
    map(
        pair(opt(char('-')), natural),
        |(sign, natural)| match sign {
            Some(_) => -natural,
            None => natural,
        },
    )(i)
}

fn addx(i: &str) -> IResult<&str, Instruction> {
    map(pair(tag("addx "), integer), |(_, n)| Instruction::Addx(n))(i)
}

fn noop(i: &str) -> IResult<&str, Instruction> {
    map(tag("noop"), |_| Instruction::Noop)(i)
}

fn instruction(i: &str) -> IResult<&str, Instruction> {
    terminated(alt((addx, noop)), eof)(i)
}

fn parse_line(line: &str) -> Instruction {
    instruction(line)
        .map(|(_rest, instr)| instr)
        .expect("Invalid input line")
}

fn compute_register_history() -> [isize; 256] {
    let mut history = [1_isize; 256];
    aoc2022::io::iterate_lines()
        .map(|line| parse_line(&line))
        .scan((1, 1), |state, instr| match instr {
            Instruction::Noop => {
                state.0 += 1;
                Some(*state)
            }
            Instruction::Addx(n) => {
                state.0 += 2;
                state.1 += n;
                Some(*state)
            }
        })
        .for_each(|(cycle, register_value)| history[cycle..].fill(register_value));
    history
}

fn part1() {
    let history = compute_register_history();
    let mut total = 0;
    for i in vec![20, 60, 100, 140, 180, 220] {
        let s = i as isize * history[i];
        eprintln!("{}: {}", i, s);
        total += s;
    }
    println!("Total signal strength is {}", total);
}

fn part2() {
    let history = compute_register_history();
    for row in 0..6 {
        for col in 0..40 {
            let cycle = row * 40 + col + 1;
            print!(
                "{}",
                if history[cycle].abs_diff(col as isize) <= 1 {
                    '#'
                } else {
                    '.'
                }
            )
        }
        println!("")
    }
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
