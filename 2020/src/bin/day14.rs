use std::io::{self, BufRead};
use std::collections::HashMap;

mod decoder_v1 {
    use itertools::Itertools;

    #[derive(Debug)]
    pub enum Command {
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

    pub fn parse_command(line: &str) -> Command {
        match &line[0..3] {
            "mas" => parse_mask(line),
            "mem" => parse_mem(line),
            _ => panic!("invalid command")
        }
    }
}

mod decoder_v2 {
    use std::iter::FromIterator;
    use itertools::Itertools;

    #[derive(Debug)]
    pub enum Command {
        Mem(u64, u64),
        Mask(Vec<(u64, u64)>),
    }

    fn parse_mask(line: &str) -> Command {
        let (_, mask) = line
            .split(" = ")
            .collect_tuple()
            .expect("invalid mask command");
        let v = mask.chars()
            .map(|c| match c {
                'X' => vec!['0', '1'],
                '1' => vec!['1'],
                '0' => vec!['X'],
                _ => panic!("unexpected char!")
            })
            .multi_cartesian_product()
            .map(|v| String::from_iter(v))
            .map(|m| {
                let mask_and = u64::from_str_radix(&m.replace("X", "1"), 2).unwrap();
                let mask_or = u64::from_str_radix(&m.replace("X", "0"), 2).unwrap();
                (mask_and, mask_or)
            })
            .collect_vec();
        Command::Mask(v)
    }

    fn parse_mem(line: &str) -> Command {
        match super::decoder_v1::parse_command(line) {
            super::decoder_v1::Command::Mem(addr, val) => Command::Mem(addr, val),
            _ => panic!("what??")
        }
    }

    pub fn parse_command(line: &str) -> Command {
        match &line[0..3] {
            "mas" => parse_mask(line),
            "mem" => parse_mem(line),
            _ => panic!("invalid command")
        }
    }
}


fn part1() {
    let mut memory: HashMap<u64, u64> = HashMap::new();
    let mut sum = 0u64;
    let mut mask = (0u64, 0u64);
    for command in io::stdin().lock().lines().map(|l| decoder_v1::parse_command(&l.unwrap())) {
        match command {
            decoder_v1::Command::Mem(addr, val) => {
                let masked_val = (val & mask.0) | mask.1;
                sum = sum + masked_val - memory.insert(addr, masked_val).unwrap_or(0u64);
            }
            decoder_v1::Command::Mask(m_and, m_or) => mask = (m_and, m_or)
        }
    }
    println!("{} is the sum of values in memory at the end", sum);
}

fn part2() {
    let mut memory: HashMap<u64, u64> = HashMap::new();
    let mut sum = 0u64;
    let mut masks: Vec<(u64, u64)> = vec![];
    for command in io::stdin().lock().lines().map(|l| decoder_v2::parse_command(&l.unwrap())) {
        match command {
            decoder_v2::Command::Mem(addr, val) => {
                for mask in &masks {
                    let masked_addr = (addr & mask.0) | mask.1;
                    sum = sum + val - memory.insert(masked_addr, val).unwrap_or(0u64);
                    // println!("wrote {} at memory address {}", val, masked_addr)
                }
            },
            decoder_v2::Command::Mask(new_masks) => masks = new_masks
        }
    }
    println!("{} is the sum of values in memory at the end", sum);
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
