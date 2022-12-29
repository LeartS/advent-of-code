use std::fmt::{Debug, Display};
use std::io::{self, BufRead};
use std::iter::FromIterator;
use std::str::FromStr;

use itertools::Itertools;

pub fn iterate_lines() -> impl Iterator<Item = String> {
    io::stdin()
        .lock()
        .lines()
        .map(|line| line.expect("could not read line"))
}

pub fn read_matrix<T>(parse: fn(char) -> T) -> Vec<Vec<T>> {
    io::stdin()
        .lock()
        .lines()
        .map(|line| line.unwrap().chars().map(parse).collect())
        .collect()
}

pub fn read_line_separated_values<C, T>() -> C
where
    C: FromIterator<T>,
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
    matrix
        .iter()
        .map(|row| row.into_iter().format(""))
        .format("\n")
        .to_string()
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
