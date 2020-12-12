use core::panic;
use std::io::{self, BufRead};

#[derive(Clone, Copy, Debug)]
enum Direction {
    North,
    East,
    South,
    West,
}

#[derive(Clone, Debug)]
struct State {
    direction: Direction,
    ship: (isize, isize),
    waypoint: (isize, isize),
}

#[derive(Clone, Copy, Debug)]
enum Command {
    N(isize),
    S(isize),
    E(isize),
    W(isize),
    L(isize),
    R(isize),
    F(isize),
}

fn rotate_ship(ship_direction: Direction, degrees: isize) -> Direction {
    (0..(degrees.abs() / 90)).fold(ship_direction, |dir, _| {
        match (dir, degrees.is_negative()) {
            (Direction::North, false) => Direction::East,
            (Direction::East, false) => Direction::South,
            (Direction::South, false) => Direction::West,
            (Direction::West, false) => Direction::North,
            (Direction::North, true) => Direction::West,
            (Direction::East, true) => Direction::North,
            (Direction::South, true) => Direction::East,
            (Direction::West, true) => Direction::South,
        }
    })
}

fn rotate_waypoint(waypoint: (isize, isize), degrees: isize) -> (isize, isize) {
    (0..(degrees.abs() / 90)).fold(waypoint, |(rel_x, rel_y), _| {
        if degrees.is_positive() {
            (-rel_y, rel_x)
        } else {
            (rel_y, -rel_x)
        }
    })
}

fn move_part1(mut state: State, command: &Command) -> State {
    match *command {
        Command::N(v) => state.ship.1 -= v,
        Command::S(v) => state.ship.1 += v,
        Command::E(v) => state.ship.0 += v,
        Command::W(v) => state.ship.0 -= v,
        Command::L(v) => state.direction = rotate_ship(state.direction, -v),
        Command::R(v) => state.direction = rotate_ship(state.direction, v),
        Command::F(v) => match state.direction {
            Direction::North => return move_part1(state, &Command::N(v)),
            Direction::East => return move_part1(state, &Command::E(v)),
            Direction::South => return move_part1(state, &Command::S(v)),
            Direction::West => return move_part1(state, &Command::W(v)),
        },
    };
    state
}

fn move_part2(mut state: State, command: &Command) -> State {
    match *command {
        Command::N(v) => state.waypoint.1 -= v,
        Command::S(v) => state.waypoint.1 += v,
        Command::E(v) => state.waypoint.0 += v,
        Command::W(v) => state.waypoint.0 -= v,
        Command::L(v) => state.waypoint = rotate_waypoint(state.waypoint, -v),
        Command::R(v) => state.waypoint = rotate_waypoint(state.waypoint, v),
        Command::F(v) => {
            state.ship = (
                state.ship.0 + state.waypoint.0 * v,
                state.ship.1 + state.waypoint.1 * v,
            )
        }
    }
    state
}

fn parse_command(cmd: &str) -> Command {
    let (c, value) = cmd.split_at(1);
    match (c.chars().next(), value.parse::<isize>()) {
        (Some('N'), Ok(v)) => Command::N(v),
        (Some('E'), Ok(v)) => Command::E(v),
        (Some('S'), Ok(v)) => Command::S(v),
        (Some('W'), Ok(v)) => Command::W(v),
        (Some('L'), Ok(v)) => Command::L(v),
        (Some('R'), Ok(v)) => Command::R(v),
        (Some('F'), Ok(v)) => Command::F(v),
        _ => panic!(&format!("Invalid command string {}", cmd)),
    }
}

fn l1_distance(coordinates: (isize, isize)) -> isize {
    coordinates.0.abs() + coordinates.1.abs()
}

fn part1(commands: &Vec<Command>) {
    let state = State {
        ship: (0, 0),
        waypoint: (10, -1),
        direction: Direction::East,
    };
    let final_state = commands.iter().fold(state, move_part1);
    println!("{}", l1_distance(final_state.ship));
}

fn part2(commands: &Vec<Command>) {
    let state = State {
        ship: (0, 0),
        waypoint: (10, -1),
        direction: Direction::East,
    };
    let final_state = commands.iter().fold(state, move_part2);
    println!("{}", l1_distance(final_state.ship));
}

pub fn main() {
    let commands: Vec<Command> = io::stdin()
        .lock()
        .lines()
        .map(|l| parse_command(l.unwrap().as_str()))
        .collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&commands),
        Some(p) if p == "part2" => part2(&commands),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
