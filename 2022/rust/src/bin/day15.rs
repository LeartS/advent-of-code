#[macro_use]
extern crate lazy_static;

use std::{collections::HashSet, iter::FromIterator};

use itertools::Itertools;
use regex::Regex;

use aoc2022;

type XY = (isize, isize);

const REFERENCE_Y: isize = 2_000_000;

lazy_static! {
    static ref RE: Regex = Regex::new(
        r"^Sensor at x=([-\d]+), y=([-\d]+): closest beacon is at x=([-\d]+), y=([-\d]+)$"
    )
    .unwrap();
}

fn parse(line: &str) -> (XY, XY) {
    let caps = RE.captures(line).expect("Invalid input line");
    let (sx, sy, bx, by) = caps
        .iter()
        .skip(1)
        .map(|c| c.unwrap().as_str().parse::<isize>().unwrap())
        .collect_tuple()
        .unwrap();
    ((sx, sy), (bx, by))
}

fn join_overlapping_intervals(intervals: &Vec<(isize, isize)>) -> Vec<(isize, isize)> {
    let disjoint = intervals.iter().sorted().fold(
        vec![(isize::MIN, isize::MIN)],
        |mut disjoint, &(start, end)| {
            let n = disjoint.len();
            let (_prev_start, prev_end) = disjoint[n - 1];
            match (start, end, prev_end) {
                (_s, e, pe) if e <= pe => (),
                (s, _e, pe) if s > pe => disjoint.push((start, end)),
                (s, e, pe) if s <= pe && e > pe => disjoint[n - 1].1 = e,
                (s, e, pe) => panic!("Unexpected situation: s={}, e={}, pe={}", s, e, pe),
            }
            disjoint
        },
    );
    disjoint[1..].to_vec()
}

fn part1() {
    let scan = aoc2022::io::iterate_lines()
        .map(|line| parse(line.as_str()))
        .collect_vec();

    let beacons: HashSet<(isize, isize)> =
        HashSet::from_iter(scan.iter().map(|&(_sensor, beacon)| beacon));

    let intervals = scan
        .iter()
        .filter_map(|&(sensor, beacon)| {
            let closest_beacon_distance = aoc2022::grid::taxicab_distance(sensor, beacon);
            let vertical_distance = sensor.1.abs_diff(REFERENCE_Y) as isize;
            println!(
                "Sensor: {:?}, beacon: {:?}, distance: {}, vertical_distance: {}",
                sensor, beacon, closest_beacon_distance, vertical_distance
            );
            match closest_beacon_distance - vertical_distance {
                leftover if leftover <= 0 => None,
                leftover => Some((sensor.0 - leftover, sensor.0 + leftover)),
            }
        })
        .collect_vec();

    eprintln!("raw intervals: {:?}", intervals);
    let disjointed = join_overlapping_intervals(&intervals);
    eprintln!("disjointed intervals: {:?}", disjointed);
    let res: isize = disjointed
        .into_iter()
        .map(|(start, end)| {
            let n_beacons = beacons
                .iter()
                .filter(|&&(x, y)| y == REFERENCE_Y && x >= start && x <= end)
                .count();
            end - start + 1 - n_beacons as isize
        })
        .sum();
    println!("Number of positions that cannot contain a beacon: {}", res);
}

fn part2() {
    todo!();
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
