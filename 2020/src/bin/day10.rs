use std::io::{self, BufRead};
use itertools::Itertools;

fn part1(adapters: &Vec<isize>) {
    let mut diff1 = 0;
    let mut diff3 = 0;
    for (n1, n2) in adapters.into_iter().sorted().tuple_windows::<(_, _)>() {
        match n2 - n1 {
            1 => diff1 += 1,
            2 => {},
            3 => diff3 += 1,
            _ => panic!("invalid diff!")
        }
    }
    println!("{} ({} * {})", diff1 * diff3, diff1, diff3);
}


fn part2(adapters: &Vec<isize>) {
    let mut arrangements: Vec<u64> = vec![0; adapters.len()];
    arrangements[0] = 1;
    for (i, joltage) in adapters.iter().enumerate().skip(1) {
        for d in 1..=3 {
            if d > i || adapters[i-d] < joltage - 3 { continue; }
            arrangements[i] += arrangements[i-d];
        }
    }
    println!("{} possible adapters arrangements", arrangements.last().unwrap());
}

pub fn main() {
    let stdin = io::stdin();
    let a = stdin.lock().lines().map(|l| l.unwrap().parse::<isize>().unwrap());
    let mut adapters: Vec<isize> = std::iter::once(0).chain(a).sorted().collect();
    adapters.push(adapters.last().unwrap() + 3);
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&adapters),
        Some(p) if p == "part2" => part2(&adapters),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
