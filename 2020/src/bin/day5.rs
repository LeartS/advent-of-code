use std::io::{self, BufRead};
use itertools::Itertools;

fn seat_id(seat: (usize, usize)) -> usize {
    seat.0 * 8 + seat.1
}

fn decode_seat(pass_code: &str) -> (usize, usize) {
    let (row, col) = pass_code.split_at(7);
    let row = row.chars().fold(0, |acc, c| {
        match c {
            'F' => acc * 2,
            'B' => acc * 2 + 1,
            _ => panic!("Invalid boarding pass!")
        }
    });
    let col = col.chars().fold(0, |acc, c| {
        match c {
            'L' => acc * 2,
            'R' => acc * 2 + 1,
            _ => panic!("Invalid boarding pass!")
        }
    });
    (row, col)
}

fn part1() {
    let max_seat_id = io::stdin()
        .lock()
        .lines()
        .map(|l| decode_seat(&l.unwrap()))
        .map(seat_id)
        .max()
        .expect("No boarding passes!");
    println!("Max seat id: {}", max_seat_id);
}

fn part2() {
    let my_seat_id = io::stdin()
        .lock()
        .lines()
        .map(|l| decode_seat(&l.unwrap()))
        .map(seat_id)
        .sorted()
        .tuple_windows::<(_, _, _)>()
        .find_map(|(p, c, n)| if c == p+2 && n == c+1 { Some(p+1) } else { None } )
        .expect("Could not find any row with a single empty seat!");
    println!("My seat id is: {}", my_seat_id);
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
