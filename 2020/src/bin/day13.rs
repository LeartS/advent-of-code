use std::io::{self, Read};
use itertools::Itertools;

fn find_timestamp(start: u64, cycle: u64, bus: u64) -> (u64, u64) {
    // println!("{} + {}n = 0 (mod {})", start, cycle, bus);
    let mut timestamp = start;
    std::iter::from_fn(|| {
        timestamp += cycle;
        Some(timestamp)
    })
        .find(|n| n % bus == 0)
        // all bus ids are prime => all cycle lengths are coprime
        // => the new cycle length is simply old_cycle_length * bus_cycle_length
        .map(|n| (n, cycle * bus))
        .expect("something strange happened")
}

fn part1(earliest_departure: u64, buses: &Vec<u64>) {
    let (bus_id, departure_time) = buses
        .iter()
        .filter(|b| **b != 0)
        .map(|b| (b, ((earliest_departure as f64 / *b as f64).ceil() as u64) * b))
        .min_by_key(|x| x.1)
        .expect("Boh");
    println!(
        "{} (depart at {} with bus {})",
        bus_id * (departure_time - earliest_departure), departure_time, bus_id);
}

fn part2(buses: &Vec<u64>) {
    let (timestamp, _cycle) = buses
        .iter()
        .skip(1)
        .fold((0u64, buses[0]), |acc, bus| {
            match bus {
                0 => (acc.0 + 1, acc.1),
                _ => find_timestamp(acc.0 + 1 as u64, acc.1, *bus)
            }
        });
    print!("{:?} is the desired timestamp", timestamp - buses.len() as u64 + 1);
}

pub fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("Could not read from stdin"); 
    let (a, b) = input.lines().collect_tuple().expect("invalid input");
    let earliest_departure: u64 = a.parse().expect("invalid timestamp");
    // 'x' are converted to 0
    let buses: Vec<u64> = b
        .split(',')
        .map(|sn| sn.parse::<u64>().unwrap_or(0))
        .collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(earliest_departure, &buses),
        Some(p) if p == "part2" => part2(&buses),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}

