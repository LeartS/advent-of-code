use aoc2022;
use itertools::Itertools;
use std::collections::HashSet;

#[derive(Copy, Clone)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}
type Motion = (Direction, u8);
type Pos = (isize, isize);

fn parse_line(line: &str) -> Motion {
    let (direction, steps_str) = line.split(" ").collect_tuple().expect("Invalid line");
    let steps: u8 = steps_str.parse().expect("Invalid number of steps");
    match direction {
        "U" => (Direction::Up, steps),
        "R" => (Direction::Right, steps),
        "D" => (Direction::Down, steps),
        "L" => (Direction::Left, steps),
        direction => panic!("Invalid motion direction: {}", direction),
    }
}

fn expand_motion(motion: Motion) -> impl Iterator<Item = Motion> {
    (1..=motion.1).map(move |_| (motion.0, 1))
}

fn apply_motion((x, y): Pos, motion: Motion) -> Pos {
    match motion {
        (Direction::Up, steps) => (x, y + steps as isize),
        (Direction::Down, steps) => (x, y - steps as isize),
        (Direction::Right, steps) => (x + steps as isize, y),
        (Direction::Left, steps) => (x - steps as isize, y),
    }
}

fn follow((prev_x, prev_y): Pos, (knot_x, knot_y): Pos) -> Pos {
    match (prev_x - knot_x, prev_y - knot_y) {
        (-1..=1, -1..=1) => (knot_x, knot_y),
        diffs @ (-2..=2, -2..=2) => (knot_x + diffs.0.signum(), knot_y + diffs.1.signum()),
        diffs => panic!(
            "Knot is too far from previous one! {:?} [{:?}]",
            diffs,
            (prev_x, prev_y)
        ),
    }
}

fn generic_solution(n_knots: usize) {
    let mut knot_positions: Vec<(isize, isize)> = vec![(0, 0); n_knots];
    let mut unique_tail_positions: HashSet<Pos> = HashSet::from_iter(vec![(0, 0)]);
    for motion in aoc2022::io::iterate_lines()
        .map(|l| parse_line(l.as_str()))
        .flat_map(|m| expand_motion(m))
    {
        knot_positions[0] = apply_motion(knot_positions[0], motion);
        for knot in 1..n_knots {
            knot_positions[knot] = follow(knot_positions[knot - 1], knot_positions[knot]);
        }
        unique_tail_positions.insert(knot_positions[n_knots - 1]);
    }
    println!(
        "Tail has been in {} unique positions",
        unique_tail_positions.len()
    );
}

fn part1() {
    generic_solution(2);
}

fn part2() {
    generic_solution(10);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
