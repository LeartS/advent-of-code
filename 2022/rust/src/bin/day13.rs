use itertools::{self, Itertools};
use std::cmp::Ordering;

use aoc2022;

fn number_at(s: &[char], start_index: usize) -> (usize, usize) {
    let mut n = 0;
    let mut i = start_index;
    while s[i].is_digit(10) {
        n *= 10;
        n += s[i].to_digit(10).unwrap();
        i += 1;
    }
    (n as usize, i - start_index)
}

fn in_right_order(left: &[char], right: &[char]) -> bool {
    let mut pl = 0;
    let mut pr = 0;
    let mut ghost_right = 0;
    let mut ghost_left = 0;
    while pl < left.len() && pr < right.len() {
        // eprintln!(
        //     "Comparing {} against {} (ghost_left: {}, ghost_right: {})",
        //     left[pl], right[pr], ghost_left, ghost_right
        // );
        match (left[pl], right[pr]) {
            ('0'..='9', '0'..='9') => {
                let (left_number, left_used_chars) = number_at(left, pl);
                let (right_number, right_used_chars) = number_at(right, pr);
                match left_number.cmp(&right_number) {
                    Ordering::Equal => {
                        pl += left_used_chars;
                        pr += right_used_chars;
                    }
                    Ordering::Less => return true,
                    Ordering::Greater => return false,
                }
            }
            (',', _) if ghost_right > 0 => return false,
            (']', ',') if ghost_right > 0 => {
                ghost_right -= 1;
                pl += 1;
            }
            (_, ',') if ghost_left > 0 => return true,
            (',', ']') if ghost_left > 0 => {
                ghost_left -= 1;
                pr += 1;
            }
            (l, r) if l == r => {
                pl += 1;
                pr += 1;
            }
            (']', _) => return true,
            (_, ']') => return false,
            (',', '[') => return true,
            ('[', ',') => return false,
            ('[', '0'..='9') => {
                ghost_right += 1;
                pl += 1;
            }
            ('0'..='9', '[') => {
                ghost_left += 1;
                pr += 1;
            }
            _ => panic!("unexpected situation"),
        }
    }
    pl == left.len()
}

fn part1() {
    let s = std::io::read_to_string(std::io::stdin()).expect("Could not read input");
    let r: usize = s
        .split("\n\n")
        .map(|group| group.lines().collect_tuple().expect("Invalid group"))
        .enumerate()
        .filter(|(i, (left, right))| {
            let is = in_right_order(&left.chars().collect_vec(), &right.chars().collect_vec());
            eprintln!("{}", left);
            eprintln!("{}", right);
            println! {"{} In right order: {}", i, if is { "YES" } else {"NO"}};
            eprintln!();
            is
        })
        .map(|(i, _)| i + 1)
        .sum();
    println!("Sum of indices of pairs in order is {}", r);
}

fn part2() {
    let r: usize = aoc2022::io::iterate_lines()
        .chain(vec![String::from("[[2]]"), String::from("[[6]]")])
        .filter(|line| line.trim().len() > 0)
        .sorted_by(|packet_a, packet_b| {
            match in_right_order(
                &packet_a.chars().collect_vec(),
                &packet_b.chars().collect_vec(),
            ) {
                true => Ordering::Less,
                false => Ordering::Greater,
            }
        })
        .enumerate()
        .filter(|(_i, packet)| packet == "[[2]]" || packet == "[[6]]")
        .map(|(i, _)| i + 1)
        .product();
    println!("Decoder key: {}", r);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
