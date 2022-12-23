use std::fmt::{Debug, Display};
use std::io::{self, BufRead};
use std::str::FromStr;

use itertools::Itertools;

pub fn iterate_lines() -> impl Iterator<Item = String> {
    io::stdin()
        .lock()
        .lines()
        .map(|line| line.expect("could not read line"))
}

pub fn read_matrix() -> Vec<Vec<isize>> {
    io::stdin()
        .lock()
        .lines()
        .map(|line| {
            line.unwrap()
                .chars()
                .map(|c| c.to_digit(10).expect("Invalid digit") as isize)
                .collect()
        })
        .collect()
}

pub fn read_line_separated_values<T>() -> Vec<T>
where
    T: FromStr,
    <T as FromStr>::Err: Debug,
{
    io::stdin()
        .lock()
        .lines()
        .map(|x| {
            x.expect("Could not read line!")
                .parse::<T>()
                .expect("Could not parse value")
        })
        .collect()
}

pub fn print_matrix<T: Display>(matrix: &Vec<Vec<T>>) -> String {
    matrix.iter().map(|row| row.into_iter().format("")).format("\n").to_string()
}

pub fn read_space_separated_values<T>() -> Vec<T>
where
    T: FromStr,
    <T as FromStr>::Err: Debug,
{
    let mut buffer = String::new();
    io::stdin()
        .lock()
        .read_line(&mut buffer)
        .expect("Could not read input line");

    buffer
        .trim()
        .split(" ")
        .map(|x| x.parse::<T>().expect("Could not parse value"))
        .collect::<Vec<T>>()
}
