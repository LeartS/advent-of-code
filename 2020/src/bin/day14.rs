use itertools::Itertools;
use std::io::{self, BufRead};
use std::collections::HashMap;

#[derive(Debug)]
enum Command {
    Mem(u64, u64),
    Mask(u64, u64),
}

fn parse_mask(line: &str) -> Command {
    let (_, mask) = line
        .split(" = ")
        .collect_tuple()
        .expect("invalid mask command");
    let mask_and = u64::from_str_radix(&mask.replace("X", "1"), 2).unwrap();
    let mask_or = u64::from_str_radix(&mask.replace("X", "0"), 2).unwrap();
    Command::Mask(mask_and, mask_or)
}

fn parse_mem(line: &str) -> Command {
    let (a, b) = line.splitn(2, " = ").collect_tuple().expect("invalid line");
    let value: u64 = b.parse().expect("invalid value");
    let address: u64 = a[4..a.len()-1].parse().expect("invalid address");
    Command::Mem(address, value)
}

fn parse_command(line: &str) -> Command {
    match &line[0..3] {
        "mas" => parse_mask(line),
        "mem" => parse_mem(line),
        _ => panic!("invalid command")
    }
}

fn part1() {
    let mut memory: HashMap<u64, u64> = HashMap::new();
    let mut sum = 0u64;
    let mut mask = (0u64, 0u64);
    for command in io::stdin().lock().lines().map(|l| parse_command(&l.unwrap())) {
        match command {
            Command::Mem(addr, val) => {
                let masked_val = (val & mask.0) | mask.1;
                sum = sum + masked_val - memory.insert(addr, masked_val).unwrap_or(0u64);
            }
            Command::Mask(m_and, m_or) => mask = (m_and, m_or)
        }
    }
    println!("{} is the sum of values in memory at the end", sum);
}

fn part2() {
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
