use multiset::HashMultiSet;
use std::io::{self, BufRead};

fn find_couple_with_sum(numbers: &Vec<i32>, sum: i32) -> Option<(i32, i32)> {
    let number_set: HashMultiSet<i32> = numbers.iter().cloned().collect();
    numbers.iter().find_map(|&n1| {
        let n2 = sum - n1;
        match number_set.count_of(&n2) {
            c if n1 != n2 && c >= 1 => Some((n1, n2)),
            c if c >= 2 => Some((n1, n2)),
            _ => None
        }
    })
}

fn find_trouple_with_sum(numbers: &Vec<i32>, sum: i32) -> Option<(i32, i32, i32)> {
    let number_set: HashMultiSet<i32> = numbers.iter().cloned().collect();
    let mut sorted_numbers = numbers.to_owned();
    sorted_numbers.sort();
    for (i, &n1) in sorted_numbers[0..sorted_numbers.len() - 1]
        .iter()
        .enumerate()
    {
        for &n2 in &sorted_numbers[i + 1..numbers.len()] {
            let n3 = sum - (n1 + n2);
            match (n1, n2, n3, number_set.count_of(&n3)) {
                (n1, n2, n3, c) if (n1 != n3) && (n2 != n3) && c >= 1 => return Some((n1, n2, n3)),
                (n1, n2, n3, c) if (n1 == n3) ^ (n2 == n3) && c >= 2 => return Some((n1, n2, n3)),
                (n1, n2, n3, c) if (n1 == n2) && (n2 == n3) && c >= 3 => return Some((n1, n2, n3)),
                _ => continue
            }
        }
    }
    None
}

fn read_numbers() -> Vec<i32> {
   io::stdin()
        .lock()
        .lines()
        .map(|x| {
            x.expect("Could not read line!")
                .parse::<i32>()
                .expect("Line is not a valid integer")
        })
        .collect()
}

fn part1() {
    let numbers = read_numbers();
    match find_couple_with_sum(&numbers, 2020) {
        Some((n1, n2)) => println!("{} ({}, {})", n1*n2, n1, n2),
        None => println!("Couldn't find any 2 numbers that sum up to 2020"),
    }
}


fn part2() {
    let numbers = read_numbers();
    match find_trouple_with_sum(&numbers, 2020) {
        Some((n1, n2, n3)) => println!("{} ({}, {}, {})", n1 * n2 * n3, n1, n2, n3),
        None => println!("Couldn't find any 3 entries that sum up to 2020"),
    }
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
