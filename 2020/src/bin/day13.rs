use itertools::Itertools;
use std::io::{self, Read};

fn bus_departure_time(prev_departure_time: u64, prev_cycle_time: u64, bus_cycle_time: u64) -> u64 {
    let mut timestamp = prev_departure_time + 1;
    std::iter::from_fn(|| {
        timestamp += prev_cycle_time;
        Some(timestamp)
    })
    .find(|t| t % bus_cycle_time == 0)
    .expect("something strange happened")
}

fn first_departure_after(bus_cycle: u64, earliest_departure: u64) -> u64 {
    (earliest_departure as f64 / bus_cycle as f64).ceil() as u64 * bus_cycle
}

fn part1(earliest_departure: u64, buses: &Vec<u64>) {
    let (bus_id, departure_time) = buses
        .iter()
        .filter(|b| **b != 0)
        .map(|b| (b, first_departure_after(*b, earliest_departure)))
        .min_by_key(|x| x.1)
        .expect("No buses?");
    let waiting_time = bus_id * (departure_time - earliest_departure);
    println!(
        "{} (depart at {} with bus {})",
        waiting_time, departure_time, bus_id
    );
}

fn part2(buses: &Vec<u64>) {
    let (last_bus_departure_time, cycle_time) = buses
        .iter()
        .skip(1)
        .fold((0u64, buses[0]), |(acc_departure_time, acc_cycle_time), &bus| {
            match bus {
                0 => (acc_departure_time + 1, acc_cycle_time),
                _ => (
                    bus_departure_time(acc_departure_time, acc_cycle_time, bus),
                    // all bus cycle times are prime => their product is coprime with new bus
                    // => the new total cycle time is simply prev_cycle_time * bus_cycle_time
                    acc_cycle_time * bus,
                ),
            }
        },
    );
    print!(
        "{:?} is the first bus departure time that satisfy constraints (cycles every {})",
        last_bus_departure_time - buses.len() as u64 + 1, cycle_time
    );
}

pub fn main() {
    let mut input = String::new();
    io::stdin()
        .read_to_string(&mut input)
        .expect("Could not read from stdin");
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
