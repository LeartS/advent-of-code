use itertools::Itertools;
use std::collections::{HashSet, VecDeque};

use aoc2022;

type Coord = (isize, isize, isize);

fn adjacents((x, y, z): Coord) -> Vec<Coord> {
    vec![
        (x - 1, y, z),
        (x + 1, y, z),
        (x, y - 1, z),
        (x, y + 1, z),
        (x, y, z - 1),
        (x, y, z + 1),
    ]
}

fn precompute_reachable_air(cubes: &HashSet<Coord>) -> HashSet<Coord> {
    let (mut min_x, mut min_y, mut min_z) = (isize::MAX, isize::MAX, isize::MAX);
    let (mut max_x, mut max_y, mut max_z) = (isize::MIN, isize::MIN, isize::MIN);
    for (x, y, z) in cubes {
        min_x = min_x.min(x - 1);
        min_y = min_y.min(y - 1);
        min_z = min_z.min(z - 1);
        max_x = max_x.max(x + 1);
        max_y = max_y.max(y + 1);
        max_z = max_z.max(z + 1);
    }
    let mut reachable: HashSet<Coord> = HashSet::new();
    let mut queue: VecDeque<Coord> = VecDeque::from([(min_x, min_y, min_z)]);
    while !queue.is_empty() {
        let air = queue.pop_front().unwrap();
        for (x, y, z) in adjacents(air) {
            if (min_x..=max_x).contains(&x)
                && (min_y..=max_y).contains(&y)
                && (min_x..=max_z).contains(&z)
                && !reachable.contains(&(x, y, z))
                && !cubes.contains(&(x, y, z))
            {
                reachable.insert((x, y, z));
                queue.push_back((x, y, z));
            }
        }
    }
    reachable
}

fn read_cubes() -> HashSet<Coord> {
    aoc2022::io::iterate_lines()
        .map(|line| {
            line.split(",")
                .map(|n| n.parse().expect("invalid coordinate"))
                .collect_tuple()
                .expect("invalid input line")
        })
        .collect()
}

fn part1() {
    let cubes = read_cubes();
    let surface_area = cubes
        .iter()
        .flat_map(|c| adjacents(*c))
        .filter(|c| !cubes.contains(&c))
        .count();
    println!("Surface area is {}", surface_area);
}

fn part2() {
    let cubes = read_cubes();
    let reachable_air = precompute_reachable_air(&cubes);
    let reachable_surface_area = cubes
        .iter()
        .flat_map(|c| adjacents(*c))
        .filter(|c| reachable_air.contains(c))
        .count();
    println!("Total reachable surface area is {}", reachable_surface_area);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
