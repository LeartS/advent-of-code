use std::fmt::Debug;
use std::io::Lines;
use std::io::{self, BufRead, StdinLock};
use std::str::FromStr;

pub fn iterate_lines() -> Lines<StdinLock<'static>> {
    io::stdin().lock().lines()
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
