use itertools::Itertools;
use std::collections::VecDeque;

use aoc2022;

fn mix(numbers: &mut VecDeque<(usize, isize)>, n: usize) {
    let (index, &(original_index, n)) = numbers
        .iter()
        .find_position(|&&(original_position, _)| original_position == n)
        .expect("mmhh");
    match n {
        0 => (),
        _ => {
            let new_index = (index as isize + n).rem_euclid(numbers.len() as isize - 1) as usize;
            numbers.remove(index);
            numbers.insert(new_index, (original_index, n));
            // eprintln!("Moving {} from {} to {}", n, index, new_index);
        }
    }
}

fn decrypt(numbers: &VecDeque<isize>, decryption_key: usize, rounds: usize) -> VecDeque<isize> {
    let mut numbers_with_original_index: VecDeque<_> = numbers
        .iter()
        .copied()
        .map(|n| n * decryption_key as isize)
        .enumerate()
        .collect();
    for _r in 0..rounds {
        for i in 0..numbers.len() {
            // eprintln!("{:?}", numbers_with_original_index);
            mix(&mut numbers_with_original_index, i);
        }
    }
    // eprintln!("{:?}", numbers_with_original_index);
    numbers_with_original_index
        .into_iter()
        .map(|(_, n)| n)
        .collect()
}

fn at(numbers: &VecDeque<isize>, modular_index: usize) -> isize {
    numbers[modular_index % numbers.len()]
}

fn common_solution(decryption_key: usize, rounds: usize) {
    let numbers: VecDeque<isize> = aoc2022::io::read_line_separated_values();
    let decrypted = decrypt(&numbers, decryption_key, rounds);
    let zero_index = decrypted
        .iter()
        .find_position(|&&n| n == 0)
        .expect("No zero??")
        .0;
    let (a, b, c) = (
        at(&decrypted, zero_index + 1000),
        at(&decrypted, zero_index + 2000),
        at(&decrypted, zero_index + 3000),
    );
    println!("{} ({}, {}, {})", a + b + c, a, b, c);
}

fn part1() {
    common_solution(1, 1);
}

fn part2() {
    common_solution(811589153, 10);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
